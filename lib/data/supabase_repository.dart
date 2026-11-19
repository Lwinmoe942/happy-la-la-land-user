import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/gmail.dart';
import 'app_exception.dart';
import 'models.dart';
import 'repository.dart';

class SupabaseUserRepository implements UserRepository {
  SupabaseUserRepository(this.client);

  final SupabaseClient client;
  RealtimeChannel? _newsChannel;

  @override
  bool get demoMode => false;

  @override
  bool get hasPassword {
    final meta = client.auth.currentUser?.userMetadata;
    return meta?['password_set'] == true;
  }

  @override
  Future<HomeData?> restore() async {
    var session = client.auth.currentSession;
    if (session == null) {
      try {
        final refreshed = await client.auth.refreshSession();
        session = refreshed.session ?? client.auth.currentSession;
      } catch (_) {}
    }
    if (session == null) {
      return null;
    }
    try {
      return await loadHome();
    } catch (_) {
      try {
        await client.auth.refreshSession();
        return await loadHome();
      } on AuthException {
        await client.auth.signOut();
        return null;
      } catch (_) {
        // Keep the saved session — a network blip must not force login again.
        return null;
      }
    }
  }

  @override
  Future<SignUpResult> signUp({
    required String email,
    required String password,
  }) async {
    final gmail = GmailAddress.normalize(email);
    if (gmail == null) {
      throw const AppException('Gmail လိပ်စာပဲ သုံးလို့ ရပါတယ်');
    }
    if (password.length < 8) {
      throw const AppException('စကားဝှက်ကို အနည်းဆုံး ၈ လုံး ထားပါ');
    }
    try {
      final response = await client.auth.signUp(
        email: gmail,
        password: password,
        data: const {'password_set': true},
      );
      if (response.session != null) {
        return SignUpResult.ready(await loadHome());
      }
      return const SignUpResult.confirm();
    } on AuthException catch (error) {
      if (_isAlreadyRegistered(error.message)) {
        return _signUpExisting(gmail, password);
      }
      throw AppException(_authMessage(error.message, password: true));
    }
  }

