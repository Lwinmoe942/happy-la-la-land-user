import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../state/app_state.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final name = state.member?.name ?? '';
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 28),
          decoration: const BoxDecoration(
            color: AppColors.coral,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.go('/account'),
                    icon: const Icon(Icons.account_circle_rounded, color: Colors.white, size: 32),
                  ),
                  const Spacer(),
                  _NewsBell(count: state.newsCount),
                ],
              ),
              Image.asset('assets/logo.png', width: 180, fit: BoxFit.contain),
              const SizedBox(height: 8),
              Text(
                name,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.white,
            child: const Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      _MenuTile(
                        icon: Icons.card_giftcard_rounded,
                        label: 'Rewards',
                        path: '/offers',
                      ),
                      _MenuDivider.vertical(),
                      _MenuTile(
                        icon: Icons.home_rounded,
                        label: 'Main',
                        path: '/main',
                      ),
                    ],
                  ),
                ),
                _MenuDivider.horizontal(),
                Expanded(
                  child: Row(
                    children: [
                      _MenuTile(
                        icon: Icons.event_available_rounded,
                        label: 'Booking',
                        path: '/book',
                      ),
                      _MenuDivider.vertical(),
                      _MenuTile(
                        icon: Icons.location_on_rounded,
                        label: 'Location',
                        path: '/location',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NewsBell extends StatelessWidget {
  const _NewsBell({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '${mmInt(99)}+' : mmInt(count);
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: () => context.push('/news'),
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 46,
          height: 46,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 24),
              ),
              if (count > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      label,
                      style: const TextStyle(color: AppColors.coral, fontSize: 10, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.icon, required this.label, required this.path});

  final IconData icon;
  final String label;
  final String path;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () => context.go(path),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 54, color: AppColors.coral),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class _MenuDivider extends StatelessWidget {
  const _MenuDivider.vertical() : vertical = true;
  const _MenuDivider.horizontal() : vertical = false;

  final bool vertical;

  @override
  Widget build(BuildContext context) {
    if (vertical) {
      return const VerticalDivider(width: 1, thickness: 1, color: AppColors.line);
    }
    return const Divider(height: 1, thickness: 1, color: AppColors.line);
  }
}
