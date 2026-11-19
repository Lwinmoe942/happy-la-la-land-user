import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/theme.dart';
import 'state/app_state.dart';
import 'ui/about_page.dart';
import 'ui/customer_service_page.dart';
import 'ui/login_page.dart';
import 'ui/offer_detail_page.dart';
import 'ui/name_page.dart';
import 'ui/news_page.dart';
import 'ui/otp_page.dart';
import 'ui/legal_pages.dart';
import 'ui/password_page.dart';
import 'ui/shell.dart';
import 'ui/signup_page.dart';

GoRouter buildRouter(AppState state) {
  return GoRouter(
    refreshListenable: state,
    initialLocation: _start(state),
    redirect: (context, route) {
      final location = route.matchedLocation;
      final member = state.member;
      if (member == null) {
        if (location == '/login' || location == '/signup') {
          return null;
        }
        if (location == '/otp' && state.pendingEmail != null) {
          return null;
        }
        return '/login';
      }
      if (!state.passwordReady) {
        return location == '/password' ? null : '/password';
      }
      if (member.name.trim().isEmpty) {
        return location == '/name' ? null : '/name';
      }
      if (location == '/login' ||
          location == '/signup' ||
          location == '/otp' ||
          location == '/name' ||
          location == '/password') {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/signup', builder: (context, state) => const SignUpPage()),
      GoRoute(path: '/otp', builder: (context, state) => const OtpPage()),
      GoRoute(path: '/password', builder: (context, state) => const PasswordPage()),
      GoRoute(path: '/name', builder: (context, state) => const NamePage()),
      GoRoute(path: '/home', builder: (context, state) => const AppShell(tab: AppTab.menu)),
      GoRoute(path: '/main', builder: (context, state) => const AppShell(tab: AppTab.main)),
      GoRoute(path: '/book', builder: (context, state) => const AppShell(tab: AppTab.book)),
      GoRoute(path: '/offers', builder: (context, state) => const AppShell(tab: AppTab.rewards)),
      GoRoute(
        path: '/offer/:id',
        builder: (context, state) => OfferDetailPage(id: state.pathParameters['id']!),
      ),
      GoRoute(path: '/location', builder: (context, state) => const AppShell(tab: AppTab.location)),
      GoRoute(path: '/account', builder: (context, state) => const AppShell(tab: AppTab.account)),
      GoRoute(path: '/news', builder: (context, state) => const NewsPage()),
      GoRoute(path: '/service', builder: (context, state) => const CustomerServicePage()),
      GoRoute(path: '/about', builder: (context, state) => const AboutPage()),
      GoRoute(path: '/privacy', builder: (context, state) => const PrivacyPage()),
      GoRoute(path: '/terms', builder: (context, state) => const TermsPage()),
      GoRoute(path: '/content-policy', builder: (context, state) => const ContentPolicyPage()),
      GoRoute(path: '/delete-account', builder: (context, state) => const AccountDeletionPage()),
    ],
  );
}

String _start(AppState state) {
  final member = state.member;
  if (member == null) {
    return '/login';
  }
  if (!state.passwordReady) {
    return '/password';
  }
  if (member.name.trim().isEmpty) {
    return '/name';
  }
  return '/home';
}

class HappyApp extends StatelessWidget {
  const HappyApp({required this.router, super.key});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'HAPPY LA LA LAND',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      routerConfig: router,
    );
  }
}
