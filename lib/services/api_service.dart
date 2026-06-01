import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:spicekart/model/cart_list_response.dart';
import 'package:spicekart/model/cart_list_food_response.dart';
import 'package:spicekart/model/saved_items_response_food.dart';
import 'package:spicekart/model/saved_items_response_product.dart';
import '../controllers/cart_controller.dart';
import '../controllers/notification_controller.dart';
import '../screens/login_screen.dart';

import '../model/all_regions.dart';
import '../model/category_list.dart';
import '../model/product_detail_response.dart';
import '../model/serach_response.dart';
import '../model/weekly_deals.dart';
import '../model/brands.dart';
import '../model/products_list_response.dart';
import '../model/wishlist_response.dart';
import '../model/banners_response.dart';
import '../model/banner_products.dart';
import '../model/order_history_response.dart';
import '../model/address_list_response.dart';
import '../model/checkout_preview_response.dart';
import '../model/notifications_response.dart';
import '../model/checkout_preview_food_response.dart';
import '../model/subscription_plans.dart';
import '../model/property_types.dart';
import '../model/delivery_slots.dart';
import '../model/profile_response.dart';
import '../model/usuals_response.dart';
import '../model/resturant_response.dart';
import '../model/resturant_menu_response.dart';
import '../model/payment_methods_response.dart';
import '../model/create_customer_payment_method_response.dart';
import '../model/zip_code_list_response.dart';

enum PendingActionType { cart, wishlist }

class PendingAction {
  final PendingActionType type;
  final int? productId;
  final int? variantId;
  final int quantity;

  const PendingAction({
    required this.type,
    this.productId,
    this.variantId,
    this.quantity = 1,
  });
}

class ApiService {
  static const String baseUrl = 'https://spicekart1.mockupz.in/api';

  // Pending action for guest-to-user conversion
  static PendingAction? _pendingAction;

  static void setPendingAction(PendingAction? action) {
    _pendingAction = action;
  }

  static PendingAction? get pendingAction => _pendingAction;

  static Future<void> clearPendingAction() async {
    _pendingAction = null;
  }

  static Future<bool> executePendingAction() async {
    if (_pendingAction == null) return false;

    final action = _pendingAction!;
    bool result = false;

    if (action.type == PendingActionType.cart) {
      if (action.productId != null && action.variantId != null) {
        result = await addProductToCart(
          productId: action.productId!,
          variantId: action.variantId!,
          quantity: action.quantity,
        );
      }
    } else if (action.type == PendingActionType.wishlist) {
      if (action.productId != null) {
        result = await addFavourite(action.productId!);
      }
    }

    _pendingAction = null;
    if (result) {
      Get.find<CartController>().updateCartCount();
    }
    return result;
  }

  // static const String baseUrl = 'https://spicekart1.mockupz.in/api';
  static String? _accessToken;
  static String? _refreshTokenStr;
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _regionKey = 'selected_region';
  static const _pincodePopupKey = 'has_seen_pincode_popup';
  static const _storedPincodeKey = 'stored_pincode';
  static String? _selectedRegion;

  static Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';

