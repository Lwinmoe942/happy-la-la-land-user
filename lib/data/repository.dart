import 'models.dart';

class SignUpResult {
  const SignUpResult.ready(this.home) : confirmEmail = false;

  const SignUpResult.confirm() : home = null, confirmEmail = true;

  final HomeData? home;
  final bool confirmEmail;
}

abstract class UserRepository {
  bool get demoMode;

  Future<HomeData?> restore();

  bool get hasPassword;

  Future<SignUpResult> signUp({required String email, required String password});

  Future<void> requestOtp(String email, {required bool signup});

  Future<HomeData> verifyOtp({
    required String email,
    required String code,
    required bool signup,
  });

  Future<HomeData> signInWithPassword({
    required String email,
    required String password,
  });

  Future<void> setPassword(String password);

  Future<Member> updateName(String name);

  Future<HomeData> loadHome();

  Future<List<TimeSlot>> slotsOn(DateTime day);

  Future<Booking> createBooking({
    required String slotId,
    required int children,
    int adults = 0,
  });

  Future<void> cancelBooking(String bookingId);

  Future<LikeUpdate?> setLiked({required String promotionId, required bool liked});

  Future<void> signOut();

  Future<void> deleteAccount();
}
