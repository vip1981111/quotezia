import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../services/premium_service.dart';

class PremiumProvider extends ChangeNotifier {
  final PremiumService _premiumService;
  StreamSubscription<bool>? _subscription;

  bool _isPremium = false;
  bool _isLoading = false;
  List<ProductDetails> _products = [];

  PremiumProvider(this._premiumService) {
    _isPremium = _premiumService.isPremium;
    _products = _premiumService.products;

    // Listen to premium status changes
    _subscription = _premiumService.premiumStatusStream.listen((isPremium) {
      _isPremium = isPremium;
      notifyListeners();
    });
  }

  bool get isPremium => _isPremium;
  bool get isLoading => _isLoading || _premiumService.isLoading;
  bool get isAvailable => _premiumService.isAvailable;
  List<ProductDetails> get products => _products;

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    await _premiumService.loadProducts();
    _products = _premiumService.products;

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> purchaseProduct(ProductDetails product) async {
    _isLoading = true;
    notifyListeners();

    final result = await _premiumService.purchaseProduct(product);

    _isLoading = false;
    notifyListeners();

    return result;
  }

  Future<void> restorePurchases() async {
    _isLoading = true;
    notifyListeners();

    await _premiumService.restorePurchases();

    _isLoading = false;
    notifyListeners();
  }

  // For testing - simulate purchase
  Future<void> simulatePurchase() async {
    _isLoading = true;
    notifyListeners();

    await _premiumService.simulatePurchase();

    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