  Future<SignUpResult> _signUpExisting(String gmail, String password) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: gmail,
        password: password,
      );
      if (response.session != null) {
        if (!hasPassword) {
          await client.auth.updateUser(
            UserAttributes(data: const {'password_set': true}),
          );
        }
        return SignUpResult.ready(await loadHome());
      }
    } on AuthException catch (error) {
      if (_needsConfirmation(error.message)) {
        await _sendSignupCode(gmail);
        return const SignUpResult.confirm();
      }
    }
    throw const AppException('ဒီ Gmail နဲ့ အကောင့် ရှိပြီးပါပြီ။ စကားဝှက်နဲ့ ဝင်ပါ။');
  }

  Future<void> _sendSignupCode(String gmail) async {
    try {
      await client.auth.resend(type: OtpType.signup, email: gmail);
    } on AuthException catch (error) {
      throw AppException(_authMessage(error.message));
    }
  }

  @override
  Future<void> requestOtp(String email, {required bool signup}) async {
    final gmail = GmailAddress.normalize(email);
    if (gmail == null) {
      throw const AppException('Gmail လိပ်စာပဲ သုံးလို့ ရပါတယ်');
    }
    try {
      if (signup) {
        await _sendSignupCode(gmail);
        return;
      }
      await client.auth.signInWithOtp(
        email: gmail,
        shouldCreateUser: false,
      );
    } on AuthException catch (error) {
      throw AppException(_authMessage(error.message));
    }
  }

  @override
  Future<HomeData> verifyOtp({
    required String email,
    required String code,
    required bool signup,
  }) async {
    final gmail = GmailAddress.normalize(email);
    if (gmail == null) {
      throw const AppException('Gmail လိပ်စာပဲ သုံးလို့ ရပါတယ်');
    }
    if (!RegExp(r'^\d{6,8}$').hasMatch(code)) {
      throw const AppException('Gmail ထဲက ဂဏန်းကုဒ်ကို အပြည့်ထည့်ပါ');
    }
    final types = signup
        ? const [OtpType.signup]
        : const [OtpType.email, OtpType.magiclink];
    Object? last;
    for (final type in types) {
      try {
        final response = await client.auth.verifyOTP(
          email: gmail,
          token: code,
          type: type,
        );
        if (response.session != null) {
          return loadHome();
        }
        last = const AuthException('otp invalid');
      } on AuthException catch (error) {
        last = error;
        final retry = type != types.last && _isWrongCode(error.message);
        if (!retry) {
          throw AppException(_authMessage(error.message));
        }
      }
    }
    final message = last is AuthException ? last.message : '';
    throw AppException(_authMessage(message.isEmpty ? 'otp invalid' : message));
  }

  @override
  Future<HomeData> signInWithPassword({
    required String email,
    required String password,
  }) async {
    final gmail = GmailAddress.normalize(email);
    if (gmail == null) {
      throw const AppException('Gmail လိပ်စာပဲ သုံးလို့ ရပါတယ်');
    }
    if (password.isEmpty) {
      throw const AppException('စကားဝှက် ထည့်ပါ');
    }
    try {
      final response = await client.auth.signInWithPassword(
        email: gmail,
        password: password,
      );
      if (response.session == null) {
        throw const AppException('Gmail သို့မဟုတ် စကားဝှက် မမှန်ပါ');
      }
      if (!hasPassword) {
        await client.auth.updateUser(
          UserAttributes(data: const {'password_set': true}),
        );
      }
    } on AuthException catch (error) {
      throw AppException(_authMessage(error.message, password: true));
    }
    return loadHome();
  }

  @override
  Future<void> setPassword(String password) async {
    if (password.length < 8) {
      throw const AppException('စကားဝှက်ကို အနည်းဆုံး ၈ လုံး ထားပါ');
    }
    if (client.auth.currentUser == null) {
      throw const AppException('အကောင့် ပြန်ဝင်ပါ');
    }
    try {
      await client.auth.updateUser(
        UserAttributes(
          password: password,
          data: const {'password_set': true},
        ),
      );
    } on AuthException catch (error) {
      throw AppException(_authMessage(error.message, password: true));
    }
  }

  @override
  Future<Member> updateName(String name) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      throw const AppException('အကောင့် ပြန်ဝင်ပါ');
    }
    try {
      final row = await client
          .from('members')
          .update({'name': name})
          .eq('user_id', userId)
          .select()
          .single();
      return Member.fromJson(_asMap(row));
    } on PostgrestException catch (error) {
      throw AppException(_clean(error.message));
    }
  }

  @override
  Future<HomeData> loadHome() async {
    try {
      await client.rpc('ensure_member');
      final data = await client.rpc('my_dashboard');
      if (data is! Map) {
        throw const AppException('အချက်အလက် မဖတ်နိုင်ပါ');
      }
      return await _withLikes(HomeData.fromJson(_asMap(data)));
    } on PostgrestException catch (error) {
      throw AppException(_clean(error.message));
    }
  }

  Future<HomeData> _withLikes(HomeData home) async {
    try {
      final raw = await client.rpc('promotion_likes_for_me');
      final data = raw is String ? jsonDecode(raw) : raw;
      if (data is! List) {
        return home;
      }
      final likes = <String, LikeUpdate>{};
      for (final item in data) {
        final row = _asMap(item);
        final id = row['id'];
        if (id is! String) {
          continue;
        }
        likes[id] = LikeUpdate(
          likeCount: (row['like_count'] as num?)?.toInt() ?? 0,
          liked: row['liked'] == true,
        );
      }
      return HomeData(
        member: home.member,
        stamp: home.stamp,
        bookings: home.bookings,
        visits: home.visits,
        settings: home.settings,
        promotions: home.promotions.map((item) {
          final like = likes[item.id];
          if (like == null) {
            return item;
          }
          return item.copyWith(likeCount: like.likeCount, liked: like.liked, likesKnown: true);
        }).toList(),
      );
    } catch (_) {
      return home;
    }
  }

  @override
  Future<LikeUpdate?> setLiked({required String promotionId, required bool liked}) async {
    if (!RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(promotionId)) {
      return null;
    }
    try {
      final data = await client.rpc(
        'toggle_promotion_like',
        params: {'p_id': promotionId, 'p_liked': liked},
      );
      if (data is! Map) {
        return null;
      }
      final row = _asMap(data);
      return LikeUpdate(
        likeCount: (row['like_count'] as num?)?.toInt() ?? 0,
        liked: row['liked'] == true,
      );
    } on PostgrestException catch (error) {
      final message = error.message.toLowerCase();
      if (message.contains('function') || message.contains('does not exist') || error.code == 'PGRST202') {
        return null;
      }
      throw AppException(_clean(error.message));
    }
  }

  @override
  Future<List<TimeSlot>> slotsOn(DateTime day) async {
    final iso =
        '${day.year.toString().padLeft(4, '0')}-'
        '${day.month.toString().padLeft(2, '0')}-'
        '${day.day.toString().padLeft(2, '0')}';
    try {
      final data = await client.rpc('slots_on', params: {'p_day': iso});
      if (data is! List) {
        return const [];
      }
      return data.map((item) => TimeSlot.fromJson(_asMap(item))).toList();
    } on PostgrestException catch (error) {
      throw AppException(_clean(error.message));
    }
  }

  @override
  Future<Booking> createBooking({
    required String slotId,
    required int children,
    int adults = 0,
  }) async {
    try {
      final data = await client.rpc(
        'create_booking',
        params: {
          'p_slot_id': slotId,
          'p_children': children,
          'p_adults': adults,
        },
      );
      if (data is! Map) {
        throw const AppException('ကြိုတင်စာရင်း မယူနိုင်ပါ');
      }
      return Booking.fromJson(_asMap(data));
    } on PostgrestException catch (error) {
      throw AppException(_clean(error.message));
    }
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    try {
      await client.rpc('cancel_booking', params: {'p_booking_id': bookingId});
    } on PostgrestException catch (error) {
      throw AppException(_clean(error.message));
    }
  }

  @override
  Future<void> signOut() => client.auth.signOut();

  @override
  Future<void> deleteAccount() async {
    try {
      await client.rpc('delete_my_account');
    } on PostgrestException catch (error) {
      throw AppException(_clean(error.message));
    }
    try {
      await client.auth.signOut();
    } catch (_) {}
  }

  void watchPromotions(void Function() onChange) {
    if (_newsChannel != null) {
      return;
    }
    _newsChannel = client
        .channel('rewards-news')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'promotions',
          callback: (_) => onChange(),
        )
        .subscribe();
  }

  Future<void> stopWatchingPromotions() async {
    final channel = _newsChannel;
    _newsChannel = null;
    if (channel != null) {
      await client.removeChannel(channel);
    }
  }
}

