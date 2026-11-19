import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../data/models.dart';
import '../state/app_state.dart';
import 'widgets.dart';

class OffersPage extends StatelessWidget {
  const OffersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final offers = state.promotions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PageHeader(title: 'Rewards'),
        Expanded(
          child: RefreshIndicator(
            color: AppColors.coral,
            onRefresh: () => context.read<AppState>().refresh(),
            child: offers.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 80),
                      Center(child: Text('လျှော့ဈေး မရှိသေးပါ')),
                    ],
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: offers.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => _RewardCard(offer: offers[index]),
                  ),
          ),
        ),
      ],
    );
  }
}

class RewardImage extends StatelessWidget {
  const RewardImage({required this.offer, this.radius = 12, super.key});

  final Promotion offer;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final child = offer.imageAsset != null
        ? Image.asset(offer.imageAsset!, fit: BoxFit.cover)
        : offer.imageUrl != null
        ? Image.network(
            offer.imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stack) => const ColoredBox(
              color: AppColors.coralSoft,
              child: Icon(Icons.campaign_rounded, color: AppColors.coral, size: 36),
            ),
          )
        : const ColoredBox(
            color: AppColors.coralSoft,
            child: Icon(Icons.campaign_rounded, color: AppColors.coral, size: 36),
          );
    return ClipRRect(borderRadius: BorderRadius.circular(radius), child: child);
  }
}

class _RewardCard extends StatelessWidget {
  const _RewardCard({required this.offer});

  final Promotion offer;

  @override
  Widget build(BuildContext context) {
    final expiry = mmDaysLeft(offer.endsAt);
    final preview = offer.body.replaceAll('\n', ' ');
    return AppCard(
      padding: const EdgeInsets.all(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.push('/offer/${offer.id}'),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 108, height: 108, child: RewardImage(offer: offer)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          offer.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, height: 1.25),
                        ),
                      ),
                      _HeartButton(offer: offer),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    preview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.muted, height: 1.35),
                  ),
                  if (expiry != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.campaign_rounded, size: 16, color: AppColors.muted),
                        const Spacer(),
                        Text(expiry, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeartButton extends StatelessWidget {
  const _HeartButton({required this.offer});

  final Promotion offer;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.read<AppState>().toggleLike(offer.id),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.only(left: 6, bottom: 4),
        child: Column(
          children: [
            Icon(
              offer.liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: AppColors.coral,
              size: 22,
            ),
            if (offer.likeCount > 0)
              Text(mmInt(offer.likeCount), style: const TextStyle(fontSize: 11, color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}
