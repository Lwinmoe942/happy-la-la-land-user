import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/language.dart';
import '../core/theme.dart';
import '../state/app_state.dart';
import 'widgets.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LegalDocPage(
      titleMy: 'ကိုယ်ရေးအချက်အလက် မူဝါဒ',
      titleEn: 'Privacy Policy',
      bodyMy:
          'စုဆောင်းသည် — Gmail၊ မိဘအမည်၊ ကြိုတင်စာရင်း၊ QR/ဆုတံဆိပ်၊ အသိပေးချက်။\n\n'
          'မစုဆောင်းပါ — ကလေးအမည်၊ ဓာတ်ပုံ၊ မွေးနေ့၊ ကျောင်း။\n\n'
          'အသုံးပြုပုံ — ကြိုတင်စာရင်း၊ ဆိုင် QR စာရင်းသွင်းမှု၊ Rewards သတင်း။\n\n'
          'ငွေပေးချေမှု — အက်ပ်ထဲတွင် မရှိပါ။ ကစားကွင်းတွင်သာ ပေးချေသည်။\n\n'
          'ဖျက်ရန်/မေးရန် — happylalaland.mawlamyine@gmail.com · +95 9 44877 7775',
      bodyEn:
          'We collect — Gmail, parent name, bookings, QR/stamp status, optional notifications.\n\n'
          'We do not collect — children’s names, photos, birthdays, or school details.\n\n'
          'We use data for bookings, shop QR check-in, and reward/news alerts.\n\n'
          'Payments — none in the app. Pay only at the playground.\n\n'
          'Delete/ask — happylalaland.mawlamyine@gmail.com · +95 9 44877 7775',
    );
  }
}

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LegalDocPage(
      titleMy: 'အသုံးပြုခြင်းဆိုင်ရာ စည်းကမ်း',
      titleEn: 'Terms of Use',
      bodyMy:
          'ဤအက်ပ်သည် HAPPY LA LA LAND မိဘအသုံးပြုသူများအတွက် ဖြစ်သည်။\n\n'
          '• Gmail တစ်ခုဖြင့်သာ အကောင့်ဖွင့် / ဝင်ရောက်ရမည်\n'
          '• ကြိုတင်စာရင်းသည် နေရာလစ်သည့်အတိုင်းသာ ရရှိသည်\n'
          '• ဆိုင်တွင် QR ပြမှ တံဆိပ်နှင့် ဝင်ငွေစာရင်း တက်သည်\n'
          '• ငွေပေးချေမှုကို အက်ပ်ထဲတွင် မလုပ်ပါ — ကစားကွင်းတွင်သာ\n'
          '• မသင့်လျော်သော အသုံးပြုမှုကို ဆိုင်က ရပ်ဆိုင်းနိုင်သည်\n\n'
          'ဆက်သွယ်ရန် — happylalaland.mawlamyine@gmail.com · +95 9 44877 7775',
      bodyEn:
          'This app is for HAPPY LA LA LAND parents/guardians.\n\n'
          '• Sign up / sign in with a Gmail address only\n'
          '• Bookings depend on available capacity\n'
          '• Stamps and visits are recorded when the shop scans your QR\n'
          '• No in-app payments — pay at the playground only\n'
          '• The shop may suspend misuse of the service\n\n'
          'Contact — happylalaland.mawlamyine@gmail.com · +95 9 44877 7775',
    );
  }
}

