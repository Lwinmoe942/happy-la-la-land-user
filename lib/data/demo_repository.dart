import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/config.dart';
import '../core/gmail.dart';
import 'app_exception.dart';
import 'booking_rules.dart';
import 'models.dart';
import 'repository.dart';

class DemoRepository implements UserRepository {
  DemoRepository._(this._prefs, this._db);

  final SharedPreferences _prefs;
  final Map<String, dynamic> _db;

  static const _storageKey = 'hll_demo_v2';

  static Future<DemoRepository> open() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    Map<String, dynamic> db = {'session': null, 'members': <String, dynamic>{}};
    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        db = decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    }
    db.putIfAbsent('members', () => <String, dynamic>{});
    return DemoRepository._(prefs, db);
  }

  @override
  bool get demoMode => true;

  @override
  bool get hasPassword {
    final phone = _db['session'] as String?;
    if (phone == null) {
      return false;
    }
    final password = _recordFor(phone)?['password'];
    return password is String && password.isNotEmpty;
  }

  Map<String, dynamic> get _members =>
      (_db['members'] as Map).map((key, value) => MapEntry(key.toString(), value));

  Future<void> _save() {
    _db['members'] = _members;
    return _prefs.setString(_storageKey, jsonEncode(_db));
  }

  Map<String, dynamic>? _recordFor(String phone) {
    final value = _members[phone];
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    return null;
  }

  @override
  Future<HomeData?> restore() async {
    final phone = _db['session'] as String?;
    if (phone == null) {
      return null;
    }
    return _homeFor(phone);
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
    final existing = _recordFor(gmail);
    final saved = existing?['password'];
    if (saved is String && saved.isNotEmpty && saved != password) {
      throw const AppException('ဒီ Gmail နဲ့ အကောင့် ရှိပြီးပါပြီ။ စကားဝှက်နဲ့ ဝင်ပါ။');
    }
    final record = existing ?? _newRecord(gmail);
    record['password'] = password;
    _db['members'] = {..._members, gmail: record};
    _db['session'] = gmail;
    await _save();
    return SignUpResult.ready(_homeFor(gmail));
  }

  @override
  Future<void> requestOtp(String email, {required bool signup}) async {
    final gmail = GmailAddress.normalize(email);
    if (gmail == null) {
      throw const AppException('Gmail လိပ်စာပဲ သုံးလို့ ရပါတယ်');
    }
    if (!signup && _recordFor(gmail) == null) {
      throw const AppException('အကောင့်မရှိသေးပါ။ အကောင့်ဖွင့်ပါ။');
    }
  }

  @override
  Future<HomeData> verifyOtp({
    required String email,
    required String code,
    required bool signup,
  }) async {
    final national = GmailAddress.normalize(email);
    if (national == null) {
      throw const AppException('Gmail လိပ်စာပဲ သုံးလို့ ရပါတယ်');
    }
    if (code != AppConfig.demoOtpCode) {
      throw const AppException('ကုဒ် မမှန်ပါ');
    }
    if (_recordFor(national) == null) {
      _db['members'] = {
        ..._members,
        national: _newRecord(national),
      };
      await _save();
    }
    _db['session'] = national;
    await _save();
    return _homeFor(national);
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
    final saved = _recordFor(gmail)?['password'];
    if (saved is! String || saved.isEmpty || saved != password) {
      throw const AppException('Gmail သို့မဟုတ် စကားဝှက် မမှန်ပါ');
    }
    _db['session'] = gmail;
    await _save();
    return _homeFor(gmail);
  }

  @override
  Future<void> setPassword(String password) async {
    if (password.length < 8) {
      throw const AppException('စကားဝှက်ကို အနည်းဆုံး ၈ လုံး ထားပါ');
    }
    final phone = _requiredPhone();
    final record = _requiredRecord(phone);
    record['password'] = password;
    _db['members'] = {..._members, phone: record};
    await _save();
  }

  @override
  Future<Member> updateName(String name) async {
    final phone = _requiredPhone();
    final record = _requiredRecord(phone);
    final member = Member.fromJson(_asMap(record['member'])).copyWith(name: name);
    record['member'] = member.toJson();
    _db['members'] = {..._members, phone: record};
    await _save();
    return member;
  }

  @override
  Future<HomeData> loadHome() async {
    return _homeFor(_requiredPhone());
  }

  @override
  Future<List<TimeSlot>> slotsOn(DateTime day) async {
    final phone = _db['session'] as String?;
    final bookings = phone == null
        ? const <Booking>[]
        : _bookingsOf(_requiredRecord(phone));
    return _slotsForDay(day, bookings);
  }

  @override
  Future<Booking> createBooking({
    required String slotId,
    required int children,
    int adults = 0,
  }) async {
    final phone = _requiredPhone();
    final record = _requiredRecord(phone);
    final bookings = _bookingsOf(record);
    final now = DateTime.now();
    TimeSlot? slot;
    for (var offset = 0; offset < 14; offset++) {
      final day = DateTime(now.year, now.month, now.day).add(Duration(days: offset));
      for (final candidate in _slotsForDay(day, bookings)) {
        if (candidate.id == slotId) {
          slot = candidate;
          break;
        }
      }
      if (slot != null) {
        break;
      }
    }
    if (slot == null) {
      throw const AppException('အချိန်ကွက် မတွေ့ပါ');
    }
    final hasActive = bookings.any(
      (booking) => BookingRules.isUpcoming(
        status: booking.status,
        endsAt: booking.endsAt,
        now: now,
      ),
    );
    BookingRules.checkCreate(
      now: now,
      slotStart: slot.startsAt,
      children: children,
      adults: adults,
      remaining: slot.remaining,
      hasActiveBooking: hasActive,
    );
    final booking = Booking(
      id: 'b${DateTime.now().microsecondsSinceEpoch}',
      slotId: slot.id,
      startsAt: slot.startsAt,
      endsAt: slot.endsAt,
      children: children,
      adults: adults,
      status: 'confirmed',
      createdAt: now,
    );
    final stored = [..._rawList(record['bookings']), booking.toJson()];
    record['bookings'] = stored;
    _db['members'] = {..._members, phone: record};
    await _save();
    return booking;
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    final phone = _requiredPhone();
    final record = _requiredRecord(phone);
    final bookings = _bookingsOf(record);
    final index = bookings.indexWhere((booking) => booking.id == bookingId);
    if (index < 0) {
      throw const AppException('စာရင်း မတွေ့ပါ');
    }
    final booking = bookings[index];
    BookingRules.checkCancel(
      now: DateTime.now(),
      slotStart: booking.startsAt,
      cancelHours: VenueSettings.defaults.cancelHours,
      status: booking.status,
    );
    final raw = _rawList(record['bookings']);
    raw[index] = booking.copyWith(status: 'cancelled').toJson();
    record['bookings'] = raw;
    _db['members'] = {..._members, phone: record};
    await _save();
  }

  @override
  Future<LikeUpdate?> setLiked({required String promotionId, required bool liked}) async => null;

  @override
  Future<void> signOut() async {
    _db['session'] = null;
    await _save();
  }

  @override
  Future<void> deleteAccount() async {
    final phone = _db['session'] as String?;
    if (phone != null) {
      final next = Map<String, dynamic>.from(_members)..remove(phone);
      _db['members'] = next;
    }
    _db['session'] = null;
    await _save();
  }

  HomeData _homeFor(String phone) {
    final record = _requiredRecord(phone);
    final visits = _visitsOf(record);
    return HomeData(
      member: Member.fromJson(_asMap(record['member'])),
      stamp: StampStatus.fromVisits(visits),
      bookings: _bookingsOf(record),
      promotions: _promotions,
      visits: visits.reversed.toList(),
      settings: VenueSettings.defaults,
    );
  }

  String _requiredPhone() {
    final phone = _db['session'] as String?;
    if (phone == null) {
      throw const AppException('အကောင့် ပြန်ဝင်ပါ');
    }
    return phone;
  }

  Map<String, dynamic> _requiredRecord(String phone) {
    final record = _recordFor(phone);
    if (record == null) {
      throw const AppException('အကောင့် မတွေ့ပါ');
    }
    return record;
  }

  Map<String, dynamic> _newRecord(String phone) {
    final now = DateTime.now();
    final member = Member(
      id: 'm$phone',
      email: phone,
      name: '',
      qrCode: _codeFor(phone),
      createdAt: now,
    );
    final visits = phone == AppConfig.demoSampleEmail
        ? [
            _seedVisit('seed-1', now.subtract(const Duration(days: 16))),
            _seedVisit('seed-2', now.subtract(const Duration(days: 10))),
            _seedVisit('seed-3', now.subtract(const Duration(days: 4))),
          ]
        : <Map<String, dynamic>>[];
    return {
      'member': member.toJson(),
      'visits': visits,
      'bookings': <Map<String, dynamic>>[],
    };
  }

  Map<String, dynamic> _seedVisit(String id, DateTime when) {
    return Visit(
      id: id,
      kind: 'paid',
      children: 1,
      freeChildren: 0,
      amount: VenueSettings.defaults.pricePerChild,
      createdAt: when,
      voided: false,
    ).toJson();
  }

  String _codeFor(String phone) {
    if (phone == AppConfig.demoSampleEmail) {
      return 'HLL-7K2P9Q';
    }
    const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    final suffix = List.generate(6, (_) => alphabet[random.nextInt(alphabet.length)]).join();
    return 'HLL-$suffix';
  }

  List<Visit> _visitsOf(Map<String, dynamic> record) {
    return _rawList(record['visits']).map(Visit.fromJson).toList();
  }

  List<Booking> _bookingsOf(Map<String, dynamic> record) {
    return _rawList(record['bookings']).map(Booking.fromJson).toList();
  }

  List<TimeSlot> _slotsForDay(DateTime day, List<Booking> bookings) {
    final settings = VenueSettings.defaults;
    final slots = <TimeSlot>[];
    var minute = settings.openHour * 60;
    final last = settings.closeHour * 60 - settings.slotMinutes;
    while (minute <= last) {
      final start = DateTime(day.year, day.month, day.day, minute ~/ 60, minute % 60);
      final end = start.add(Duration(minutes: settings.slotMinutes));
      final id = _slotId(start);
      final own = bookings
          .where(
            (booking) =>
                booking.slotId == id &&
                (booking.status == 'confirmed' || booking.status == 'arrived'),
          )
          .fold<int>(0, (sum, booking) => sum + booking.children);
      final taken = _sampleTaken(id, settings.capacity) + own;
      slots.add(
        TimeSlot(
          id: id,
          startsAt: start,
          endsAt: end,
          capacity: settings.capacity,
          bookedChildren: taken > settings.capacity ? settings.capacity : taken,
        ),
      );
      minute += settings.slotMinutes;
    }
    return slots;
  }

  String _slotId(DateTime start) {
    final year = start.year.toString().padLeft(4, '0');
    final month = start.month.toString().padLeft(2, '0');
    final day = start.day.toString().padLeft(2, '0');
    final hour = start.hour.toString().padLeft(2, '0');
    final minute = start.minute.toString().padLeft(2, '0');
    return 'd$year$month$day-t$hour$minute';
  }

  int _sampleTaken(String id, int capacity) {
    var hash = 0;
    for (final unit in id.codeUnits) {
      hash = (hash * 33 + unit) % 997;
    }
    final taken = 4 + (hash % 22);
    final cap = capacity - 1;
    return taken > cap ? cap : taken;
  }

  List<Promotion> get _promotions => const [
    Promotion(
      id: 'promo-monday',
      title: 'တနင်္လာနေ့ မိသားစု လျှော့ဈေး',
      body: 'တနင်္လာနေ့မှာ ကလေး ၂ ယောက်စာ ဝင်ရင် ၁ ယောက်စာ လျှော့ပေးပါမယ်။',
      discountLabel: '၁ ယောက်စာ လျှော့',
      endsAt: null,
    ),
    Promotion(
      id: 'promo-birthday',
      title: 'မွေးနေ့ပွဲ ပက်ကေ့ချ်',
      body: 'မွေးနေ့ပွဲ ကြိုတင်ယူရင် ဝင်ကြေး ၁၀% လျှော့ပါမယ်။ ဆိုင်ကို ဖုန်းဆက်ပြီး အတည်ပြုပါ။',
      discountLabel: '၁၀% လျှော့',
      endsAt: null,
    ),
  ];
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

List<Map<String, dynamic>> _rawList(Object? value) {
  if (value is! List) {
    return [];
  }
  return value.map(_asMap).toList();
}
