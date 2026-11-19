import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config.dart';
import 'data/demo_repository.dart';
import 'data/repository.dart';
import 'data/supabase_repository.dart';

Future<UserRepository> openRepository() async {
  if (!AppConfig.useSupabase) {
    return DemoRepository.open();
  }
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    publishableKey: AppConfig.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.implicit,
      persistSession: true,
      autoRefreshToken: true,
    ),
  );
  return SupabaseUserRepository(Supabase.instance.client);
}
