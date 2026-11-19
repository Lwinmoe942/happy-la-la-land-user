import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import 'widgets.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _again = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
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
      await state.signUp(_email.text, password);
      if (!mounted) {
        return;
      }
      if (state.pendingSignup) {
        context.go('/otp');
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
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => context.go('/login'),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                ),
                const BrandMark(),
                const SizedBox(height: 28),
                Text('အကောင့်ဖွင့်မယ်', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                const Text(
                  'Gmail နဲ့ စကားဝှက်သတ်မှတ်ပါ။ ပြီးရင် Gmail ထဲက ဂဏန်းကုဒ်ကို ထည့်ပါ။ လင့်ခ်ကို နှိပ်စရာ မလိုပါ။',
                  style: TextStyle(color: Color(0xFF6E6258), height: 1.45),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(
                    labelText: 'Gmail',
                    hintText: 'name@gmail.com',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _password,
                  obscureText: true,
                  autofillHints: const [AutofillHints.newPassword],
                  decoration: const InputDecoration(labelText: 'စကားဝှက်'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _again,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'စကားဝှက် နောက်တစ်ကြိမ်'),
                  onSubmitted: (_) => state.busy ? null : _submit(),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: state.busy ? null : _submit,
                  child: Text(state.busy ? 'ဖွင့်နေပါတယ်' : 'အကောင့်ဖွင့်မယ်'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
