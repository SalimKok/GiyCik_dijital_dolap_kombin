import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService {
  static const String _googleApiKey = 'goog_rqqfScWMysqBdwuDIZqNLkJFZmP';

  // Aboneliğinizin RevenueCat'te oluşturduğunuz entitlement (yetki) id'si. Genelde "pro" veya "premium" yapılır.
  static const String entitlementId = 'pro';

  static Future<void> initialize() async {
    if (kIsWeb) return;

    if (kDebugMode) {
      await Purchases.setLogLevel(LogLevel.debug);
    } else {
      await Purchases.setLogLevel(LogLevel.warn);
    }

    PurchasesConfiguration? configuration;
    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(_googleApiKey);
    }

    if (configuration != null) {
      await Purchases.configure(configuration);
    }
  }

  static Future<Offerings?> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      return offerings;
    } catch (e) {
      debugPrint("Error fetching offerings: $e");
      return null;
    }
  }

  static Future<bool> purchasePackage(Package package) async {
    try {
      final purchaseResult = await Purchases.purchasePackage(package);
      return purchaseResult.customerInfo.entitlements.all[entitlementId]?.isActive == true;
    } catch (e) {
      debugPrint("Error purchasing package: $e");
      return false;
    }
  }

  static Future<bool> restorePurchases() async {
    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      return customerInfo.entitlements.all[entitlementId]?.isActive == true;
    } catch (e) {
      debugPrint("Error restoring purchases: $e");
      return false;
    }
  }

  static Future<bool> checkProStatus() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all[entitlementId]?.isActive == true;
    } catch (e) {
      debugPrint("Error checking pro status: $e");
      return false;
    }
  }
}
