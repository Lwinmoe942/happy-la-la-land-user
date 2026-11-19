import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import 'widgets.dart';

class NamePage extends StatefulWidget {
  const NamePage({super.key});

  @override
  State<NamePage> createState() => _NamePageState();
}

class _NamePageState extends State<NamePage> {
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      showAppMessage(context, 'နာမည် ထည့်ပါ');
      return;
    }
    if (name.length > 40) {
      showAppMessage(context, 'နာမည် တိုအောင် ထည့်ပါ');
      return;
    }
    try {
      await context.read<AppState>().saveName(name);
      if (mounted) {
        context.go('/home');
      }
    } catch (error) {
      if (mounted) {
        showAppMessage(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.watch<AppState>().busy;
    return Scaffold(
      body: SafeArea(
        child: AppFrame(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('နာမည်ကို ဘယ်လို ခေါ်ရမလဲ', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                const Text(
                  'ဆိုင်က QR ဖတ်တဲ့အခါ ဒီနာမည်ကို ပြပါမယ်။',
                  style: TextStyle(color: Color(0xFF6E6258), height: 1.4),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _name,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(labelText: 'နာမည်', hintText: 'မမလှ'),
                  onSubmitted: (_) => busy ? null : _submit(),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: busy ? null : _submit,
                  child: Text(busy ? 'သိမ်းနေပါတယ်' : 'ဆက်လုပ်မယ်'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
