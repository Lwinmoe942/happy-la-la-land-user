const _myanmarDigits = ['၀', '၁', '၂', '၃', '၄', '၅', '၆', '၇', '၈', '၉'];

const _months = [
  'ဇန်နဝါရီ',
  'ဖေဖော်ဝါရီ',
  'မတ်',
  'ဧပြီ',
  'မေ',
  'ဇွန်',
  'ဇူလိုင်',
  'ဩဂုတ်',
  'စက်တင်ဘာ',
  'အောက်တိုဘာ',
  'နိုဝင်ဘာ',
  'ဒီဇင်ဘာ',
];

const _weekdays = [
  'တနင်္လာ',
  'အင်္ဂါ',
  'ဗုဒ္ဓဟူး',
  'ကြာသပတေး',
  'သောကြာ',
  'စနေ',
  'တနင်္ဂနွေ',
];

String toMyanmarDigits(String value) {
  final buffer = StringBuffer();
  for (final char in value.split('')) {
    final code = char.codeUnitAt(0);
    if (code >= 48 && code <= 57) {
      buffer.write(_myanmarDigits[code - 48]);
    } else {
      buffer.write(char);
    }
  }
  return buffer.toString();
}

String mmInt(int value) => toMyanmarDigits(value.toString());

String mmDigits(int value, int width) =>
    toMyanmarDigits(value.toString().padLeft(width, '0'));

String mmMoney(int amount) {
  final raw = amount.abs().toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => ',',
  );
  final sign = amount < 0 ? '-' : '';
  return '$sign${toMyanmarDigits(raw)} ကျပ်';
}

String mmDate(DateTime date) => '${mmInt(date.day)} ${_months[date.month - 1]}';

String mmWeekday(DateTime date) => _weekdays[date.weekday - 1];

String mmTime(DateTime time) => '${mmDigits(time.hour, 2)}:${mmDigits(time.minute, 2)}';

String mmDateTime(DateTime time) => '${mmDate(time)} · ${mmTime(time)}';

String? mmDaysLeft(DateTime? endsAt) {
  if (endsAt == null) {
    return null;
  }
  final days = endsAt.difference(DateTime.now()).inDays;
  if (days < 0) {
    return 'သက်တမ်းကုန်ပါပြီ';
  }
  if (days == 0) {
    return 'ဒီနေ့ နောက်ဆုံး';
  }
  return 'နောက် ${mmInt(days)} ရက်';
}
