import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/language.dart';
import '../core/theme.dart';
import 'widgets.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.watch<AppLanguage>();
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.coral,
        foregroundColor: Colors.white,
        title: Text(tr(language, 'About App', 'About App')),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'HAPPY LA LA LAND',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  tr(language, 'မိဘအက်ပ် · ဗားရှင်း ၁.၀.၆', 'Parent app · version 1.0.6'),
                  style: const TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 12),
                Text(
                  tr(
                    language,
                    'Gmail နဲ့ အကောင့်ဖွင့်ပြီး QR ပြပါ။ ဆိုင်က ဖတ်မှ တံဆိပ်တက်ပါတယ်။ ၄ ကြိမ်လာရင် နောက်တစ်ကြိမ် ကလေးတစ်ယောက် အခမဲ့ပါ။ ကြိုတင်စာရင်းယူပြီး ဆိုင်ရောက်မှ ပေးချေပါ။ အက်ပ်ထဲတွင် ငွေပေးချေမှု မရှိပါ။',
                    'Sign in with Gmail and show your QR code. A stamp is added only when the shop scans it. After 4 paid visits, one child is free next time. Book ahead and pay at the playground. There are no in-app payments.',
                  ),
                  style: const TextStyle(height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 4),
                  child: Text(
                    tr(language, 'မူဝါဒနှင့် စည်းကမ်း', 'Policies'),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                _LinkRow(
                  icon: Icons.privacy_tip_outlined,
                  label: tr(language, 'ကိုယ်ရေးအချက်အလက် မူဝါဒ', 'Privacy Policy'),
                  onTap: () => context.push('/privacy'),
                ),
                _LinkRow(
                  icon: Icons.description_outlined,
                  label: tr(language, 'အသုံးပြုခြင်းဆိုင်ရာ စည်းကမ်း', 'Terms of Use'),
                  onTap: () => context.push('/terms'),
                ),
                _LinkRow(
                  icon: Icons.policy_outlined,
                  label: tr(language, 'အကြောင်းအရာ မူဝါဒ', 'Content Policy'),
                  onTap: () => context.push('/content-policy'),
                ),
                _LinkRow(
                  icon: Icons.person_off_outlined,
                  label: tr(language, 'အကောင့်ဖျက်ခြင်း', 'Account Deletion'),
                  onTap: () => context.push('/delete-account'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.coral),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
