import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/app_exception.dart';
import '../data/booking_rules.dart';
import '../data/like_store.dart';
import '../data/login_credentials.dart';
import '../data/models.dart';
import '../data/news_read_store.dart';
import '../data/repository.dart';
import '../data/supabase_repository.dart';

class AppState extends ChangeNotifier {
  AppState(this.repo);

  final UserRepository repo;

  Member? member;
  StampStatus stamp = StampStatus.empty;
  List<Booking> bookings = const [];
  List<Promotion> promotions = const [];
  List<Visit> visits = const [];
  VenueSettings settings = VenueSettings.defaults;
  String? pendingEmail;
  String? pendingPassword;
  bool pendingSignup = false;
  bool passwordReady = false;
  bool booted = false;
  bool busy = false;
  String? loadError;
  Future<void> Function(List<Promotion> promotions)? onNews;
  Future<void> Function()? onNewsCleared;
  Timer? _newsTimer;
  var _newsWatching = false;
  Set<String> _likedIds = {};
  Set<String> _readNews = {};

  int get newsCount => promotions.where((item) => !_readNews.contains(item.id)).length;

  bool get demoMode => repo.demoMode;

  Booking? get upcoming {
    final now = DateTime.now();
    final active = bookings.where(
      (booking) => BookingRules.isUpcoming(
        status: booking.status,
        endsAt: booking.endsAt,
        now: now,
      ),
    );
    final list = active.toList()..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    if (list.isEmpty) {
      return null;
    }
    return list.first;
  }

  Future<void> boot() async {
    _likedIds = await LikeStore.load();
    _readNews = await NewsReadStore.load();
    final home = await repo.restore();
    if (home != null) {
      _apply(home, notify: false);
      // A restored session means the user is already signed in.
      // Do not send them to the password page on every app open.
      passwordReady = true;
    }
    booted = true;
    notifyListeners();
  }

  Future<void> signUp(String email, String password) {
    return _guard(() async {
      final result = await repo.signUp(email: email, password: password);
      if (result.home != null) {
        pendingEmail = null;
        pendingPassword = null;
        pendingSignup = false;
        passwordReady = true;
        _apply(result.home!, notify: false);
        return;
      }
      pendingEmail = email.trim().toLowerCase();
      pendingPassword = password;
      pendingSignup = true;
    });
  }

  Future<void> requestOtp(String email, {bool signup = false}) {
    return _guard(() async {
      final confirming = signup || pendingSignup;
      await repo.requestOtp(email, signup: confirming);
      pendingEmail = email.trim().toLowerCase();
      pendingSignup = confirming;
    });
  }

  Future<void> verifyOtp(String code) {
    final email = pendingEmail;
    final signup = pendingSignup;
    final chosenPassword = pendingPassword;
    return _guard(() async {
      if (email == null) {
        throw const AppException('Gmail ပြန်ထည့်ပါ');
      }
      final home = await repo.verifyOtp(
        email: email,
        code: code.trim(),
        signup: signup,
      );
      var ready = repo.hasPassword;
      if (chosenPassword != null && !ready) {
        try {
          await repo.setPassword(chosenPassword);
          ready = true;
        } on AppException {
          ready = repo.hasPassword;
        }
      }
      if (!signup) {
        ready = false;
      }
      pendingEmail = null;
      pendingPassword = ready ? null : chosenPassword;
      pendingSignup = false;
      passwordReady = ready;
      _apply(home, notify: false);
    });
  }

  Future<void> signInWithPassword(String email, String password, {bool remember = true}) {
    return _guard(() async {
      final home = await repo.signInWithPassword(email: email, password: password);
      pendingEmail = null;
      passwordReady = true;
      await LoginCredentials.save(email: email, password: password, remember: remember);
      _apply(home, notify: false);
    });
  }

  Future<void> setPassword(String password) {
    return _guard(() async {
      await repo.setPassword(password);
      passwordReady = true;
    });
  }

  Future<void> saveName(String name) {
    return _guard(() async {
      final updated = await repo.updateName(name.trim());
      member = updated;
    });
  }

  Future<void> refresh() async {
    if (member == null) {
      return;
    }
    try {
      final home = await repo.loadHome();
      loadError = null;
      _apply(home);
    } catch (error) {
      loadError = error is Exception ? error.toString() : 'မဖတ်နိုင်ပါ';
      notifyListeners();
    }
  }

  Future<List<TimeSlot>> slotsOn(DateTime day) => repo.slotsOn(day);

  Future<void> book({
    required String slotId,
    required int children,
    int adults = 0,
  }) {
    return _guard(() async {
      await repo.createBooking(
        slotId: slotId,
        children: children,
        adults: adults,
      );
      _apply(await repo.loadHome(), notify: false);
    });
  }

