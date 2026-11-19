import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../state/app_state.dart';
import 'offers_page.dart';

class OfferDetailPage extends StatelessWidget {
  const OfferDetailPage({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final matches = state.promotions.where((item) => item.id == id);
    final offer = matches.isEmpty ? null : matches.first;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.coral,
        foregroundColor: Colors.white,
        title: const Text('Rewards'),
      ),
      body: offer == null
          ? const Center(child: Text('ဒီပို့စ်ကို ဖျက်ပြီးပါပြီ'))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                AspectRatio(aspectRatio: 1, child: RewardImage(offer: offer, radius: 18)),
                const SizedBox(height: 16),
                Text(offer.title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, height: 1.25)),
                const SizedBox(height: 10),
                Text(offer.body, style: const TextStyle(fontSize: 16, height: 1.5)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    InkWell(
                      onTap: () => context.read<AppState>().toggleLike(offer.id),
                      borderRadius: BorderRadius.circular(24),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                        child: Row(
                          children: [
                            Icon(
                              offer.liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              color: AppColors.coral,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              offer.likeCount > 0 ? mmInt(offer.likeCount) : 'အသဲ',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (mmDaysLeft(offer.endsAt) != null)
                      Text(mmDaysLeft(offer.endsAt)!, style: const TextStyle(color: AppColors.muted)),
                  ],
                ),
              ],
            ),
    );
  }
}
