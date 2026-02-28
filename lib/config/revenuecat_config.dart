import 'dart:io';

const String _revenueCatAppleApiKey = 'appl_XXXXX';
const String _revenueCatGoogleApiKey = 'goog_qgOlVdiKfQXELMhRPWxstycYtmK';

/// Entitlement identifier configured in RevenueCat dashboard.
const String entitlementPro = 'pro';

/// Product identifiers configured in RevenueCat dashboard.
const String productProYearly = 'personal_pro_yearly';
const String productTeacherLiteMonthly = 'teacher_lite_monthly';
const String productTeacherProMonthly = 'teacher_pro_monthly';
const String productTeacherPremiumMonthly = 'teacher_premium_monthly';

String get revenueCatApiKey {
  if (Platform.isIOS || Platform.isMacOS) return _revenueCatAppleApiKey;
  return _revenueCatGoogleApiKey;
}
