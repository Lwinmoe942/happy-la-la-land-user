import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';
import 'account_page.dart';
import 'book_page.dart';
import 'home_page.dart';
import 'location_page.dart';
import 'menu_page.dart';
import 'offers_page.dart';
import 'widgets.dart';

enum AppTab { menu, main, book, rewards, location, account }

class AppShell extends StatelessWidget {
  const AppShell({required this.tab, super.key});

  final AppTab tab;

  @override
  Widget build(BuildContext context) {
    final page = switch (tab) {
      AppTab.menu => const MenuPage(),
      AppTab.main => const HomePage(),
      AppTab.book => const BookPage(),
      AppTab.rewards => const OffersPage(),
      AppTab.location => const LocationPage(),
      AppTab.account => const AccountPage(),
    };
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: AppFrame(
          child: Column(
            children: [
              Expanded(child: page),
              _BottomNav(tab: tab),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.tab});

  final AppTab tab;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        children: [
          _item(context, AppTab.menu, Icons.grid_view_rounded, 'Home', '/home'),
          _item(context, AppTab.main, Icons.home_rounded, 'Main', '/main'),
          _item(context, AppTab.book, Icons.event_available_rounded, 'Booking', '/book'),
          _item(context, AppTab.account, Icons.person_rounded, 'Account', '/account'),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, AppTab value, IconData icon, String label, String path) {
    final selected = tab == value ||
        (value == AppTab.menu && (tab == AppTab.rewards || tab == AppTab.location));
    final color = selected ? AppColors.coral : AppColors.muted;
    return Expanded(
      child: InkWell(
        onTap: () => context.go(path),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 2),
              Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}
