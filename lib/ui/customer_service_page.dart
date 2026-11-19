import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/language.dart';
import '../core/theme.dart';
import 'widgets.dart';

class CustomerServicePage extends StatelessWidget {
  const CustomerServicePage({super.key});

  static const phone = '+95 9 44877 7775';
  static const email = 'happylalaland.mawlamyine@gmail.com';
  static const address =
      'No 117 Upper Main Road, Mawlamyine, Myanmar (Burma), Mawlamyine, Myanmar, 12012';

  @override
  Widget build(BuildContext context) {
    final language = context.watch<AppLanguage>();
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.coral,
        foregroundColor: Colors.white,
        title: const Text('Customer Service'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _ContactCard(
            icon: Icons.phone_rounded,
            title: 'HAPPY LA LA LAND Hotline Phone Number',
            value: phone,
            onTap: () => _open(context, Uri.parse('tel:+959448777775'), language),
          ),
          const SizedBox(height: 12),
          _ContactCard(
            icon: Icons.mail_rounded,
            title: 'HAPPY LA LA LAND Customer Support Email',
            value: email,
            onTap: () => _open(context, Uri.parse('mailto:$email'), language),
          ),
          const SizedBox(height: 12),
          _ContactCard(
            icon: Icons.location_on_rounded,
            title: 'Address',
            value: address,
            onTap: () => context.push('/location'),
          ),
        ],
      ),
    );
  }

  Future<void> _open(BuildContext context, Uri uri, AppLanguage language) async {
    final opened = await launchUrl(uri);
    if (!opened && context.mounted) {
      showAppMessage(context, tr(language, 'ဖွင့်လို့ မရပါ', 'Could not open'));
    }
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(color: AppColors.coral, shape: BoxShape.circle),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: AppColors.muted, height: 1.3)),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        color: AppColors.coral,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
