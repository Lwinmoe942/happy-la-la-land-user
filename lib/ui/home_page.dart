import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../data/models.dart';
import '../state/app_state.dart';
import 'widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final member = state.member;
    if (member == null) {
      return const SizedBox.shrink();
    }
    return RefreshIndicator(
      color: AppColors.coral,
      onRefresh: () => context.read<AppState>().refresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Text('မင်္ဂလာပါ', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 2),
          Text(member.name, style: const TextStyle(color: AppColors.muted, fontSize: 16)),
          const SizedBox(height: 16),
          _QrCard(member: member),
          const SizedBox(height: 12),
          _StampCard(stamp: state.stamp),
          if (state.loadError != null) ...[
            const SizedBox(height: 12),
            Text(state.loadError!, style: const TextStyle(color: AppColors.coral)),
          ],
          const SizedBox(height: 12),
          _UpcomingCard(booking: state.upcoming),
        ],
      ),
    );
  }
}

class _QrCard extends StatelessWidget {
  const _QrCard({required this.member});

  final Member member;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          const Text('ဆိုင်က ဒီ QR ကို ဖတ်ပါမယ်', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.line),
            ),
            child: QrImageView(
              data: 'HLL1:${member.qrCode}',
              size: 210,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: AppColors.ink),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: AppColors.ink,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            member.qrCode,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 1.2),
          ),
        ],
      ),
    );
  }
}

class _StampCard extends StatelessWidget {
  const _StampCard({required this.stamp});

  final StampStatus stamp;

  @override
  Widget build(BuildContext context) {
    final ready = stamp.rewardReady;
    final left = StampStatus.goal - stamp.filled;
    final caption = ready
        ? 'Free ရပြီ။ နောက်တစ်ခါလာရင် ကလေးတစ်ယောက်စာ မပေးရပါ။'
        : left == StampStatus.goal
        ? '၄ ကြိမ်လာရင် ကလေးတစ်ယောက်စာ free'
        : 'နောက် ${mmInt(left)} ကြိမ်လာရင် free';
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('လာရောက်မှု တံဆိပ်', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
              Text(
                '${mmInt(stamp.filled)} / ${mmInt(StampStatus.goal)}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var index = 0; index < StampStatus.goal; index++)
                Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < stamp.filled
                        ? (ready ? AppColors.teal : AppColors.coral)
                        : Colors.transparent,
                    border: Border.all(
                      color: index < stamp.filled
                          ? (ready ? AppColors.teal : AppColors.coral)
                          : AppColors.line,
                      width: 2,
                    ),
                  ),
                  child: index < stamp.filled
                      ? const Icon(Icons.star_rounded, color: Colors.white, size: 18)
                      : null,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(caption, style: const TextStyle(height: 1.4)),
          const SizedBox(height: 4),
          Text(
            'လာပြီး ${mmInt(stamp.paidVisits)} ကြိမ်',
            style: const TextStyle(color: AppColors.muted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _UpcomingCard extends StatelessWidget {
  const _UpcomingCard({required this.booking});

  final Booking? booking;

  @override
  Widget build(BuildContext context) {
    final current = booking;
    if (current == null) {
      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ကြိုတင်စာရင်း မရှိသေးပါ', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text(
              'နေ့ရက်နဲ့ အချိန်ရွေးပြီး နေရာယူနိုင်ပါတယ်။ ငွေကို ကစားကွင်းရောက်မှ ပေးချေပါမယ်။',
              style: TextStyle(color: AppColors.muted, height: 1.4),
            ),
            const SizedBox(height: 14),
            FilledButton(onPressed: () => context.go('/book'), child: const Text('နေရာယူမယ်')),
          ],
        ),
      );
    }
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('နောက်တစ်ခါ လာမယ့်အချိန်', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(
            '${mmWeekday(current.startsAt)} · ${mmDateTime(current.startsAt)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'ကလေး ${mmInt(current.children)} · လူကြီး ${mmInt(current.adults)} · ဦးရေ ${mmInt(current.people)}',
            style: const TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => _cancel(context, current.id),
            child: const Text('ပယ်ဖျက်မယ်'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancel(BuildContext context, String id) async {
    final ok = await confirmAction(
      context,
      title: 'စာရင်းပယ်ဖျက်မလား',
      body: 'သွားမယ့်အချိန် မတိုင်ခင် ၂ နာရီအလိုအထိ ပယ်ဖျက်လို့ ရပါတယ်။',
      confirmLabel: 'ပယ်ဖျက်မယ်',
    );
    if (!ok || !context.mounted) {
      return;
    }
    try {
      await context.read<AppState>().cancel(id);
      if (context.mounted) {
        showAppMessage(context, 'ပယ်ဖျက်ပြီးပါပြီ');
      }
    } catch (error) {
      if (context.mounted) {
        showAppMessage(context, error);
      }
    }
  }
}
