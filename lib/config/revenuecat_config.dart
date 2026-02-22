import 'dart:io';

const String _revenueCatAppleApiKey = 'appl_XXXXX';
const String _revenueCatGoogleApiKey = 'goog_qgOlVdiKfQXELMhRPWxstycYtmK';

/// Entitlement identifier configured in RevenueCat dashboard.
const String entitlementPro = 'pro';

String get revenueCatApiKey {
  if (Platform.isIOS || Platform.isMacOS) return _revenueCatAppleApiKey;
  return _revenueCatGoogleApiKey;
}
