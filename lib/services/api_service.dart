import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:spicekart/model/cart_list_response.dart';

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
import '../model/user_address.dart';
import '../model/checkout_preview_response.dart';
import '../model/saved_items_response.dart';

class ApiService {
  static const String baseUrl = 'https://spicekart1.mockupz.in/api';
  // static const String baseUrl = 'https://spicekart.mockupz.in/api';
  static String? _accessToken;
  static String? _refreshTokenStr;
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _regionKey = 'selected_region';
  static String? _selectedRegion;

  static Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
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

  static Future<void> logout() async {
    try {
      final url = Uri.parse('$baseUrl/logout');
      print('Logging out at: $url');
      final response = await _postAuthRequest(url);

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
          final data = jsonDecode(response.body);
          if (data['status'] == 1 &&
              data['access_token'] != null &&
              data['refresh_token'] != null) {
            final access = data['access_token'];
            final refresh = data['refresh_token'];
            await _storeTokens(access, refresh);
            // Assuming the API returns user data, we might want to return a User object or similar
            // For now sticking to boolean as per previous contract, but token is saved.
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
        final data = jsonDecode(response.body);
        if (data['status'] == 1 &&
            data['access_token'] != null &&
            data['refresh_token'] != null) {
          final newAccess = data['access_token'];
          final newRefresh = data['refresh_token'];
          await _storeTokens(newAccess, newRefresh);
          print('Token refreshed successfully');
          return true;
        }
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

  static Future<SearchResponse?> searchProducts(
    String search, {
    int? categoryId,
    int? brandId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/searchProducts');
      print(
        'Searching products from: $url with search: $search, category: $categoryId, brand: $brandId and headers: $_headers',
      );

      final Map<String, dynamic> body = {'search': search};
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

  static Future<WeeklyDeals?> getWeekDealsProducts() async {
    try {
      final url = Uri.parse('$baseUrl/getWeekDealsProducts');
      print('Fetching weekly deals from: $url');

      final response = await _postAuthRequest(url);

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

  static Future<bool> addToCart({
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
          'product_id': productId,
          'variant_id': variantId,
          'quantity': quantity,
          'is_saved_for_later': isSavedForLater,
        }),
      );

      if (response.statusCode == 200) {
        print('Add to Cart response: ${response.body}');
        final data = jsonDecode(response.body);
        return data['status'] == 1;
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

  static Future<CartListResponse?> listCartItems() async {
    try {
      final url = Uri.parse('$baseUrl/listCartItems');
      print('Fetching cart items from: $url');

      final response = await _postAuthRequest(url);

      if (response.statusCode == 200) {
        print('List Cart Items response: ${response.body}');
        return cartListResponseFromJson(response.body);
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

  static Future<SavedItemsResponse?> getSavedItemsList() async {
    try {
      final url = Uri.parse('$baseUrl/getSavedItemsList');
      print('Fetching saved items from: $url');

      final response = await _postAuthRequest(url);

      if (response.statusCode == 200) {
        print('Get Saved Items List response: ${response.body}');
        return savedItemsResponseFromJson(response.body);
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
        return data['status'] == 1;
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
        body: jsonEncode({'cart_item_id': cartItemId, 'action': action}),
      );

      if (response.statusCode == 200) {
        print('Update Cart Item response: ${response.body}');
        final data = jsonDecode(response.body);
        return data['status'] == 1;
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

  static Future<bool> deleteCartItem(int cartId) async {
    try {
      final url = Uri.parse('$baseUrl/deleteCartItems');
      print('Deleting cart item at: $url');

      final response = await _postAuthRequest(
        url,
        body: jsonEncode({'cart_item_id': cartId}),
      );

      if (response.statusCode == 200) {
        print('Delete Cart Item response: ${response.body}');
        final data = jsonDecode(response.body);
        return data['status'] == 1;
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
        return data['status'] == 1;
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

      final response = await _postAuthRequest(url);

      if (response.statusCode == 200) {
        print('Cart count response: ${response.body}');
        final data = jsonDecode(response.body);
        if (data['status'] == 1) {
          return data['data'] as int;
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
    required String gateCode,
    required String deliveryNotes,
    required String dropOffLocation,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/updateDeliveryInstructions');
      print('Adding delivery instructions at: $url');

      final response = await _postAuthRequest(
        url,
        body: jsonEncode({
          'property_type_id': propertyTypeId,
          'gate_code': gateCode,
          'delivery_notes': deliveryNotes,
          'drop_off_location': dropOffLocation,
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
  }) async {
    try {
      final url = Uri.parse('$baseUrl/listProducts');
      print(
        'Fetching products from: $url for category: $categoryId, brand: $brandId',
      );

      final Map<String, dynamic> body = {};
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

  static Future<FavouritesListResponse?> listFavourites() async {
    try {
      final url = Uri.parse('$baseUrl/listFavourites');
      print('Fetching favorites from: $url');

      final response = await _postAuthRequest(url);

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

  static Future<BannerProducts?> getBannerProducts(int bannerId) async {
    try {
      final url = Uri.parse('$baseUrl/getBannerProducts');
      print('Fetching banner products from: $url for banner_id: $bannerId');

      final response = await http.post(
        url,
        headers: _headersNoAuth,
        body: jsonEncode({'banner_id': bannerId}),
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

  static Future<OrderHistoryResponse?> listOrders() async {
    try {
      final url = Uri.parse('$baseUrl/listOrders');
      print('Fetching order history from: $url');

      final response = await _postAuthRequest(url);

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
    required String country,
    required String postalCode,
    required String addressType,
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

  static Future<CheckoutPreviewResponse?> checkoutPreview() async {
    try {
      final url = Uri.parse('$baseUrl/checkoutPreview');
      print('Fetching checkout preview from: $url');

      final response = await _postAuthRequest(url);

      if (response.statusCode == 200) {
        print('Checkout Preview response: ${response.body}');
        return checkoutPreviewResponseFromJson(response.body);
      } else {
        print('Failed to get checkout preview: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error getting checkout preview: $e');
      return null;
    }
  }

  static Future<bool> applyTip(int tipPercent) async {
    try {
      final url = Uri.parse('$baseUrl/applyTip');
      print('Applying tip at: $url with tip_percent: $tipPercent');

      final response = await _postAuthRequest(url, body: jsonEncode({
        'tip_percent': tipPercent,
      }));

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

  static Future<bool> applyCoupon(String couponCode) async {
    try {
      final url = Uri.parse('$baseUrl/applyCoupon');
      print('Applying coupon at: $url with coupon_code: $couponCode');

      final response = await _postAuthRequest(url, body: jsonEncode({
        'coupon_code': couponCode,
      }));

      if (response.statusCode == 200) {
        print('Apply Coupon response: ${response.body}');
        final data = jsonDecode(response.body);
        return data['status'] == 1;
      } else {
        print('Failed to apply coupon: ${response.statusCode} - ${response.body}');
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

      final response = await _postAuthRequest(url);

      if (response.statusCode == 200) {
        print('Remove Coupon response: ${response.body}');
        final data = jsonDecode(response.body);
        return data['status'] == 1;
      } else {
        print('Failed to remove coupon: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error removing coupon: $e');
      return false;
    }
  }

  static Future<String?> createStripePaymentIntent({required double amount}) async {
    try {
      // TODO: Replace with your actual backend endpoint to create a PaymentIntent
      // Request should hit your server with the amount, and return a JSON like:
      // { "client_secret": "pi_3M..." }
      
      final url = Uri.parse('$baseUrl/createPaymentIntent');
      print('Creating Stripe Payment Intent at: $url for amount: \$${amount.toStringAsFixed(2)}');

      final response = await _postAuthRequest(url, body: jsonEncode({
        'amount': amount,
        'currency': 'usd', // or your target currency
      }));

      if (response.statusCode == 200) {
        print('Create Payment Intent response: ${response.body}');
        final data = jsonDecode(response.body);
        
        // This key will vary depending on your backend developer's exact implementation
        if (data['data'] != null && data['data']['client_secret'] != null) {
           return data['data']['client_secret'];
        } else if (data['client_secret'] != null) {
           return data['client_secret']; // Alternative fallback
        }
        return null;
      } else {
        print('Failed to create payment intent: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
    }
  }

  static Future<bool> updateUserTimezone(String timezone) async {
    try {
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
        print('Failed to update timezone: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updating timezone: $e');
      return false;
    }
  }

  static Future<List<dynamic>?> listDeliverySlots() async {
    try {
      final url = Uri.parse('$baseUrl/listDeliverySlots');
      print('Fetching delivery slots from: $url');

      final response = await _postAuthRequest(url);

      if (response.statusCode == 200) {
        print('List Delivery Slots response: ${response.body}');
        final data = jsonDecode(response.body);
        if (data['status'] == 1 && data['data'] != null) {
          return data['data'] as List<dynamic>;
        }
        return [];
      } else {
        print('Failed to get delivery slots: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error getting delivery slots: $e');
      return null;
    }
  }

  static Future<bool> sendCheckoutPhoneOtp(String phone) async {
    try {
      final url = Uri.parse('$baseUrl/sendCheckoutPhoneOtp');
      print('Sending checkout phone OTP for: $phone');

      final response = await _postAuthRequest(
        url,
        body: jsonEncode({'phone': phone}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 1;
      } else {
        print('Failed to send checkout phone OTP: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error sending checkout phone OTP: $e');
      return false;
    }
  }

  static Future<bool> verifyCheckoutPhoneOtp(String phone, String otp) async {
    try {
      final url = Uri.parse('$baseUrl/verifyCheckoutPhoneOtp');
      print('Verifying checkout phone OTP: $otp for: $phone');

      final response = await _postAuthRequest(
        url,
        body: jsonEncode({'phone': phone, 'otp': otp}),
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
}
