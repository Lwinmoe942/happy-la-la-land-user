import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:user_app/data/models.dart';
import 'package:user_app/data/repository.dart';
import 'package:user_app/state/app_state.dart';
import 'package:user_app/ui/home_page.dart';
import 'package:user_app/ui/login_page.dart';

void main() {
  testWidgets('login page shows the playground name', (tester) async {
    final state = AppState(_FakeRepository());
    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: const MaterialApp(home: LoginPage()),
      ),
    );
    expect(find.byKey(const Key('app-logo')), findsOneWidget);
    expect(find.text('Gmail နဲ့ ဝင်မယ်'), findsOneWidget);
    expect(find.textContaining('စမ်းသပ်အသုံးပြုမှု'), findsOneWidget);
  });

  testWidgets('home page shows the member QR code', (tester) async {
    final state = AppState(_FakeRepository());
    state.member = Member(
      id: '1',
      email: 'lalaland@gmail.com',
      name: 'မမလှ',
      qrCode: 'HLL-7K2P9Q',
      createdAt: DateTime(2026, 1, 1),
    );
    state.stamp = const StampStatus(
      filled: 3,
      rewardReady: false,
      paidVisits: 3,
      freeUsed: 0,
    );
    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: const MaterialApp(home: HomePage()),
      ),
    );
    expect(find.text('မမလှ'), findsOneWidget);
    expect(find.text('HLL-7K2P9Q'), findsOneWidget);
    expect(find.text('နောက် ၁ ကြိမ်လာရင် free'), findsOneWidget);
  });
}

class _FakeRepository implements UserRepository {
  @override
  bool get demoMode => true;

  @override
  Future<Booking> createBooking({
    required String slotId,
    required int children,
    int adults = 0,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> cancelBooking(String bookingId) async {}

  @override
  Future<HomeData> loadHome() async => throw UnimplementedError();

  @override
  Future<HomeData?> restore() async => null;

  @override
  bool get hasPassword => false;

  @override
  Future<SignUpResult> signUp({
    required String email,
    required String password,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> requestOtp(String email, {required bool signup}) async {}

  @override
  Future<HomeData> signInWithPassword({
    required String email,
    required String password,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> setPassword(String password) async {}

  @override
  Future<LikeUpdate?> setLiked({required String promotionId, required bool liked}) async => null;

  @override
  Future<void> signOut() async {}

  @override
  Future<void> deleteAccount() async {}

  @override
  Future<List<TimeSlot>> slotsOn(DateTime day) async => const [];

  @override
  Future<Member> updateName(String name) async => throw UnimplementedError();

  @override
  Future<HomeData> verifyOtp({
    required String email,
    required String code,
    required bool signup,
  }) async {
    throw UnimplementedError();
  }
}
