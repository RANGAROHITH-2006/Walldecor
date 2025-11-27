import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InAppPurchaseService {
  static final InAppPurchaseService _instance = InAppPurchaseService._internal();
  factory InAppPurchaseService() => _instance;
  InAppPurchaseService._internal();

  static const String _baseUrl = 'http://172.168.17.2:13024';

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  
  // Product IDs for subscription plans
  static const String weeklyPlanId = 'test_weekly';
  static const String yearlyPlanId = 'test_yearly';
  
  static const List<String> productIds = [weeklyPlanId, yearlyPlanId];

  List<ProductDetails> _products = [];
  List<ProductDetails> get products => _products;

  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  Function(bool success, String? message)? _purchaseCallback;

  /// Initialize the in-app purchase service
  Future<void> initialize() async {
    try {
      _isAvailable = await _inAppPurchase.isAvailable();
      
      if (!_isAvailable) {
        if (kDebugMode) print('In-app purchases not available');
        return;
      }

      // Start listening to purchase updates
      _subscription = _inAppPurchase.purchaseStream.listen(
        _onPurchaseUpdate,
        onDone: () => _subscription.cancel(),
        onError: (error) {
          if (kDebugMode) print('Purchase stream error: $error');
          _purchaseCallback?.call(false, 'Purchase failed: $error');
        },
      );

      // Load product details
      await _loadProducts();
    } catch (e) {
      if (kDebugMode) print('Error initializing in-app purchases: $e');
    }
  }

  /// Load product details from the store
  Future<void> _loadProducts() async {
    if (!_isAvailable) return;

    try {
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(productIds.toSet());
      
      if (response.notFoundIDs.isNotEmpty) {
        if (kDebugMode) print('Products not found: ${response.notFoundIDs}');
      }

      _products = response.productDetails;
      
      if (kDebugMode) {
        for (var product in _products) {
          print('Product: ${product.id}, Price: ${product.price}');
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error loading products: $e');
    }
  }

  /// Get product details by ID
  ProductDetails? getProductById(String productId) {
    try {
      return _products.firstWhere((product) => product.id == productId);
    } catch (e) {
      return null;
    }
  }

  /// Purchase a product
  Future<void> purchaseProduct(String productId, Function(bool success, String? message) callback) async {
    if (!_isAvailable) {
      callback(false, 'In-app purchases not available');
      return;
    }

    final ProductDetails? product = getProductById(productId);
    if (product == null) {
      callback(false, 'Product not found');
      return;
    }

    _purchaseCallback = callback;

    try {
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      if (kDebugMode) print('Error purchasing product: $e');
      callback(false, 'Purchase failed: $e');
    }
  }

  /// Handle purchase updates
 // Add a Set to track processed purchase IDs
final Set<String> _processedPurchases = {};

void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
  for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
    if (purchaseDetails.status == PurchaseStatus.pending) {
      // Handle pending purchase
      if (kDebugMode) print('Purchase pending');
    } else {
      if (purchaseDetails.status == PurchaseStatus.error) {
        // Handle purchase error
        if (kDebugMode) print('Purchase error: ${purchaseDetails.error}');
        _purchaseCallback?.call(false, purchaseDetails.error?.message ?? 'Purchase failed');
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                 purchaseDetails.status == PurchaseStatus.restored) {
        // Check if the purchase has already been processed
        if (_processedPurchases.contains(purchaseDetails.purchaseID)) {
          if (kDebugMode) print('Duplicate purchase update ignored: ${purchaseDetails.purchaseID}');
          continue;
        }

        // Mark the purchase as processed
        _processedPurchases.add(purchaseDetails.purchaseID ?? '');

        // Handle successful purchase
        if (kDebugMode) print('Purchase successful: ${purchaseDetails.productID}');
        _verifyPurchase(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        // Handle canceled purchase
        if (kDebugMode) print('Purchase canceled');
        _purchaseCallback?.call(false, 'Purchase was canceled');
      }

      // Complete the purchase
      if (purchaseDetails.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }
}

  /// Verify the purchase and send to API
  Future<void> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    try {
      print('-----------------------TTTTTTT----------------------------');
      // Send purchase details to your backend server
      final success = await _sendPurchaseToServer(purchaseDetails);
      
      if (success) {
        _purchaseCallback?.call(true, 'Purchase successful!');
      } else {
        _purchaseCallback?.call(false, 'Purchase verification failed');
      }
    } catch (e) {
      if (kDebugMode) print('Error verifying purchase: $e');
      _purchaseCallback?.call(false, 'Purchase verification failed');
    }
  }

  /// Send purchase data to API
  Future<bool> _sendPurchaseToServer(PurchaseDetails purchaseDetails) async {
    try {
      // Get device information
      final deviceInfo = DeviceInfoPlugin();
      String deviceId = '';
      String appType = '';
      String store = '';
      
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
        appType = 'Android';
        store = 'Google Play';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? 'unknown';
        appType = 'iOS';
        store = 'App Store';
      }

      // Get auth token
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');
      
      if (token == null) {
        if (kDebugMode) print('No auth token found for purchase verification');
        return false;
      }

      // Get product price
      final product = getProductById(purchaseDetails.productID);
      String price = product?.price ?? '0';
      
      // Remove currency symbol and get numeric value
      final priceNumeric = price.replaceAll(RegExp(r'[^0-9.]'), '');
      
      // Determine subscription type
      String subscriptionType = 'WEEKLY';
      if (purchaseDetails.productID == yearlyPlanId) {
        subscriptionType = 'YEARLY';
      }

      // Prepare API body
      final body = {
        'receiptId': purchaseDetails.purchaseID ?? 'unknown',
        'data': base64Encode(utf8.encode(purchaseDetails.verificationData.localVerificationData)),
        'purchase': purchaseDetails.verificationData.serverVerificationData,
        'deviceId': deviceId,
        'appType': appType,
        'price': priceNumeric,
        'store': store,
        'subscriptionType': subscriptionType,
      };

      if (kDebugMode) print('Sending purchase to server: $body');

      // Make API call
      final response = await http.post(
        Uri.parse('$_baseUrl/inApp/purchaseSubscription'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
        body: jsonEncode(body),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        print('-------------------------------------------------------------------');
        if (kDebugMode) print('Purchase verification successful: ${response.body}');
        return true;
      } else {
        if (kDebugMode) {
          print('Purchase verification failed: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) print('Error sending purchase to server: $e');
      return false;
    }
  }

  /// Restore previous purchases
  Future<void> restorePurchases() async {
    if (!_isAvailable) return;

    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      if (kDebugMode) print('Error restoring purchases: $e');
    }
  }

  /// Dispose of the service
  void dispose() {
    _subscription.cancel();
  }
}