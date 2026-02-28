import 'package:listzly/models/subscription_tier.dart';

class SubscriptionInfo {
  final SubscriptionTier tier;
  final DateTime? expirationDate;
  final bool willRenew;
  final bool isInTrial;
  final String? managementURL;

  const SubscriptionInfo({
    required this.tier,
    this.expirationDate,
    this.willRenew = false,
    this.isInTrial = false,
    this.managementURL,
  });

  bool get isCancelled => tier.isPro && !willRenew;
  bool get isActive => tier.isPro;

  static const free = SubscriptionInfo(tier: SubscriptionTier.free);
}
