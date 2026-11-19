import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/config.dart';
import '../data/login_credentials.dart';
import '../state/app_state.dart';
import 'widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  var _remember = true;
  var _obscure = true;
  var _ready = false;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final saved = await LoginCredentials.load();
    if (!mounted) {
      return;
    }
    setState(() {
      _email.text = saved.email;
      _password.text = saved.password;
      _remember = saved.remember;
      _ready = true;
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final state = context.read<AppState>();
    try {
      await state.signInWithPassword(
        _email.text,
        _password.text,
        remember: _remember,
      );
      if (!mounted) {
        return;
      }
      TextInput.finishAutofillContext(shouldSave: _remember);
      final name = state.member?.name.trim() ?? '';
      context.go(name.isEmpty ? '/name' : '/home');
    } catch (error) {
      if (mounted) {
        showAppMessage(context, error);
      }
    }
  }

  Future<void> _forgot() async {
    final state = context.read<AppState>();
    try {
      await state.requestOtp(_email.text);
      if (!mounted) {
        return;
      }
      context.go('/otp');
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
          child: !_ready
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
                  child: AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const BrandMark(),
                        const SizedBox(height: 36),
                        Text('Gmail နဲ့ ဝင်မယ်', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 6),
                        const Text(
                          'တစ်ခါဝင်ပြီးရင် အက်ပ်ပြန်ဖွင့်တိုင်း အလိုအလျောက် ဝင်ထားပါမယ်။ စကားဝှက်ကိုလည်း မှတ်ထားနိုင်ပါတယ်။',
                          style: TextStyle(color: Color(0xFF6E6258), height: 1.45),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.username, AutofillHints.email],
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Gmail',
                            hintText: 'name@gmail.com',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _password,
                          obscureText: _obscure,
                          autofillHints: const [AutofillHints.password],
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            labelText: 'စကားဝှက်',
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => _obscure = !_obscure),
                              icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            ),
                          ),
                          onSubmitted: (_) => state.busy ? null : _signIn(),
                        ),
                        const SizedBox(height: 4),
                        CheckboxListTile(
                          value: _remember,
                          onChanged: state.busy
                              ? null
                              : (value) => setState(() => _remember = value ?? true),
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: const Text('Gmail နဲ့ စကားဝှက် မှတ်ထားမယ်'),
                        ),
                        const SizedBox(height: 8),
                        FilledButton(
                          onPressed: state.busy ? null : _signIn,
                          child: Text(state.busy ? 'ခဏစောင့်ပါ' : 'ဝင်မယ်'),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: state.busy ? null : () => context.go('/signup'),
                          child: const Text('အကောင့်မရှိသေးဘူး။ အကောင့်ဖွင့်မယ်'),
                        ),
                        TextButton(
                          onPressed: state.busy ? null : _forgot,
                          child: Text(state.busy ? 'ပို့နေပါတယ်' : 'စကားဝှက် မေ့သွားပြီ'),
                        ),
                        if (state.demoMode) ...[
                          const SizedBox(height: 20),
                          const _DemoHint(),
                        ],
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _DemoHint extends StatelessWidget {
  const _DemoHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1D2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'စမ်းသပ်အသုံးပြုမှုပါ။ ကုဒ် ${AppConfig.demoOtpCode} နဲ့ ဝင်ပါ။ '
        '${AppConfig.demoSampleEmail} မှာ တံဆိပ် ၃ ခု ရှိပြီးပါပြီ။',
        style: const TextStyle(height: 1.45),
      ),
    );
  }
}
