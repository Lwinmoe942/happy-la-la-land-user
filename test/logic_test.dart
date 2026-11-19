import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/core/format.dart';
import 'package:user_app/core/gmail.dart';
import 'package:user_app/data/app_exception.dart';
import 'package:user_app/data/booking_rules.dart';
import 'package:user_app/data/models.dart';

void main() {
  test('accepts Gmail addresses only', () {
    expect(GmailAddress.normalize('  Happy@Gmail.com '), 'happy@gmail.com');
    expect(GmailAddress.normalize('parent.name@gmail.com'), 'parent.name@gmail.com');
    expect(GmailAddress.normalize('parent@googlemail.com'), isNull);
    expect(GmailAddress.normalize('parent@yahoo.com'), isNull);
    expect(GmailAddress.normalize('not-an-email'), isNull);
  });

  test('formats dates and money in Myanmar digits', () {
    expect(mmMoney(5000), '၅,၀၀၀ ကျပ်');
    expect(mmMoney(215000), '၂၁၅,၀၀၀ ကျပ်');
    expect(mmDate(DateTime(2026, 11, 17)), '၁၇ နိုဝင်ဘာ');
    expect(mmTime(DateTime(2026, 11, 17, 9, 5)), '၀၉:၀၅');
    expect(mmWeekday(DateTime(2026, 11, 17)), 'အင်္ဂါ');
  });

  test('four paid visits unlock one free visit', () {
    final visits = List.generate(4, (index) {
      return Visit(
        id: '$index',
        kind: 'paid',
        children: 1,
        freeChildren: 0,
        amount: 5000,
        createdAt: DateTime(2026, 1, index + 1),
        voided: false,
      );
    });
    final ready = StampStatus.fromVisits(visits);
    expect(ready.filled, 4);
    expect(ready.rewardReady, isTrue);
    expect(ready.paidVisits, 4);

    final redeemed = StampStatus.fromVisits([
      ...visits,
      Visit(
        id: 'free',
        kind: 'free',
        children: 1,
        freeChildren: 1,
        amount: 0,
        createdAt: DateTime(2026, 2, 1),
        voided: false,
      ),
    ]);
    expect(redeemed.filled, 0);
    expect(redeemed.rewardReady, isFalse);
    expect(redeemed.freeUsed, 1);
  });

  test('voided visits do not count', () {
    final stamp = StampStatus.fromVisits([
      Visit(
        id: 'void',
        kind: 'paid',
        children: 1,
        freeChildren: 0,
        amount: 5000,
        createdAt: DateTime(2026, 3, 1),
        voided: true,
      ),
    ]);
    expect(stamp.filled, 0);
    expect(stamp.paidVisits, 0);
  });

  test('booking rules keep one active booking and a full slot closed', () {
    final now = DateTime(2026, 11, 17, 8);
    BookingRules.checkCreate(
      now: now,
      slotStart: DateTime(2026, 11, 17, 10),
      children: 2,
      remaining: 2,
      hasActiveBooking: false,
    );
    expect(
      () => BookingRules.checkCreate(
        now: now,
        slotStart: DateTime(2026, 11, 17, 10),
        children: 2,
        remaining: 1,
        hasActiveBooking: false,
      ),
      throwsA(isA<AppException>()),
    );
    expect(
      () => BookingRules.checkCreate(
        now: now,
        slotStart: DateTime(2026, 11, 17, 11),
        children: 1,
        remaining: 10,
        hasActiveBooking: true,
      ),
      throwsA(isA<AppException>()),
    );
  });

  test('a booking can be cancelled until two hours before', () {
    expect(
      () => BookingRules.checkCancel(
        now: DateTime(2026, 11, 17, 9),
        slotStart: DateTime(2026, 11, 17, 10),
        cancelHours: 2,
        status: 'confirmed',
      ),
      throwsA(isA<AppException>()),
    );
    BookingRules.checkCancel(
      now: DateTime(2026, 11, 17, 7),
      slotStart: DateTime(2026, 11, 17, 10),
      cancelHours: 2,
      status: 'confirmed',
    );
    expect(
      BookingRules.isUpcoming(
        status: 'confirmed',
        endsAt: DateTime(2026, 11, 17, 11),
        now: DateTime(2026, 11, 17, 10, 30),
      ),
      isTrue,
    );
  });
}
