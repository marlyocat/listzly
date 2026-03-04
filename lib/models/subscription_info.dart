import 'package:listzly/models/subscription_tier.dart';

class SubscriptionInfo {
  final SubscriptionTier tier;
  final DateTime? expirationDate;
  final bool willRenew;
  final bool isInTrial;

  const SubscriptionInfo({
    required this.tier,
    this.expirationDate,
    this.willRenew = false,
    this.isInTrial = false,
  });

  bool get isCancelled => tier.isPro && !willRenew;

  static const free = SubscriptionInfo(tier: SubscriptionTier.free);
}