class ContentPolicyPage extends StatelessWidget {
  const ContentPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LegalDocPage(
      titleMy: 'အကြောင်းအရာ မူဝါဒ',
      titleEn: 'Content Policy',
      bodyMy:
          'ဤအက်ပ်သည် မိဘများအတွက် ဖြစ်ပြီး ကလေးအကောင့် မဖွင့်ပါ။\n\n'
          '• Rewards / သတင်းသည် ဆိုင်က တင်သော မိသားစုနှင့် သင့်တော်သော အကြောင်းအရာသာ\n'
          '• အကြမ်းဖက်မှု၊ လိင်ပိုင်း၊ အမုန်းစကား၊ တရားမဝင် အကြောင်းအရာ မတင်ပါ\n'
          '• အသုံးပြုသူက အများပြည်သူထံ စာမတင်နိုင်ပါ\n'
          '• မသင့်လျော်သော အကြောင်းအရာ တွေ့ရင် Customer Service သို့ အကြောင်းကြားပါ\n\n'
          'Target audience — parents/guardians (18+)\n'
          'Child personal data — not collected',
      bodyEn:
          'This app is for parents/guardians. Children do not create accounts.\n\n'
          '• Rewards/news are shop-published family-friendly posts only\n'
          '• No violence, sexual, hateful, or illegal content\n'
          '• Users cannot post public content in the app\n'
          '• Report issues via Customer Service\n\n'
          'Target audience — parents/guardians (18+)\n'
          'Child personal data — not collected',
    );
  }
}

class AccountDeletionPage extends StatelessWidget {
  const AccountDeletionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.watch<AppLanguage>();
    final state = context.watch<AppState>();
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.coral,
        foregroundColor: Colors.white,
        title: Text(tr(language, 'အကောင့်ဖျက်မယ်', 'Delete Account')),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        children: [
          AppCard(
            child: Text(
              tr(
                language,
                'အကောင့်ဖျက်လိုက်ရင် Gmail အကောင့်ချိတ်ဆက်မှု၊ ကြိုတင်စာရင်း၊ QR/ဆုတံဆိပ် နှင့် လာရောက်မှုစာရင်းကို ဖျက်ပါမယ်။ ပြန်မရနိုင်ပါ။\n\n'
                'အက်ပ်မရှိတော့ရင်လည်း အီးမေးလ်ပို့ပြီး တောင်းဆိုနိုင်သည် — happylalaland.mawlamyine@gmail.com\n'
                'အကြောင်းအရာတွင် “Delete HAPPY LA LA LAND account” နှင့် သင့် Gmail ထည့်ပေးပါ။ ရက်အနည်းငယ်အတွင်း ဆောင်ရွက်ပေးပါမယ်။',
                'Deleting your account removes your Gmail login link, bookings, QR/stamp progress, and visit history. This cannot be undone.\n\n'
                'If you already uninstalled the app, email happylalaland.mawlamyine@gmail.com with subject “Delete HAPPY LA LA LAND account” and your Gmail. We process requests within a few days.',
              ),
              style: const TextStyle(height: 1.5),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.coral),
            onPressed: state.busy ? null : () => _confirmDelete(context, language),
            child: Text(tr(language, 'အကောင့်ကို အပြီးဖျက်မယ်', 'Delete my account permanently')),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, AppLanguage language) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr(language, 'အကောင့်ဖျက်မလား', 'Delete account?')),
        content: Text(
          tr(
            language,
            'ဤလုပ်ဆောင်ချက်ကို ပြန်မရနိုင်ပါ။',
            'This action cannot be undone.',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(tr(language, 'မလုပ်ပါ', 'Cancel'))),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(tr(language, 'ဖျက်မယ်', 'Delete'), style: const TextStyle(color: AppColors.coral)),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) {
      return;
    }
    try {
      await context.read<AppState>().deleteAccount();
      if (!context.mounted) {
        return;
      }
      context.go('/login');
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }
}

class _LegalDocPage extends StatelessWidget {
  const _LegalDocPage({
    required this.titleMy,
    required this.titleEn,
    required this.bodyMy,
    required this.bodyEn,
  });

  final String titleMy;
  final String titleEn;
  final String bodyMy;
  final String bodyEn;

  @override
  Widget build(BuildContext context) {
    final language = context.watch<AppLanguage>();
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.coral,
        foregroundColor: Colors.white,
        title: Text(tr(language, titleMy, titleEn)),
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(tr(language, bodyMy, bodyEn), style: const TextStyle(height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