  Future<void> cancel(String bookingId) {
    return _guard(() async {
      await repo.cancelBooking(bookingId);
      _apply(await repo.loadHome(), notify: false);
    });
  }

  Future<void> toggleLike(String id) async {
    final index = promotions.indexWhere((item) => item.id == id);
    if (index < 0) {
      return;
    }
    final current = promotions[index];
    final next = !current.liked;
    if (next) {
      _likedIds.add(id);
    } else {
      _likedIds.remove(id);
    }
    await LikeStore.save(_likedIds);
    final count = current.likeCount + (next ? 1 : -1);
    promotions = [...promotions]
      ..[index] = current.copyWith(liked: next, likeCount: count < 0 ? 0 : count);
    notifyListeners();
    try {
      final update = await repo.setLiked(promotionId: id, liked: next);
      if (update == null) {
        return;
      }
      if (update.liked) {
        _likedIds.add(id);
      } else {
        _likedIds.remove(id);
      }
      await LikeStore.save(_likedIds);
      final latest = promotions.indexWhere((item) => item.id == id);
      if (latest < 0) {
        return;
      }
      promotions = [...promotions]
        ..[latest] = promotions[latest].copyWith(
          liked: update.liked,
          likeCount: update.likeCount,
          likesKnown: true,
        );
      notifyListeners();
    } catch (_) {}
  }

  Future<void> markNewsRead() async {
    for (final item in promotions) {
      _readNews.add(item.id);
    }
    await NewsReadStore.save(_readNews);
    notifyListeners();
    final clear = onNewsCleared;
    if (clear != null) {
      await clear();
    }
  }

  Future<void> pullNews() async {
    if (member == null || busy) {
      return;
    }
    try {
      final home = await repo.loadHome();
      if (member == null) {
        return;
      }
      _apply(home);
    } catch (_) {}
  }

  Future<void> signOut() async {
    _newsTimer?.cancel();
    _newsTimer = null;
    _newsWatching = false;
    final repository = repo;
    if (repository is SupabaseUserRepository) {
      unawaited(repository.stopWatchingPromotions());
    }
    await repo.signOut();
    _clearLocalSession();
  }

  Future<void> deleteAccount() {
    return _guard(() async {
      _newsTimer?.cancel();
      _newsTimer = null;
      _newsWatching = false;
      final repository = repo;
      if (repository is SupabaseUserRepository) {
        unawaited(repository.stopWatchingPromotions());
      }
      await repo.deleteAccount();
      _clearLocalSession(clearSavedLogin: true);
    });
  }

  void _clearLocalSession({bool clearSavedLogin = false}) {
    member = null;
    stamp = StampStatus.empty;
    bookings = const [];
    promotions = const [];
    visits = const [];
    pendingEmail = null;
    pendingPassword = null;
    pendingSignup = false;
    passwordReady = false;
    loadError = null;
    if (clearSavedLogin) {
      unawaited(LoginCredentials.clear());
    }
    notifyListeners();
  }

  Future<void> _guard(Future<void> Function() action) async {
    if (busy) {
      return;
    }
    busy = true;
    notifyListeners();
    try {
      await action();
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  void _apply(HomeData home, {bool notify = true}) {
    member = home.member;
    stamp = home.stamp;
    bookings = home.bookings;
    promotions = home.promotions.map(_withLocalLike).toList();
    if (promotions.any((item) => item.likesKnown)) {
      unawaited(LikeStore.save(_likedIds));
    }
    visits = home.visits;
    settings = home.settings;
    loadError = null;
    if (member != null) {
      _ensureNewsWatch();
      final notifyNews = onNews;
      if (notifyNews != null) {
        unawaited(notifyNews(promotions));
      }
    }
    if (notify) {
      notifyListeners();
    }
  }

  Promotion _withLocalLike(Promotion item) {
    if (item.likesKnown) {
      if (item.liked) {
        _likedIds.add(item.id);
      } else {
        _likedIds.remove(item.id);
      }
      return item;
    }
    if (!_likedIds.contains(item.id)) {
      return item;
    }
    return item.copyWith(liked: true, likeCount: item.likeCount + 1);
  }

  void _ensureNewsWatch() {
    if (_newsWatching) {
      return;
    }
    _newsWatching = true;
    final repository = repo;
    if (repository is SupabaseUserRepository) {
      repository.watchPromotions(pullNews);
    }
    _newsTimer = Timer.periodic(const Duration(seconds: 40), (_) => pullNews());
  }
}