bool _isAlreadyRegistered(String message) {
  final lower = message.toLowerCase();
  return lower.contains('already') || lower.contains('exists');
}

bool _needsConfirmation(String message) {
  final lower = message.toLowerCase();
  return lower.contains('not confirmed') || lower.contains('confirm');
}

bool _isWrongCode(String message) {
  final lower = message.toLowerCase();
  return lower.contains('expired') || lower.contains('invalid') || lower.contains('otp');
}

String _authMessage(String message, {bool password = false}) {
  final lower = message.toLowerCase();
  if (lower.contains('socket') ||
      lower.contains('network') ||
      lower.contains('failed host') ||
      lower.contains('connection') ||
      lower.contains('timed out') ||
      lower.contains('fetch')) {
    return 'အင်တာနက် မရောက်ပါ။ ဖုန်းအင်တာနက်ကို ဖွင့်ပြီး ထပ်ကြိုးစားပါ။';
  }
  if (lower.contains('rate') || lower.contains('once every') || lower.contains('only request')) {
    return 'ကုဒ်ကို ခဏနေမှ ထပ်တောင်းပါ';
  }
  if (lower.contains('sending') || lower.contains('smtp')) {
    return 'ကုဒ် မပို့နိုင်ပါ။ ခဏနေမှ ထပ်ကြိုးစားပါ';
  }
  if (lower.contains('not found') || lower.contains('signups not allowed')) {
    return 'အကောင့်မရှိသေးပါ။ အကောင့်ဖွင့်ပါ။';
  }
  if (_needsConfirmation(message)) {
    return 'အီးမေးလ် မအတည်ပြုရသေးပါ။ အကောင့်ဖွင့်မယ်ကနေ ကုဒ်ထည့်ပါ။';
  }
  if (_isAlreadyRegistered(message)) {
    return 'ဒီ Gmail နဲ့ အကောင့် ရှိပြီးပါပြီ။ စကားဝှက်နဲ့ ဝင်ပါ။';
  }
  if (password && (lower.contains('invalid') || lower.contains('credential'))) {
    return 'အကောင့်မရှိသေးရင် အကောင့်ဖွင့်ပါ။ ရှိပြီးသားဆိုရင် စကားဝှက်ကို ပြန်စစ်ပါ။';
  }
  if (lower.contains('password') && (lower.contains('short') || lower.contains('least'))) {
    return 'စကားဝှက်ကို အနည်းဆုံး ၈ လုံး ထားပါ';
  }
  if (_isWrongCode(message)) {
    return 'ကုဒ် မမှန်ပါ။ နောက်ဆုံးရောက်တဲ့စာထဲက ဂဏန်းကို ထည့်ပါ။';
  }
  return 'ဝင်လို့ မရပါ';
}

String _clean(String message) {
  final text = message.trim();
  if (text.isEmpty) {
    return 'မအောင်မြင်ပါ';
  }
  return text;
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
  return {};
}
