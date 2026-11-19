import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/app_exception.dart';

class AppFrame extends StatelessWidget {
  const AppFrame({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth > 480 ? 480.0 : constraints.maxWidth;
        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(width: width, height: constraints.maxHeight, child: child),
        );
      },
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({required this.child, this.padding = const EdgeInsets.all(18), super.key});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.line),
      ),
      child: child,
    );
  }
}

class PageHeader extends StatelessWidget {
  const PageHeader({required this.title, this.subtitle, super.key});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: const TextStyle(color: AppColors.muted, height: 1.4)),
          ],
        ],
      ),
    );
  }
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/logo.png',
          key: const Key('app-logo'),
          width: 280,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 8),
        const Text('ကစားကွင်း', style: TextStyle(color: AppColors.muted)),
      ],
    );
  }
}

void showAppMessage(BuildContext context, Object message) {
  final text = switch (message) {
    AppException(:final message) => message,
    String() => message,
    _ => 'မအောင်မြင်ပါ။ နောက်တစ်ခါ ထပ်ကြိုးစားပါ။',
  };
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}

Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  String cancelLabel = 'မလုပ်တော့ပါ',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(body, style: const TextStyle(height: 1.4)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(cancelLabel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(confirmLabel)),
        ],
      );
    },
  );
  return result ?? false;
}
