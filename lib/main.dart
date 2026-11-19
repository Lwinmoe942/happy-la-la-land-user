import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'bootstrap.dart';
import 'core/language.dart';
import 'core/play_update.dart';
import 'core/reward_alerts.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  final repository = await openRepository();
  final state = AppState(repository);
  final language = await AppLanguage.load();
  final alerts = RewardAlerts();
  state.onNews = alerts.announce;
  state.onNewsCleared = alerts.clear;
  await alerts.prepare();
  await state.boot();
  final router = buildRouter(state);
  alerts.onOpen = () {
    if (state.member != null) {
      router.go('/news');
    }
  };
  if (alerts.openedRewards && state.member != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) => router.go('/news'));
  }
  WidgetsBinding.instance.addObserver(_AppLifecycle(state));
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>.value(value: state),
        ChangeNotifierProvider<AppLanguage>.value(value: language),
      ],
      child: HappyApp(router: router),
    ),
  );
  // After first frame so Play UI can show on top of the app.
  WidgetsBinding.instance.addPostFrameCallback((_) => PlayUpdate.checkNow());
}

class _AppLifecycle extends WidgetsBindingObserver {
  _AppLifecycle(this.state);

  final AppState state;

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    if (lifecycle == AppLifecycleState.resumed) {
      state.pullNews();
      PlayUpdate.checkNow();
    }
  }
}
