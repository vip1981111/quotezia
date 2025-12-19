import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../core/constants/app_strings.dart';
import 'storage_service.dart';

class PremiumService {
  static final PremiumService _instance = PremiumService._internal();
  factory PremiumService() => _instance;
  PremiumService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool _isPremium = false;
  bool _isAvailable = false;
  List<ProductDetails> _products = [];
  bool _isLoading = false;

  bool get isPremium => _isPremium;
  bool get isAvailable => _isAvailable;
  List<ProductDetails> get products => _products;
  bool get isLoading => _isLoading;

  StorageService? _storageService;

  final _premiumStatusController = StreamController<bool>.broadcast();
  Stream<bool> get premiumStatusStream => _premiumStatusController.stream;

  Future<void> initialize(StorageService storageService) async {
    _storageService = storageService;

    // Load saved premium status
    _isPremium = _storageService?.getBool(AppStrings.isPremiumKey) ?? false;
    _premiumStatusController.add(_isPremium);

    // Only initialize IAP on mobile platforms
    if (!Platform.isAndroid && !Platform.isIOS) {
      debugPrint('PremiumService: IAP not supported on this platform');
      return;
    }

    _isAvailable = await _inAppPurchase.isAvailable();
    debugPrint('PremiumService: IAP available: $_isAvailable');

    if (!_isAvailable) return;

    // Listen to purchase updates
    _subscription = _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (error) => debugPrint('PremiumService: Purchase stream error: $error'),
    );

    // Load products
    await loadProducts();
  }

  Future<void> loadProducts() async {
    if (!_isAvailable) return;

    _isLoading = true;

    const productIds = <String>{
      AppStrings.premiumMonthlyId,
      AppStrings.premiumYearlyId,
      AppStrings.premiumLifetimeId,
    };

    try {
      final response = await _inAppPurchase.queryProductDetails(productIds);

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('PremiumService: Products not found: ${response.notFoundIDs}');
      }

      _products = response.productDetails;
      debugPrint('PremiumService: Loaded ${_products.length} products');
    } catch (e) {
      debugPrint('PremiumService: Error loading products: $e');
    }

    _isLoading = false;
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchaseDetails in purchaseDetailsList) {
      debugPrint('PremiumService: Purchase update - ${purchaseDetails.productID}: ${purchaseDetails.status}');

      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Show loading indicator
        _isLoading = true;
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          debugPrint('PremiumService: Purchase error: ${purchaseDetails.error}');
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          // Verify and deliver the product
          _verifyAndDeliverProduct(purchaseDetails);
        }

        if (purchaseDetails.pendingCompletePurchase) {
          _inAppPurchase.completePurchase(purchaseDetails);
        }

        _isLoading = false;
      }
    }
  }

  Future<void> _verifyAndDeliverProduct(PurchaseDetails purchaseDetails) async {
    // In a real app, you would verify the purchase with your backend server
    // For now, we'll just grant premium access

    debugPrint('PremiumService: Verifying purchase: ${purchaseDetails.productID}');

    // Grant premium access
    await setPremiumStatus(true);
    debugPrint('PremiumService: Premium access granted!');
  }

  Future<bool> purchaseProduct(ProductDetails product) async {
    if (!_isAvailable) {
      debugPrint('PremiumService: IAP not available');
      return false;
    }

    final purchaseParam = PurchaseParam(productDetails: product);

    try {
      // For subscriptions
      if (product.id == AppStrings.premiumMonthlyId ||
          product.id == AppStrings.premiumYearlyId) {
        return await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      }

      // For lifetime (non-consumable)
      return await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      debugPrint('PremiumService: Purchase error: $e');
      return false;
    }
  }

  Future<void> restorePurchases() async {
    if (!_isAvailable) {
      debugPrint('PremiumService: IAP not available');
      return;
    }

    try {
      await _inAppPurchase.restorePurchases();
      debugPrint('PremiumService: Restore purchases initiated');
    } catch (e) {
      debugPrint('PremiumService: Restore error: $e');
    }
  }

  Future<void> setPremiumStatus(bool value) async {
    _isPremium = value;
    await _storageService?.setBool(AppStrings.isPremiumKey, value);
    _premiumStatusController.add(_isPremium);
    debugPrint('PremiumService: Premium status set to: $value');
  }

  // For testing purposes - simulate a purchase
  Future<void> simulatePurchase() async {
    debugPrint('PremiumService: Simulating purchase...');
    await Future.delayed(const Duration(seconds: 1));
    await setPremiumStatus(true);
  }

  void dispose() {
    _subscription?.cancel();
    _premiumStatusController.close();
  }
}
