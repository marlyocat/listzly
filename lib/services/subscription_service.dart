import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:listzly/config/revenuecat_config.dart';
import 'package:listzly/models/subscription_info.dart';
import 'package:listzly/models/subscription_tier.dart';

class SubscriptionService {
  bool _initialized = false;

  Future<void> init({required String userId}) async {
    if (_initialized) return;

    await Purchases.configure(
      PurchasesConfiguration(revenueCatApiKey)..appUserID = userId,
    );
    _initialized = true;
  }

  /// Current subscription tier based on active entitlements.
  Future<SubscriptionTier> getCurrentTier() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return _tierFromEntitlements(customerInfo);
    } catch (e) {
      debugPrint('SubscriptionService.getCurrentTier error: $e');
      return SubscriptionTier.free;
    }
  }

  /// Fetch available offerings for the paywall.
  Future<Offerings> getOfferings() async {
    return Purchases.getOfferings();
  }

  /// Purchase a package.
  Future<SubscriptionTier> purchase(Package package) async {
    final result = await Purchases.purchase(PurchaseParams.package(package));
    return _tierFromEntitlements(result.customerInfo);
  }

  /// Restore previous purchases.
  Future<SubscriptionTier> restorePurchases() async {
    final customerInfo = await Purchases.restorePurchases();
    return _tierFromEntitlements(customerInfo);
  }

  /// Full subscription details including expiration and renewal status.
  Future<SubscriptionInfo> getSubscriptionInfo() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final tier = _tierFromEntitlements(customerInfo);
      if (tier.isFree) return SubscriptionInfo.free;

      final entitlement = customerInfo.entitlements.active[entitlementPro]!;
      DateTime? expirationDate;
      if (entitlement.expirationDate != null) {
        expirationDate = DateTime.tryParse(entitlement.expirationDate!);
      }

      return SubscriptionInfo(
        tier: tier,
        expirationDate: expirationDate,
        willRenew: entitlement.willRenew,
        isInTrial: entitlement.periodType == PeriodType.trial,
        managementURL: customerInfo.managementURL,
      );
    } catch (e) {
      debugPrint('SubscriptionService.getSubscriptionInfo error: $e');
      return SubscriptionInfo.free;
    }
  }

  /// Stream that emits whenever the subscription status changes.
  Stream<SubscriptionTier> get onTierChanged {
    final controller = StreamController<SubscriptionTier>.broadcast();
    Purchases.addCustomerInfoUpdateListener((info) {
      controller.add(_tierFromEntitlements(info));
    });
    return controller.stream;
  }

  SubscriptionTier _tierFromEntitlements(CustomerInfo info) {
    final proEntitlement = info.entitlements.active[entitlementPro];
    if (proEntitlement == null) return SubscriptionTier.free;

    final productId = proEntitlement.productIdentifier;
    if (productId == productTeacherPremiumMonthly) {
      return SubscriptionTier.teacherPremium;
    }
    if (productId == productTeacherProMonthly) {
      return SubscriptionTier.teacherPro;
    }
    if (productId == productTeacherLiteMonthly) {
      return SubscriptionTier.teacherLite;
    }
    return SubscriptionTier.pro;
  }
}
