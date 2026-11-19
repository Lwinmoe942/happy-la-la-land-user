import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import 'widgets.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final state = context.read<AppState>();
    try {
      await state.verifyOtp(_code.text);
      if (!mounted) {
        return;
      }
      if (!state.passwordReady) {
        context.go('/password');
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

  Future<void> _resend() async {
    final email = context.read<AppState>().pendingEmail;
    if (email == null) {
      context.go('/login');
      return;
    }
    try {
      await context.read<AppState>().requestOtp(
        email,
        signup: context.read<AppState>().pendingSignup,
      );
      if (mounted) {
        showAppMessage(context, 'ကုဒ် အသစ်ပို့ပြီးပါပြီ');
      }
    } catch (error) {
      if (mounted) {
        showAppMessage(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final shown = state.pendingEmail ?? '';
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
                    onPressed: () => context.go(state.pendingSignup ? '/signup' : '/login'),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  state.pendingSignup ? 'အကောင့်ဖွင့်ဖို့ ကုဒ်ထည့်ပါ' : 'ကုဒ်ထည့်ပါ',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  shown.isEmpty
                      ? 'Gmail ကို ပြန်ထည့်ပါ'
                      : '$shown ဆီ ပို့ထားပါတယ်။ နောက်ဆုံးစာထဲက ဂဏန်းကို ထည့်ပါ။ လင့်ခ်ကို နှိပ်စရာ မလိုပါ။',
                  style: const TextStyle(color: Color(0xFF6E6258), height: 1.4),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _code,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 8,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(fontSize: 28, letterSpacing: 4, fontWeight: FontWeight.w800),
                  decoration: const InputDecoration(counterText: '', hintText: 'ဂဏန်းကုဒ်'),
                  onSubmitted: (_) => state.busy ? null : _submit(),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: state.busy ? null : _submit,
                  child: Text(state.busy ? 'စစ်နေပါတယ်' : 'အတည်ပြုမယ်'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: state.busy ? null : _resend,
                  child: const Text('ကုဒ် ပြန်ပို့မယ်'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
