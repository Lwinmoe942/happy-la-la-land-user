class GmailAddress {
  static final _pattern = RegExp(r'^[a-z0-9._%+\-]+@gmail\.com$');

  static String? normalize(String input) {
    final email = input.trim().toLowerCase();
    if (!_pattern.hasMatch(email)) {
      return null;
    }
    return email;
  }
}
