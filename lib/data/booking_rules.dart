import '../core/format.dart';
import 'app_exception.dart';

class BookingRules {
  static void checkCreate({
    required DateTime now,
    required DateTime slotStart,
    required int children,
    int adults = 0,
    required int remaining,
    required bool hasActiveBooking,
  }) {
    if (children < 0 || adults < 0 || children + adults < 1) {
      throw const AppException('ကလေး သို့မဟုတ် လူကြီး အနည်းဆုံး ၁ ဦး ရွေးပါ');
    }
    if (hasActiveBooking) {
      throw const AppException('မရောက်သေးတဲ့ ကြိုတင်စာရင်း တစ်ခု ရှိပြီးပါပြီ');
    }
    if (!slotStart.isAfter(now)) {
      throw const AppException('ဒီအချိန်ကွက်ကို ယူလို့ မရတော့ပါ');
    }
    if (remaining < children) {
      throw const AppException('နေရာ မလောက်တော့ပါ');
    }
  }

  static void checkCancel({
    required DateTime now,
    required DateTime slotStart,
    required int cancelHours,
    required String status,
  }) {
    if (status != 'confirmed') {
      throw const AppException('ဒီစာရင်းကို ပယ်ဖျက်လို့ မရပါ');
    }
    if (slotStart.difference(now) < Duration(hours: cancelHours)) {
      throw AppException(
        'သွားမယ့်အချိန် မတိုင်ခင် ${mmInt(cancelHours)} နာရီအလိုအထိပဲ ပယ်ဖျက်လို့ ရပါမယ်',
      );
    }
  }

  static bool isUpcoming({
    required String status,
    required DateTime endsAt,
    required DateTime now,
  }) {
    return status == 'confirmed' && endsAt.isAfter(now);
  }
}