      print("Access token:$_accessToken");
    }
    return headers;
  }

  static Map<String, String> get _headersNoAuth {
    final headersNoAuth = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    return headersNoAuth;
  }

  // Initializer to load token and region on app start
  static Future<void> loadToken() async {
    // On iOS, Keychain persists after app uninstall. 
    // We use SharedPreferences (which is wiped on uninstall) to detect a fresh install.
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('is_first_run') ?? true) {
      print('Fresh install detected, clearing secure storage...');
      await _storage.deleteAll();
      await prefs.setBool('is_first_run', false);
    }

    _accessToken = await _storage.read(key: _tokenKey);
    _refreshTokenStr = await _storage.read(key: _refreshTokenKey);
    _selectedRegion = await _storage.read(key: _regionKey);
    if (_accessToken != null) {
      print('Token loaded from storage: $_accessToken');
    }
    if (_refreshTokenStr != null) {
      print('Refresh Token loaded from storage: $_refreshTokenStr');
    }
    if (_selectedRegion != null) {
      print('Region loaded from storage: $_selectedRegion');
    }
  }

  // Getter for selected region
  static String? get selectedRegion => _selectedRegion;

  static Future<void> saveRegion(String region) async {
    _selectedRegion = region;
    await _storage.write(key: _regionKey, value: region);
    print('Region stored securely: $region');
  }

  static Future<void> clearRegion() async {
    _selectedRegion = null;
    await _storage.delete(key: _regionKey);
    print('Region cleared from storage.');
  }

  static Future<bool> checkPincodePopupSeen() async {
    final value = await _storage.read(key: _pincodePopupKey);
    return value == 'true';
  }

  static Future<void> setPincodePopupSeen() async {
    await _storage.write(key: _pincodePopupKey, value: 'true');
  }

  static Future<void> savePincode(String pincode) async {
    await _storage.write(key: _storedPincodeKey, value: pincode);
  }

  static Future<String?> getPincode() async {
    return await _storage.read(key: _storedPincodeKey);
  }

  // Getter to check if we have a token
  static String? get accessToken => _accessToken;

  static Future<void> _storeTokens(
    String accessToken,
    String refreshToken,
  ) async {
    _accessToken = accessToken;
    _refreshTokenStr = refreshToken;
    await _storage.write(key: _tokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    print('Tokens stored securely.');
  }

  static bool _isLoggingOut = false;

  static Future<void> _forceLogout() async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;

    _accessToken = null;
    _refreshTokenStr = null;
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await clearRegion();
    NotificationController.to.logout();
    Get.offAll(() => const LoginScreen());
    
    if (Get.isSnackbarOpen != true) {
      Get.snackbar('Session Expired', 'Please login again.');
    }

    Future.delayed(const Duration(seconds: 3), () {
      _isLoggingOut = false;
    });
  }

  static Future<void> logout() async {
    try {
      final url = Uri.parse('$baseUrl/logout');
      print('Logging out at: $url');
      // Do not use [_postAuthRequest]: a 401 from logout would call [_forceLogout]
      // and show "Session Expired" even when the user chose to log out.
      final response = await http.post(url, headers: _headers);

      if (response.statusCode == 200) {
        print('Logout successful: ${response.body}');
      } else {
        print(
          'Server logout failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error during server logout: $e');
    } finally {
      _accessToken = null;
      _refreshTokenStr = null;
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _refreshTokenKey);
      await clearRegion();
      NotificationController.to.logout();
      print('Logged out from local, tokens and region deleted.');
    }
  }

  static Future<bool> sendOtp(String phoneOrEmail) async {
    try {
      final url = Uri.parse('$baseUrl/sendOtp');
      final response = await http.post(
        url,
        body: jsonEncode({'phone_or_email': phoneOrEmail}),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        print('Send OTP response: ${response.body}');
        return true;
      } else {
        print('Failed to send OTP: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending OTP: $e');
      return false;
    }
  }

  static Future<bool> socialLogin({
    required String accessToken,
    required String provider,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/socialLogin');
      final response = await http.post(
        url,
        body: jsonEncode({
          'access_token': accessToken,
          'provider': provider,
        }),
        headers: _headersNoAuth,
      );

      if (response.statusCode == 200) {
        print('Social Login response: ${response.body}');
        final responseData = jsonDecode(response.body);
        final data = responseData['data'] ?? responseData;
        if (responseData['status'] == 1 &&
            data['access_token'] != null &&
            data['refresh_token'] != null) {
          final access = data['access_token'];
          final refresh = data['refresh_token'];
          await _storeTokens(access, refresh);
          await getProfile(); // Fetch profile to sync OneSignal User ID and selected region
          return true;
        }
      }
      print('Failed social login: ${response.statusCode} - ${response.body}');
      return false;
    } catch (e) {
      print('Error social login: $e');
      return false;
    }
  }

  static Future<bool> verifyOtp(String phoneOrEmail, String otp) async {
    try {
      final url = Uri.parse('$baseUrl/verifyOtp');
      final response = await _postAuthRequest(
        url,
        body: jsonEncode({'phone_or_email': phoneOrEmail, 'otp': otp}),
      );
      print('PhoneOrEmail: $phoneOrEmail, OTP: $otp');

      if (response.statusCode == 200) {
        print('Verify OTP response: ${response.body}');

        try {
          final responseData = jsonDecode(response.body);
          final data = responseData['data'] ?? responseData;
          if (responseData['status'] == 1 &&
              data['access_token'] != null &&
              data['refresh_token'] != null) {
            final access = data['access_token'];
            final refresh = data['refresh_token'];
            await _storeTokens(access, refresh);
            await getProfile(); // Fetch profile to sync OneSignal User ID and selected region
            return true;
          } else {
            print('OTP Verified but status not 1 or token missing.');
            return false;
          }
        } catch (e) {
          print('Error parsing verifyOtp response: $e');
          return false;
        }
      } else {
        print(
          'Failed to verify OTP: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Error verifying OTP: $e');
      return false;
    }
  }

  static Future<bool> _refreshToken() async {
    if (_refreshTokenStr == null) return false;

    try {
      final url = Uri.parse('$baseUrl/refreshToken');
      print('Calling refreshToken API');
      final response = await http.post(
        url,
        headers: _headersNoAuth,
        body: jsonEncode({'refresh_token': _refreshTokenStr}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final data = responseData['data'] ?? responseData;
        if (responseData['status'] == 1 &&
            data['access_token'] != null &&
            data['refresh_token'] != null) {
          final newAccess = data['access_token'];
          final newRefresh = data['refresh_token'];
          await _storeTokens(newAccess, newRefresh);
          print('Token refreshed successfully');
          return true;
        }
      } else if (response.statusCode == 400) {
        try {
          final body = jsonDecode(response.body);
          if (body['status'] == 0 && body['message'] == 'Invalid or expired refresh token') {
            await _forceLogout();
          }
        } catch (e) {}
      }
      print(
        'Failed to refresh token: ${response.statusCode} - ${response.body}',
      );
    } catch (e) {
      print('Error refreshing token: $e');
    }
    return false;
  }

  static Future<http.Response> _postAuthRequest(Uri url, {Object? body}) async {
    http.Response response = await http.post(
      url,
      headers: _headers,
      body: body,
    );

    if (response.statusCode == 401) {
      print('401 Unauthorized received for . Attempting to refresh token...');
      final bool refreshSuccess = await _refreshToken();
      if (refreshSuccess) {
        print('Token refreshed, retrying request for ');
        response = await http.post(url, headers: _headers, body: body);
      }
      if (response.statusCode == 401) {
        try {
          final resBody = jsonDecode(response.body);
          if (resBody['message'] == 'Unauthenticated.') {
            await _forceLogout();
          }
        } catch (e) {}
      }
    }
    return response;
  }

  static Future<http.Response> _getAuthRequest(Uri url) async {
    http.Response response = await http.get(
      url,
      headers: _headers,
    );

    if (response.statusCode == 401) {
      print('401 Unauthorized received for . Attempting to refresh token...');
      final bool refreshSuccess = await _refreshToken();
      if (refreshSuccess) {
        print('Token refreshed, retrying request for ');
        response = await http.get(url, headers: _headers);
      }
      if (response.statusCode == 401) {
        try {
          final resBody = jsonDecode(response.body);
          if (resBody['message'] == 'Unauthenticated.') {
            await _forceLogout();
          }
        } catch (e) {}
      }
    }
    return response;
  }

  static Future<AllRegions?> getAllRegions() async {
    try {
      final url = Uri.parse('$baseUrl/listAllRegions');
      print('Fetching regions from: $url with headers: $_headers');
      // Ensure we have the token if it exists (though verifyOtp sets variable, reload just in case is not needed if variable is static)
      final response = await http.post(url, headers: _headersNoAuth);

      if (response.statusCode == 200) {
        print('Get All Regions response: ${response.body}');
        return allRegionsFromJson(response.body);
      } else {
        print(
          'Failed to get regions: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error getting regions: $e');
      return null;
    }
  }

  static Future<ZipCodeListResponse?> listAllZipcodesWithZones() async {
    try {
      final url = Uri.parse('$baseUrl/listAllZipcodesWithZones');
      print('Fetching zip codes from: $url');

      final response = await http.post(url, headers: _headersNoAuth);

      if (response.statusCode == 200) {
        print('Get All Zipcodes response: ${response.body}');
        return zipCodeListResponseFromJson(response.body);
      } else {
        print(
          'Failed to get zip codes: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error getting zip codes: $e');
      return null;
    }
  }

  static Future<bool> findValidZipCode(String zipCode) async {
    try {
      final url = Uri.parse('$baseUrl/findValidZipCode');
      print('Checking zip code from: $url');
      
      final response = await http.post(
        url,
        headers: _headersNoAuth,
        body: jsonEncode({'zip_code': zipCode}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 1;
      }
      return false;
    } catch (e) {
      print('Error checking zip code: $e');
      return false;
    }
  }

  static Future<SearchResponse?> searchProducts(
    String search, {
    int? categoryId,
    int? brandId,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/searchProducts');
      print(
        'Searching products from: $url with search: $search, category: $categoryId, brand: $brandId, page: $page and headers: $_headers',
      );

      final Map<String, dynamic> body = {
        'search': search,
        'page': page,
        'per_page': perPage,
      };
      if (categoryId != null) body['category_id'] = categoryId;
      if (brandId != null) body['brand_id'] = brandId;

      final response = await http.post(
        url,
        headers: _headersNoAuth,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('Search Products response: ${response.body}');
        return searchResponseFromJson(response.body);
      } else {
        print(
          'Failed to search products: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error searching products: $e');
      return null;
    }
  }

  static Future<CategoryList?> listAllCategories() async {
    try {
      final url = Uri.parse('$baseUrl/listAllCategories');
      print('Fetching categories from: $url');

      final response = await http.post(url, headers: _headersNoAuth);

      if (response.statusCode == 200) {
        print('List All Categories response: ${response.body}');
        return categoryListFromJson(response.body);
      } else {
        print(
          'Failed to get categories: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error getting categories: $e');
      return null;
    }
  }

  static Future<WeeklyDeals?> getWeekDealsProducts({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/getWeekDealsProducts');
      print('Fetching weekly deals from: $url for page: $page');

      final response = await _postAuthRequest(
        url,
        body: jsonEncode({
          'page': page,
          'per_page': perPage,
        }),
      );

      if (response.statusCode == 200) {
        print('Get Week Deals Products response: ${response.body}');
        return weeklyDealsFromJson(response.body);
      } else {
        print(
          'Failed to get weekly deals: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error getting weekly deals: $e');
      return null;
    }
  }

  static Future<UsualsResponse?> listUsualItems() async {
    final url = Uri.parse('$baseUrl/listUsualItems');
    try {
      final response = await _postAuthRequest(
        url
      );
      if (response.statusCode == 200) {
        return UsualsResponse.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e) {
      print('Error in listUsualItems: $e');
      return null;
    }
  }

  static Future<ProductDetailResponse?> getProductDetails(int productId) async {
    try {
      final url = Uri.parse('$baseUrl/getProductDetails');
      print('Fetching product details from: $url for product_id: $productId');

      final response = await _postAuthRequest(
        url,
        body: jsonEncode({'product_id': productId}),
      );

      if (response.statusCode == 200) {
        print('Get Product Details response: ${response.body}');
        return productDetailResponseFromJson(response.body);
      } else {
        print(
          'Failed to get product details: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error getting product details: $e');
      return null;
    }
  }

  static Future<bool> addFavourite(int productId) async {
    try {
      final url = Uri.parse('$baseUrl/addFavourite');
      print('Toggling favorite from: $url for product_id: $productId');

      final response = await _postAuthRequest(
        url,
        body: jsonEncode({'product_id': productId}),
      );

      if (response.statusCode == 200) {
        print('Add Favourite response: ${response.body}');
        final data = jsonDecode(response.body);
        return data['status'] == 1;
      } else {
        print(
          'Failed to toggle favorite: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      return false;
    }
  }

  static Future<bool> addProductToCart({
    required int productId,
    required int variantId,
    required int quantity,
    int isSavedForLater = 0,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/addToCart');
      print('Adding to cart at: $url');

      final response = await _postAuthRequest(
        url,
        body: jsonEncode({
          'item_type': 'product',
          'item_id': productId,
          'variant_id': variantId,
          'quantity': quantity,
          'is_saved_for_later': isSavedForLater,
        }),
      );

      if (response.statusCode == 200) {
        print('Add to Cart response: ${response.body}');
        final data = jsonDecode(response.body);
        final bool success = data['status'] == 1;
        if (success) {
          Get.find<CartController>().updateCartCount();
        }
        return success;
      } else {
        print(
          'Failed to add to cart: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Error adding to cart: $e');
      return false;
    }
  }

  static Future<bool> addFoodToCart({
    required int itemId,
    required int quantity,
    required int restaurantId,
    required String restaurantName,
    required String restaurantAddress,
    int isSavedForLater = 0,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/addToCart');
      print('Adding food to cart at: $url');

      final response = await _postAuthRequest(
        url,
        body: jsonEncode({
          'item_type': 'food',
          'item_id': itemId,
          'quantity': quantity,
          'is_saved_for_later': isSavedForLater,
          'restaurant_id': restaurantId,
          'restaurant_name': restaurantName,
          'restaurant_address': restaurantAddress,
        }),
      );

      if (response.statusCode == 200) {
        print('Add Food to Cart response: ${response.body}');
        final data = jsonDecode(response.body);
        final bool success = data['status'] == 1;
        if (success) {
          Get.find<CartController>().updateCartCount();
        }
        return success;
      } else {
        print(
          'Failed to add food to cart: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Error adding food to cart: $e');
      return false;
    }
  }


  static Future<NotificationsResponse?> getUserNotifications() async {
    try {
      final url = Uri.parse('$baseUrl/getUserNotifications');
      print('Fetching user notifications from: $url');

      final response = await _getAuthRequest(url);

      if (response.statusCode == 200) {
        print('Get User Notifications response: ${response.body}');
        return notificationsResponseFromJson(response.body);
      } else {
        print(
          'Failed to get user notifications: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error getting user notifications: $e');
      return null;
    }
  }

  static Future<bool> markNotificationAsRead(int notificationId) async {
    try {
      final url = Uri.parse('$baseUrl/markNotificationAsRead');
      print('Marking notification as read from: $url');

      final response = await _postAuthRequest(
        url,
        body: jsonEncode({'notification_id': notificationId}),
      );

      if (response.statusCode == 200) {
        print('Mark Notification As Read response: ${response.body}');
        final data = jsonDecode(response.body);
        return data['status'] == 1;
      } else {
        print('Failed to mark notification as read: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  static Future<bool> markAllNotificationsAsRead() async {
    try {
      final url = Uri.parse('$baseUrl/markAllNotificationsAsRead');
      print('Marking all notifications as read from: $url');

      final response = await _postAuthRequest(url);

      if (response.statusCode == 200) {
        print('Mark All Notifications As Read response: ${response.body}');
        final data = jsonDecode(response.body);
        return data['status'] == 1;
      } else {
        print('Failed to mark all notifications as read: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error marking all notifications as read: $e');
      return false;
    }
  }

  static Future<CartListProductResponse?> listCartItems() async {
    try {
      final url = Uri.parse('$baseUrl/listCartItems');
      print('Fetching cart items from: $url');

      final response = await _postAuthRequest(
        url,
        body: jsonEncode({}),
      );

      if (response.statusCode == 200) {
        print('List Cart Items response: ${response.body}');
        return cartListProductResponseFromJson(response.body);
      } else {
        print(
          'Failed to list cart items: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error listing cart items: $e');
      return null;
    }
  }

  static Future<SavedItemsResponseProduct?> getSavedItemsList({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/getSavedItemsList');
      print('Fetching saved items from: $url for page: $page');

      final response = await _postAuthRequest(
        url,
        body: jsonEncode({
          'page': page,
          'per_page': perPage,
        }),
      );

      if (response.statusCode == 200) {
        print('Get Saved Items List response: ${response.body}');
        return savedItemsResponseProductFromJson(response.body);
      } else {
        print(
          'Failed to list saved items: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error listing saved items: $e');
      return null;
    }
  }

  static Future<bool> updateCartQuantity(int cartId, int quantity) async {
    try {
      final url = Uri.parse('$baseUrl/updateCartQuantity');
      print('Updating cart quantity at: $url');

      final response = await _postAuthRequest(
        url,
        body: jsonEncode({'cart_id': cartId, 'quantity': quantity}),
      );

      if (response.statusCode == 200) {
        print('Update Cart Quantity response: ${response.body}');
        final data = jsonDecode(response.body);
        final bool success = data['status'] == 1;
        if (success) {
          Get.find<CartController>().updateCartCount();
        }
        return success;
      } else {
        print(
          'Failed to update cart quantity: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Error updating cart quantity: $e');
      return false;
    }
  }

  static Future<bool> updateCartItem({
    required int cartItemId,
    required String action,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/updateCartItem');
      print('Updating cart item at: $url with action: $action');

      final response = await _postAuthRequest(
        url,
        body: jsonEncode({
          'cart_item_id': cartItemId,
          'action': action,
        }),
      );

      if (response.statusCode == 200) {
        print('Update Cart Item response: ${response.body}');
        final data = jsonDecode(response.body);
        final bool success = data['status'] == 1;
        if (success) {
          Get.find<CartController>().updateCartCount();
        }
        return success;
      } else {
        print(
          'Failed to update cart item: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Error updating cart item: $e');
      return false;
    }
  }

  static Future<bool> deleteCartItem({
    required int cartId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/deleteCartItems');
      print('Deleting cart item at: $url');

      final response = await _postAuthRequest(
        url,
        body: jsonEncode({
          'cart_item_id': cartId,
        }),
      );

      if (response.statusCode == 200) {
        print('Delete Cart Item response: ${response.body}');
        final data = jsonDecode(response.body);
        final bool success = data['status'] == 1;
        if (success) {
          Get.find<CartController>().updateCartCount();
        }
        return success;
      } else {
        print(
          'Failed to delete cart item: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Error deleting cart item: $e');
      return false;
    }
  }

  static Future<bool> saveForLater(int cartId, int isSavedForLater) async {
    try {
      final url = Uri.parse('$baseUrl/saveForLater');
      print('Moving to save for later at: $url');

      final response = await _postAuthRequest(
        url,
        body: jsonEncode({
          'cart_id': cartId,
          'is_saved_for_later': isSavedForLater,
        }),
      );

      if (response.statusCode == 200) {
        print('Save for Later response: ${response.body}');
        final data = jsonDecode(response.body);
        final bool success = data['status'] == 1;
        if (success) {
          Get.find<CartController>().updateCartCount();
        }
        return success;
      } else {
        print(
          'Failed to save for later: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Error saving for later: $e');
      return false;
    }
  }

  static Future<int> getCartCount() async {
    try {
      final url = Uri.parse('$baseUrl/cartCount');
      print('Fetching cart count from: $url');

      final response = await _postAuthRequest(
        url,
        body: jsonEncode({}),
      );

      if (response.statusCode == 200) {
        print('Cart count response: ${response.body}');
        final data = jsonDecode(response.body);
        if (data['status'] == 1) {
          final rawData = data['data'];
          if (rawData is int) {
            return rawData;
          } else if (rawData is num) {
            return rawData.toInt();
          } else if (rawData != null) {
            return int.tryParse(rawData.toString()) ?? 0;
          }
        }
      }
      return 0;
    } catch (e) {
      print('Error fetching cart count: $e');
      return 0;
    }
  }

  static Future<bool> addDeliveryInstructions({
    required int propertyTypeId,
    required String deliveryNotes,
    required String dropOffLocation,
    required String gateCode,
    required String deliveryPreference,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/updateDeliveryInstructions');
      print('Adding delivery instructions at: $url');
      print('propertyTypeId: $propertyTypeId');
      final response = await _postAuthRequest(
        url,
        body: jsonEncode({
          'property_type_id': propertyTypeId,
          'gate_code': gateCode,
          'delivery_notes': deliveryNotes,
          'drop_off_location': dropOffLocation,
          'delivery_preference': deliveryPreference,
        }),
      );

      if (response.statusCode == 200) {
        print('Add Delivery Instructions response: ${response.body}');
        final data = jsonDecode(response.body);
        return data['status'] == 1;
      } else {
        print(
          'Failed to add delivery instructions: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Error adding delivery instructions: $e');
      return false;
    }
  }

  static Future<PropertyTypes?> listPropertyTypes() async {
    try {
      final url = Uri.parse('$baseUrl/listPropertyTypes');
      print('Fetching property types from: $url');

      final response = await _postAuthRequest(url);

      if (response.statusCode == 200) {
        print('List Property Types response: ${response.body}');
        return propertyTypesFromJson(response.body);
      } else {
        print(
          'Failed to list property types: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error listing property types: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getDeliveryInstructions() async {
    try {
      final url = Uri.parse('$baseUrl/getDeliveryInstructions');
      print('Fetching delivery instructions from: $url');

      final response = await _postAuthRequest(
        url,
        body: jsonEncode({}),
      );

      if (response.statusCode == 200) {
        print('Get Delivery Instructions response: ${response.body}');
        return jsonDecode(response.body);
      } else {
        print(
          'Failed to get delivery instructions: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error getting delivery instructions: $e');
      return null;
    }
  }

  static Future<Brands?> listBrands({int? categoryId}) async {
    try {
      final url = Uri.parse('$baseUrl/listBrands');
      print('Fetching brands from: $url for category: $categoryId');

      final Map<String, dynamic> body = {};
      if (categoryId != null) body['category_id'] = categoryId;

      final response = await http.post(
        url,
        headers: _headersNoAuth,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('List Brands response: ${response.body}');
        return brandsFromJson(response.body);
      } else {
        print(
          'Failed to get brands: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error getting brands: $e');
      return null;
    }
  }

  static Future<ProductsListResponse?> listProducts({
    int? categoryId,
    int? brandId,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/listProducts');
      print(
        'Fetching products from: $url for category: $categoryId, brand: $brandId, page: $page',
      );

      final Map<String, dynamic> body = {
        'page': page,
        'per_page': perPage,
      };
      if (categoryId != null) body['category_id'] = categoryId;
      if (brandId != null) body['brand_id'] = brandId;

      final response = await http.post(
        url,
        headers: _headersNoAuth,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('List Products response: ${response.body}');
        return productsListResponseFromJson(response.body);
      } else {
        print(
          'Failed to get products: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error getting products: $e');
      return null;
    }
  }

  static Future<FavouritesListResponse?> listFavourites({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/listFavourites');
      print('Fetching favorites from: $url for page: $page');

      final response = await _postAuthRequest(
        url,
        body: jsonEncode({
          'page': page,
          'per_page': perPage,
        }),
      );

      if (response.statusCode == 200) {
        print('List Favourites response: ${response.body}');
        return favouritesListResponseFromJson(response.body);
      } else {
        print(
          'Failed to get favorites: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error getting favorites: $e');
      return null;
    }
  }

  static Future<bool> removeFromWishlist(int productId) async {
    try {
      final url = Uri.parse('$baseUrl/removeFavourite');
      print('Removing favorite from: $url for product_id: $productId');

      final response = await _postAuthRequest(
        url,
        body: jsonEncode({'product_id': productId}),
      );

      if (response.statusCode == 200) {
        print('Remove Favourite response: ${response.body}');
        final data = jsonDecode(response.body);
        return data['status'] == 1;
      } else {
        print(
          'Failed to remove favorite: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Error removing favorite: $e');
      return false;
    }
  }

  static Future<BannersResponse?> getBanners() async {
    try {
      final url = Uri.parse('$baseUrl/getBanners');
      print('Fetching banners from: $url');

      final response = await http.post(url, headers: _headersNoAuth);

      if (response.statusCode == 200) {
        print('Get Banners response: ${response.body}');
        return bannersResponseFromJson(response.body);
      } else {
        print(
          'Failed to get banners: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error getting banners: $e');
      return null;
    }
  }

  static Future<bool> updateUserRegion(int regionId) async {
    try {
      final url = Uri.parse('$baseUrl/updateUserRegion');
      print('Updating user region at: $url with region_id: $regionId');

      final response = await _postAuthRequest(
        url,
        body: jsonEncode({'region_id': regionId}),
      );

      if (response.statusCode == 200) {
        print('Update User Region response: ${response.body}');
        final data = jsonDecode(response.body);
        return data['status'] == 1;
      } else {
        print(
          'Failed to update region: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Error updating region: $e');
      return false;
    }
  }

  static Future<SubscriptionPlans?> getSubscriptionPlans() async {
    try {
      final url = Uri.parse('$baseUrl/subscriptionPlans');
      print('Fetching subscription plans from: $url');

      final response = await _getAuthRequest(url);

      if (response.statusCode == 200) {
        print('Get Subscription Plans response: ${response.body}');
        return subscriptionPlansFromJson(response.body);
      } else {
        print(
          'Failed to get subscription plans: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error getting subscription plans: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>> checkActiveSubscription() async {
    try {
      final url = Uri.parse('$baseUrl/subscription');
      print('Checking active subscription from: $url');

      final response = await _getAuthRequest(url);

      if (response.statusCode == 200) {
        print('Check active subscription response: ${response.body}');
        return jsonDecode(response.body);
      } else {
        print(
          'Failed to check active subscription: ${response.statusCode} - ${response.body}',
        );
        return {'status': 0, 'message': 'Failed', 'data': null};
      }
    } catch (e) {
      print('Error checking active subscription: $e');
      return {'status': 0, 'message': 'Error', 'data': null};
    }
  }

  static Future<BannerProducts?> getBannerProducts(
    int bannerId, {
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/getBannerProducts');
      print(
        'Fetching banner products from: $url for banner_id: $bannerId, page: $page',
      );

      final response = await http.post(
        url,
        headers: _headersNoAuth,
        body: jsonEncode({
          'banner_id': bannerId,
          'page': page,
          'per_page': perPage,
        }),
      );

      if (response.statusCode == 200) {
        print('Get Banner Products response: ${response.body}');
        return bannerProductsFromJson(response.body);
      } else {
        print(
          'Failed to get banner products: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error getting banner products: $e');
      return null;
    }
  }


  static Future<bool> rateOrder({
    required int orderId,
    required double deliveryRating,
    required List<Map<String, dynamic>> itemRatings,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/submitOrderRating');
      print('Submitting order rating at: $url');

      final response = await _postAuthRequest(
        url,
        body: jsonEncode({
          'order_id': orderId,
          'delivery_rating': deliveryRating,
          'item_ratings': itemRatings,
        }),
      );

      if (response.statusCode == 200) {
        print('Submit Rating response: ${response.body}');
        final data = jsonDecode(response.body);
        return data['status'] == 1;
      } else {
        print(
          'Failed to submit rating: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Error submitting rating: $e');
      return false;
    }
  }

  static Future<bool> rateProduct({
    required int productId,
    required double rating,
    String reviewText = "",
  }) async {
    try {
      final url = Uri.parse('$baseUrl/rateProduct');
      print('Submitting product rating at: $url');

      final response = await _postAuthRequest(
        url,
        body: jsonEncode({
          'product_id': productId,
          'rating': rating,
          'review_text': 'No Reviews',
        }),
      );

      if (response.statusCode == 200) {
        print('Rate Product response: ${response.body}');
        final data = jsonDecode(response.body);
        return data['status'] == 1;
      } else {
        print(
          'Failed to rate product: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Error rating product: $e');
      return false;
    }
  }

  static Future<bool> updateCheckoutAddress({
    required int addressId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/updateCheckoutAddress');
      print('Updating checkout address at: $url with address_id: $addressId');

      final response = await _postAuthRequest(
        url,
        body: jsonEncode({
          'address_id': addressId,
        }),
      );

      if (response.statusCode == 200) {
        print('Update Checkout Address response: ${response.body}');
        final data = jsonDecode(response.body);
        return data['status'] == 1;
      } else {
        print(
          'Failed to update checkout address: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Error updating checkout address: $e');
      return false;
    }
  }

  static Future<AddressListResponse?> listUserAddresses() async {
    try {
      final url = Uri.parse('$baseUrl/listUserAddresses');
      print('Fetching user addresses from: $url');

      final response = await _postAuthRequest(url);

      if (response.statusCode == 200) {
        print('List User Addresses response: ${response.body}');
        return addressListResponseFromJson(response.body);
      } else if (response.statusCode == 404) {
        print(
          'No Addresses to show: ${response.statusCode} - ${response.body}',
        );
        return AddressListResponse(
          status: 0,
          message: 'No Addresses to show',
          data: [],
        );
      } else {
        print(
          'Failed to list user addresses: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error listing user addresses: $e');
      return null;
    }
  }

  static Future<bool> updateUserAddress({
    int? addressId,
    required String addressLine1,
    String? addressLine2,
    String? landmark,
    required String city,
    required String state,
    String country = 'USA',
    required String postalCode,
    required String addressType,
    String? firstName,
    String? lastName,
    required bool isDefault,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/updateUserAddress');
      print('Updating user address at: $url');

      final Map<String, dynamic> body = {
        'address_line_1': addressLine1,
        'city': city,
        'state': state,
        'country': country,
        'postal_code': postalCode,
        'address_type': addressType,
        'is_default': isDefault ? 1 : 0,
      };

      if (firstName != null) body['first_name'] = firstName;
      if (lastName != null) body['last_name'] = lastName;

      if (addressId != null) body['address_id'] = addressId;
      if (addressLine2 != null && addressLine2.isNotEmpty)
        body['address_line_2'] = addressLine2;
      if (landmark != null && landmark.isNotEmpty) body['landmark'] = landmark;

      final response = await _postAuthRequest(url, body: jsonEncode(body));

      if (response.statusCode == 200) {
        print('Update User Address response: ${response.body}');
        final data = jsonDecode(response.body);
        return data['status'] == 1;
      } else {
        print(
          'Failed to update user address: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Error updating user address: $e');
      return false;
    }
  }

  static Future<bool> deleteUserAddress(int addressId) async {
    try {
      final url = Uri.parse('$baseUrl/deleteUserAddress');
      print('Deleting user address at: $url with address_id: $addressId');

      final response = await _postAuthRequest(
        url,
        body: jsonEncode({'address_id': addressId}),
      );

      if (response.statusCode == 200) {
        print('Delete User Address response: ${response.body}');
        final data = jsonDecode(response.body);
        return data['status'] == 1;
      } else {
        print(
          'Failed to delete user address: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Error deleting user address: $e');
      return false;
    }
  }

  static Future<CheckoutPreviewProductResponse?> checkoutPreview() async {
    try {
      final url = Uri.parse('$baseUrl/checkoutPreview');
      print('Checkout preview at: $url');

      final response = await _postAuthRequest(
        url,
        body: jsonEncode({}),
      );

      if (response.statusCode == 200) {
        print('Checkout Preview response: ${response.body}');
        return checkoutPreviewProductResponseFromJson(response.body);
      } else {
        print(
          'Failed to get checkout preview: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error getting checkout preview: $e');
      return null;
    }
  }

  /// Returns saved customer payment methods (e.g. Stripe) when `status == 1`.
  static Future<PaymentMethodsResponse?> getCustomerPaymentmethods() async {
    try {
      final url = Uri.parse('$baseUrl/getCustomerPaymentmethods');
      final response = await _postAuthRequest(
        url,
        body: jsonEncode({}),
      );
      if (response.statusCode != 200) return null;
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return null;
      if (_asInt(decoded['status']) != 1) return null;
      return PaymentMethodsResponse.fromJson(decoded);
    } catch (e) {
      print('Error getting customer payment methods: $e');
      return null;
    }
  }

  /// Starts Stripe SetupIntent flow to attach a new payment method to the customer.
  /// On success, `data.client_secret` is used with the Payment Sheet.
  static Future<CreateCustomerPaymentMethodResponse?>
      createCustomerPaymentMethod() async {
    try {
      final url = Uri.parse('$baseUrl/createCustomerPaymentMethod');
      final response = await _postAuthRequest(
        url,
        body: jsonEncode({}),
      );
      if (response.statusCode != 200) return null;
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return null;
      return CreateCustomerPaymentMethodResponse.fromJson(decoded);
    } catch (e) {
      print('Error createCustomerPaymentMethod: $e');
      return null;
    }
  }

  static int _asInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.round();
    return int.tryParse(v.toString()) ?? 0;
  }

  static Future<Map<String, dynamic>> checkout({
    required String paymentMethod,
    String? playerId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/checkout');
      print('Calling checkout at: $url');
      print('Payment method:$paymentMethod');


      final bodyData = {
        'payment_method': 'stripe',
      };


      if (playerId != null) {
        bodyData['player_id'] = playerId;
      }

      final response = await _postAuthRequest(
        url,
        body: jsonEncode(bodyData),
      );

      if (response.statusCode == 200) {
        print('Checkout API response: ${response.body}');
        return jsonDecode(response.body);
      } else {
        print('Failed to checkout: ${response.statusCode} - ${response.body}');
        try {
          final errorData = jsonDecode(response.body);
          return {
            'status': errorData['status'] ?? 0,
            'message': errorData['message'] ?? 'Failed to process checkout'
          };
        } catch (_) {
          return {'status': 0, 'message': 'Failed to process checkout'};
        }
      }
    } catch (e) {
      print('Error calling checkout: $e');
      return {'status': 0, 'message': 'Error'};
    }
  }

  static Future<bool> applyTip({
    required String tipType,
    int tipPercent = 0,
    double customTipAmount = 0,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/applyTip');
      print(
        'Applying tip at: $url tip_type: $tipType tip_percent: $tipPercent custom_tip_amount: $customTipAmount',
      );

      final response = await _postAuthRequest(
        url,
        body: jsonEncode({
          'tip_type': tipType,
          'tip_percent': tipPercent,
          'custom_tip_amount': customTipAmount,
        }),
      );

      if (response.statusCode == 200) {
        print('Apply Tip response: ${response.body}');
        final data = jsonDecode(response.body);
        return data['status'] == 1;
      } else {
        print('Failed to apply tip: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error applying tip: $e');
      return false;
    }
  }

  static Future<bool> applyCoupon({
    required String couponCode,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/applyCoupon');
      print('Applying coupon at: $url with coupon_code: $couponCode');

      final response = await _postAuthRequest(
        url,
        body: jsonEncode({
          'coupon_code': couponCode,
        }),
      );

      if (response.statusCode == 200) {
        print('Apply Coupon response: ${response.body}');
        final data = jsonDecode(response.body);
        return data['status'] == 1;
      } else {
        print(
          'Failed to apply coupon: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Error applying coupon: $e');
      return false;
    }
  }

  static Future<bool> removeCoupon() async {
    try {
      final url = Uri.parse('$baseUrl/removeCoupon');
      print('Removing coupon at: $url');

      final response = await _postAuthRequest(
        url,
        body: jsonEncode({}),
      );

      if (response.statusCode == 200) {
        print('Remove Coupon response: ${response.body}');
        final data = jsonDecode(response.body);
        return data['status'] == 1;
      } else {
        print(
          'Failed to remove coupon: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Error removing coupon: $e');
      return false;
    }
  }


  static Future<bool> updateUserTimezone(String timezone) async {
    try {
      // Modernize legacy timezone names
      // if (timezone == 'Asia/Calcutta') {
      //   timezone = 'Asia/Kolkata';
      // }

      final url = Uri.parse('$baseUrl/updateUserTimezone');
      print('Updating user timezone at: $url with timezone: $timezone');

      final response = await _postAuthRequest(
        url,
        body: jsonEncode({'timezone': timezone}),
      );

      if (response.statusCode == 200) {
        print('Update User Timezone response: ${response.body}');
        final data = jsonDecode(response.body);
        return data['status'] == 1;
      } else {
        print(
          'Failed to update timezone: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Error updating timezone: $e');
      return false;
    }
  }

  static Future<DeliverySlots?> listDeliverySlots() async {
    try {
      final url = Uri.parse('$baseUrl/listDeliverySlots');
      print('Fetching delivery slots from: $url');

      final response = await _postAuthRequest(url);

      if (response.statusCode == 200) {
        print('List Delivery Slots response: ${response.body}');
        return deliverySlotsFromJson(response.body);
      } else {
        print(
          'Failed to list delivery slots: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error listing delivery slots: $e');
      return null;
    }
  }

  static Future<bool> applyWallet({
    required bool redeem,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/applyWallet');
      print('Applying wallet at: $url with redeem: $redeem');

      final response = await _postAuthRequest(
        url,
        body: jsonEncode({
          'redeem': redeem ? 1 : 0,
        }),
      );

      if (response.statusCode == 200) {
        print('Apply Wallet response: ${response.body}');
        final data = jsonDecode(response.body);
        return data['status'] == 1;
      } else {
        print(
          'Failed to apply wallet: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Error applying wallet: $e');
      return false;
    }
  }

  static Future<bool> updateCheckoutEmail({
    required String email,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/updateCheckoutEmail');
      print('Updating checkout email at: $url with email: $email');

      final response = await _postAuthRequest(
        url,
        body: jsonEncode({
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        print('Update Checkout Email response: ${response.body}');
        final data = jsonDecode(response.body);
        return data['status'] == 1;
      } else {
        print(
          'Failed to update checkout email: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Error updating checkout email: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> sendCheckoutPhoneOtp({
    required String phone,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/sendCheckoutPhoneOtp');
      print('Sending checkout phone OTP for: $phone');

      final response = await _postAuthRequest(
        url,
        body: jsonEncode({
          'phone': phone,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': data['status'] == 1,
          'message': data['message'] ?? 'Failed to send OTP',
        };
      } else {
        return {
          'success': false,
          'message':
              'Failed to send checkout phone OTP: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Error sending checkout phone OTP: $e');
      return {'success': false, 'message': 'Error sending checkout phone OTP'};
    }
  }

  static Future<bool> verifyCheckoutPhoneOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/verifyCheckoutPhoneOtp');
      print('Verifying checkout phone OTP: $otp for: $phone');

      final response = await _postAuthRequest(
        url,
        body: jsonEncode({
          'phone': phone,
          'otp': otp,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 1;
      } else {
        print('Failed to verify checkout phone OTP: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error verifying checkout phone OTP: $e');
      return false;
    }
  }

  static Future<bool> addDeliverySlot({
    required int deliverySlotId,
    required String deliveryDate,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/addDeliverySlot');
      print(
        'Adding delivery slot at: $url with id: $deliverySlotId, date: $deliveryDate',
      );

      final response = await _postAuthRequest(
        url,
        body: jsonEncode({
          'delivery_slot_id': deliverySlotId,
          'delivery_date': deliveryDate,
        }),
      );

      if (response.statusCode == 200) {
        print('Add Delivery Slot response: ${response.body}');
        final data = jsonDecode(response.body);
        return data['status'] == 1;
      } else {
        print(
          'Failed to add delivery slot: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Error adding delivery slot: $e');
      return false;
    }
  }

  static Future<ProfileResponse?> getProfile() async {
    try {
      final url = Uri.parse('$baseUrl/getProfile');
      print('Fetching profile from: $url');

      final response = await _postAuthRequest(url);

      if (response.statusCode == 200) {
        print('Get Profile response: ${response.body}');
        final profile = profileResponseFromJson(response.body);
        if (profile.status == 1 && profile.data != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_first_name', profile.data!.firstName);
          await prefs.setString('user_email', profile.data!.email);
          
          NotificationController.to.login(profile.data!.id.toString());
          
          if (profile.data!.regionId != null) {
            final regions = await getAllRegions();
            if (regions != null && regions.status == 1) {
              final match = regions.data.firstWhereOrNull((r) => r.id == profile.data!.regionId);
              if (match != null) {
                await saveRegion(match.title);
              }
            }
          }
        }
        return profile;
      } else {
        print(
          'Failed to get profile: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error getting profile: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    String? timezone,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/updateProfile');
      print('Updating profile at: $url');

      final response = await _postAuthRequest(
        url,
        body: jsonEncode({
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'phone': phone,
          if (timezone != null) 'timezone': timezone,
        }),
      );

      if (response.statusCode == 200) {
        print('Update Profile response: ${response.body}');
        final result = jsonDecode(response.body);
        if (result['status'] == 1) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_first_name', firstName);
          await prefs.setString('user_email', email);
        }
        return result;
      } else {
        print(
          'Failed to update profile: ${response.statusCode} - ${response.body}',
        );
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {'status': 0, 'message': 'Failed to update profile'};
        }
      }
    } catch (e) {
      print('Error updating profile: $e');
      return {'status': 0, 'message': 'Something went wrong'};
    }
  }

/*  static Future<bool> generateDeliveryCode({
    required bool generate,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/generateDeliveryCode');
      final response = await _postAuthRequest(
        url,
        body: jsonEncode({
          'generate': generate,
        }),
      );
      print("generate:$generate");
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }*/

  static Future<OrderHistoryResponse?> listOrders({
    String? status,
    int? perPage,
    int? page,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/listOrders');
      final Map<String, dynamic> body = {};
      if (status != null) body['status'] = status;
      if (perPage != null) body['per_page'] = perPage;
      if (page != null) body['page'] = page;

      final response = await _postAuthRequest(
        url,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('List Orders response: ${response.body}');
        return orderHistoryResponseFromJson(response.body);
      } else {
        print(
          'Failed to list orders: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error listing orders: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getCurrentActiveWebTheme() async {
    try {
      final url = Uri.parse('$baseUrl/getCurrentActiveWebTheme');
      print('Fetching active theme from: $url');

      final response = await http.post(url, headers: _headersNoAuth);

      if (response.statusCode == 200) {
        print('Get Active Theme response: ${response.body}');
        return jsonDecode(response.body);
      } else {
        print(
          'Failed to get active theme: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error getting active theme: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getCurrentActiveThemeByPlatform({
    required String platform,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/getCurrentActiveThemeByPlatform');
      print('Fetching active theme from: $url for platform: $platform');

      final response = await http.post(
        url,
        headers: _headersNoAuth,
        body: jsonEncode({'platform': platform}),
      );

      if (response.statusCode == 200) {
        print('Get Active Theme response: ${response.body}');
        return jsonDecode(response.body);
      } else {
        print(
          'Failed to get active theme: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error getting active theme: $e');
      return null;
    }
  }

  static Future<RestaurantsResponse?> getRestaurants() async {
    try {
      final url = Uri.parse('$baseUrl/getRestaurants');
      print('Fetching restaurants from: $url');

      final response = await http.post(
        url,
        headers: _headersNoAuth,
      );

      if (response.statusCode == 200) {
        print('Get Restaurants response: ${response.body}');
        return restaurantsResponseFromJson(response.body);
      } else {
        print(
          'Failed to get restaurants: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error getting restaurants: $e');
      return null;
    }
  }

  static Future<RestaurantMenuResponse?> getFoodItems({
    required int restaurantId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/getFoodItems');
      print('Fetching food items for restaurant: $restaurantId');

      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode({
          'restaurant_id': restaurantId,
        }),
      );

      if (response.statusCode == 200) {
        print('Get Food Items response: ${response.body}');
        return restaurantMenuResponseFromJson(response.body);
      } else {
        print(
          'Failed to get food items: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error getting food items: $e');
      return null;
    }
  }
}
