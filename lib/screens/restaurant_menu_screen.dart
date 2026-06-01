import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/app_theme.dart';
import '../services/api_service.dart';
import '../model/resturant_menu_response.dart';
import '../controllers/cart_controller.dart';

class RestaurantMenuScreen extends StatefulWidget {
  final String restaurantName;
  final int restaurantId;

  const RestaurantMenuScreen({
    super.key,
    required this.restaurantName,
    required this.restaurantId,
  });

  @override
  State<RestaurantMenuScreen> createState() => _RestaurantMenuScreenState();
}

class _RestaurantMenuScreenState extends State<RestaurantMenuScreen> {
  final CartController cartController = Get.find<CartController>();
  List<Datum> _menuItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMenu();
  }

  @override
  void dispose() {
    super.dispose();
  }



  Future<void> _fetchMenu() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.getFoodItems(
        restaurantId: widget.restaurantId,
      );

      if (response != null && response.status == 1) {
        setState(() {
          _menuItems = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching menu: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F7),
        body: SafeArea(
          child: Column(
            children: [
              // Custom Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          'Back',
                          style: TextStyle(
                            color: Color(0xFF4D555C),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'ITC Avant Garde Gothic Pro',
                          ),
                        ),
                      ),
                    ),
                    Text(
                      widget.restaurantName,
                      style: const TextStyle(
                        color: Color(0xFF4D555C),
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'ITC Avant Garde Gothic Pro',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Menu List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _menuItems.isEmpty
                        ? const Center(child: Text('No menu items available'))
                        : RefreshIndicator(
                            onRefresh: () => _fetchMenu(),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _menuItems.length,
                              itemBuilder: (context, index) {
                                return _buildMenuItemCard(_menuItems[index]);
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItemCard(Datum item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: 'https://spicekart1.mockupz.in/storage/food_items/${item.image}',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey.shade100,
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.fastfood, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      color: Color(0xFF374338),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'ITC Avant Garde Gothic Pro',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: const TextStyle(
                      color: Color(0xFF7F858A),
                      fontSize: 13,
                      fontFamily: 'ITC Avant Garde Gothic Pro',
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${item.price}',
                        style: const TextStyle(
                          color: Color(0xFF374338),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'ITC Avant Garde Gothic Pro',
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final success = await ApiService.addFoodToCart(
                            itemId: item.id,
                            quantity: 1,
                            restaurantId: item.restaurant.id,
                            restaurantName: item.restaurant.name,
                            restaurantAddress: item.restaurant.address,
                          );

                          if (success) {
                            Get.snackbar(
                              'Added to Cart',
                              '${item.name} added to your basket',
                              backgroundColor: AppTheme.instance.primaryColor,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          } else {
                            Get.snackbar(
                              'Failed to Add',
                              'Could not add ${item.name} to cart',
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          }
                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.instance.secondaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Add to Cart',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
