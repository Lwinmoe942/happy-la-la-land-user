import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/language.dart';
import '../core/theme.dart';
import '../state/app_state.dart';
import 'widgets.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final language = context.watch<AppLanguage>();
    final member = state.member;
    if (member == null) {
      return const SizedBox.shrink();
    }
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Container(
          width: double.infinity,
          color: AppColors.coral,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
          child: Text(
            tr(language, 'အကောင့်', 'Account'),
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 18),
        const Icon(Icons.account_circle, size: 84, color: AppColors.coral),
        const SizedBox(height: 6),
        Text(
          member.name,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        Text(member.email, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted)),
        const SizedBox(height: 8),
        Center(
          child: OutlinedButton(
            onPressed: () => _rename(context, member.name, language),
            child: Text(tr(language, 'နာမည်ပြင်မယ်', 'Edit')),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: AppCard(
            child: _MenuRow(
              icon: Icons.language_rounded,
              label: 'Language',
              trailing: tr(language, 'မြန်မာ', 'English'),
              onTap: () => _chooseLanguage(context, language),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: AppCard(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(18, 8, 18, 4),
                  child: Text('Account Management', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
                _MenuRow(
                  icon: Icons.lock_rounded,
                  label: tr(language, 'စကားဝှက်ပြောင်းမယ်', 'Change password'),
                  onTap: state.busy ? null : () => _changePassword(context, language),
                ),
                _MenuRow(
                  icon: Icons.logout_rounded,
                  label: tr(language, 'ထွက်မယ်', 'Sign out'),
                  onTap: state.busy ? null : () => _signOut(context, language),
                ),
                _MenuRow(
                  icon: Icons.person_off_outlined,
                  label: tr(language, 'အကောင့်ဖျက်မယ်', 'Delete account'),
                  onTap: state.busy ? null : () => context.push('/delete-account'),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: AppCard(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(18, 8, 18, 4),
                  child: Text('Help', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
                _MenuRow(
                  icon: Icons.support_agent_rounded,
                  label: 'Customer Service',
                  onTap: () => context.push('/service'),
                ),
                _MenuRow(
                  icon: Icons.info_outline_rounded,
                  label: 'About App',
                  onTap: () => context.push('/about'),
                ),
                const _MenuRow(
                  icon: Icons.sell_outlined,
                  label: 'Version',
                  trailing: '1.0.6',
                  chevron: false,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _chooseLanguage(BuildContext context, AppLanguage language) async {
    final picked = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Language'),
          children: [
            SimpleDialogOption(onPressed: () => Navigator.pop(context, 'my'), child: const Text('မြန်မာ')),
            SimpleDialogOption(onPressed: () => Navigator.pop(context, 'en'), child: const Text('English')),
          ],
        );
      },
    );
    if (picked != null) {
      await language.use(picked);
    }
  }

  Future<void> _changePassword(BuildContext context, AppLanguage language) async {
    final password = TextEditingController();
    final again = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(tr(language, 'စကားဝှက်ပြောင်းမယ်', 'Change password')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: password,
                obscureText: true,
                decoration: InputDecoration(labelText: tr(language, 'စကားဝှက်အသစ်', 'New password')),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: again,
                obscureText: true,
                decoration: InputDecoration(labelText: tr(language, 'နောက်တစ်ကြိမ်', 'Again')),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(tr(language, 'မလုပ်တော့ပါ', 'Cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(tr(language, 'သိမ်းမယ်', 'Save')),
            ),
          ],
        );
      },
    );
    final next = password.text;
    final repeat = again.text;
    password.dispose();
    again.dispose();
    if (saved != true || !context.mounted) {
      return;
    }
    if (next.length < 8) {
      showAppMessage(context, tr(language, 'စကားဝှက်ကို အနည်းဆုံး ၈ လုံး ထားပါ', 'Use at least 8 characters'));
      return;
    }
    if (next != repeat) {
      showAppMessage(context, tr(language, 'စကားဝှက် နှစ်ခု မတူပါ', 'The passwords do not match'));
      return;
    }
    try {
      await context.read<AppState>().setPassword(next);
      if (context.mounted) {
        showAppMessage(context, tr(language, 'စကားဝှက် ပြောင်းပြီးပါပြီ', 'Password updated'));
      }
    } catch (error) {
      if (context.mounted) {
        showAppMessage(context, error);
      }
    }
  }

  Future<void> _rename(BuildContext context, String current, AppLanguage language) async {
    final controller = TextEditingController(text: current);
    final name = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(tr(language, 'နာမည်ပြင်မယ်', 'Edit name')),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(labelText: tr(language, 'နာမည်', 'Name')),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(tr(language, 'မလုပ်တော့ပါ', 'Cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: Text(tr(language, 'သိမ်းမယ်', 'Save')),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (name == null || name.isEmpty || !context.mounted) {
      return;
    }
    try {
      await context.read<AppState>().saveName(name);
    } catch (error) {
      if (context.mounted) {
        showAppMessage(context, error);
      }
    }
  }

  Future<void> _signOut(BuildContext context, AppLanguage language) async {
    final ok = await confirmAction(
      context,
      title: tr(language, 'အကောင့်က ထွက်မလား', 'Sign out?'),
      body: tr(
        language,
        'QR ပြန်ကြည့်ချင်ရင် ဒီ Gmail နဲ့ ပြန်ဝင်ပါ။',
        'Sign in again with this Gmail to see your QR code.',
      ),
      confirmLabel: tr(language, 'ထွက်မယ်', 'Sign out'),
      cancelLabel: tr(language, 'မလုပ်တော့ပါ', 'Cancel'),
    );
    if (!ok || !context.mounted) {
      return;
    }
    await context.read<AppState>().signOut();
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    this.onTap,
    this.trailing,
    this.chevron = true,
  });

  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback? onTap;
  final bool chevron;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.ink),
      title: Text(label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null) Text(trailing!, style: const TextStyle(color: AppColors.muted)),
          if (chevron) const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
        ],
      ),
      onTap: onTap,
    );
  }
}
