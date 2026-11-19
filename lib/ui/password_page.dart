import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import 'widgets.dart';

class PasswordPage extends StatefulWidget {
  const PasswordPage({super.key});

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final _password = TextEditingController();
  final _again = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    _again.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final password = _password.text;
    if (password.length < 8) {
      showAppMessage(context, 'စကားဝှက်ကို အနည်းဆုံး ၈ လုံး ထားပါ');
      return;
    }
    if (password != _again.text) {
      showAppMessage(context, 'စကားဝှက် နှစ်ခု မတူပါ');
      return;
    }
    final state = context.read<AppState>();
    try {
      await state.setPassword(password);
      if (!mounted) {
        return;
      }
      final name = state.member?.name.trim() ?? '';
      context.go(name.isEmpty ? '/name' : '/home');
    } catch (error) {
      if (mounted) {
        showAppMessage(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      body: SafeArea(
        child: AppFrame(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('စကားဝှက် သတ်မှတ်ပါ', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                const Text(
                  'တစ်ခါသတ်မှတ်ပြီးရင် ကုဒ် ထပ်မတောင်းတော့ပါ။ နောက်တစ်ခါ ဒီစကားဝှက်နဲ့ ဝင်ပါ။ အကောင့်ကို ဖုန်းထဲမှာ မှတ်ထားပါမယ်။',
                  style: TextStyle(color: Color(0xFF6E6258), height: 1.4),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _password,
                  autofocus: true,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'စကားဝှက်'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _again,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'နောက်တစ်ကြိမ် ထည့်ပါ'),
                  onSubmitted: (_) => state.busy ? null : _submit(),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: state.busy ? null : _submit,
                  child: Text(state.busy ? 'သိမ်းနေပါတယ်' : 'သိမ်းမယ်'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
