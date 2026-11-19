class AppConfig {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://perceptive-liberation-production-38a4c425.up.railway.app',
  );
  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_5xxH2rwEzatmxetJsgyCyg_TQ3RH35M',
  );

  static bool get useSupabase =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static const demoOtpCode = '123456';
  static const demoSampleEmail = 'lalaland@gmail.com';
}
