import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:spicekart/controllers/main_controller.dart';
import 'package:spicekart/screens/checkout_screen.dart';
import 'package:spicekart/screens/user_address_list_screen.dart';
import '../utils/app_theme.dart';
import 'package:spicekart/model/cart_list_response.dart';
import 'package:spicekart/model/saved_items_response_product.dart'
    as saved_model;
import 'package:spicekart/services/api_service.dart';
import 'delivery_instructions_screen.dart';
import 'home_screen.dart';
import 'categories_screen.dart';
import 'hot_food_screen.dart';
import '../utils/guest_checker.dart';
import '../model/usuals_response.dart' as usuals;
import 'usual_items_screen.dart';
import 'product_detail_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../controllers/cart_controller.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<dynamic> _cartItems = [];
  List<dynamic> _savedItems = [];
  List<usuals.Datum> _usualItems = [];
  bool _isLoading = true;
  bool _isProcessingAction = false;
  final Map<int, usuals.Variant> _selectedUsualVariants = {};
  final Set<int> _addingSavedItemIds = {};
  final Set<int> _addingUsualProductIds = {};
  StreamSubscription? _refreshSubscription;

  int _apiCartCount = 0;

  Widget _buildCartIconWithBadge({required int count}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.shopping_cart, size: 28, color: Color(0xFF4D555C)),
        if (count > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white, width: 2),
              ),
              constraints: const BoxConstraints(minWidth: 18),
              child: Text(
                count > 99 ? '99+' : '$count',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                ),
              ),
            ),
          ),
      ],
    );
  }

  double _calculateCartTotal() {
    double total = 0.0;
    for (final item in _cartItems) {
      final bool isProduct = item.itemType == 'product';
      final String priceStr = isProduct
          ? (item.variant?.productPrice ?? "0.00")
          : item.item.price;
      final double price = double.tryParse(priceStr.toString()) ?? 0.0;
      total += price * (item.quantity as int);
    }
    return total;
  }

  @override
  void initState() {
    super.initState();
    _fetchCartItems();

    // Listen for refresh signal from the bottom navigation bar
    _refreshSubscription = CartController.to.refreshSignal.listen((_) {
      if (mounted) {
        _fetchCartItems(quiet: true); // Use quiet refresh for tab selection
      }
    });
  }

  @override
  void dispose() {
    _refreshSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchCartItems({bool quiet = false}) async {
    if (quiet) {
      setState(() => _isProcessingAction = true);
    } else {
      setState(() => _isLoading = true);
    }
    try {
      final cartResponseFuture = ApiService.listCartItems();
      final savedResponseFuture = ApiService.getSavedItemsList();
      final usualsResponseFuture = ApiService.listUsualItems();
      final cartCountFuture = ApiService.getCartCount();

      final results = await Future.wait([
        cartResponseFuture,
        savedResponseFuture,
        usualsResponseFuture,
        cartCountFuture,
      ]);
      final dynamic cartResponse = results[0];
      final dynamic savedResponse = results[1];
      final usualsResponse = results[2] as usuals.UsualsResponse?;
      final int cartCount = results[3] as int;

      setState(() {
        _apiCartCount = cartCount;
        if (cartResponse != null && cartResponse.status == 1) {
          _cartItems = cartResponse.data
              .where((item) => item.isSavedForLater == 0)
              .toList();
        } else {
          _cartItems = [];
        }

        if (savedResponse != null && savedResponse.status == 1) {
          _savedItems = savedResponse.data;
        } else {
          _savedItems = [];
        }

        if (usualsResponse != null && usualsResponse.status == 1) {
          _usualItems = usualsResponse.data;
        } else {
          _usualItems = [];
        }
        _isLoading = false;
        _isProcessingAction = false;
      });
    } catch (e) {
      debugPrint('Error fetching cart items: $e');
      setState(() {
        _isLoading = false;
        _isProcessingAction = false;
      });
    }
  }

  Future<void> _updateCartItem(int cartItemId, String action) async {
    // Optimistic Update
    final index = _cartItems.indexWhere((item) => item.id == cartItemId);
    if (index == -1) return;

    final originalItem = _cartItems[index];

    if (action == 'decrement' && originalItem.quantity <= 1) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quantity cannot be less than 1. Use delete instead.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      if (action == 'increment') {
        _cartItems[index] = Datum(
          id: originalItem.id,
          quantity: originalItem.quantity + 1,
          isSavedForLater: originalItem.isSavedForLater,
          variant: originalItem.variant,
          itemType: originalItem.itemType,
          item: originalItem.item,
        );
      } else if (action == 'decrement') {
        _cartItems[index] = Datum(
          id: originalItem.id,
          quantity: originalItem.quantity - 1,
          isSavedForLater: originalItem.isSavedForLater,
          variant: originalItem.variant,
          itemType: originalItem.itemType,
          item: originalItem.item,
        );
      }
    });

    setState(() => _isProcessingAction = true);
    try {
      final success = await ApiService.updateCartItem(
        cartItemId: cartItemId,
        action: action,
      );
      if (success) {
        setState(() => _isProcessingAction = false);
        _fetchCartItems(quiet: true);
      } else {
        // Revert on failure
        setState(() {
          _isProcessingAction = false;
          _cartItems[index] = originalItem;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update quantity')),
        );
      }
    } catch (e) {
      debugPrint('Error updating cart item: $e');
      setState(() {
        _isProcessingAction = false;
        _cartItems[index] = originalItem;
      });
    }
  }

  Future<void> _deleteItem(int cartId) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text(
          'Are you sure you want to remove this item from your cart?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final index = _cartItems.indexWhere((item) => item.id == cartId);
      if (index == -1) return;
      final originalItem = _cartItems[index];

      setState(() {
        _isProcessingAction = true;
        _cartItems.removeAt(index);
      });

      try {
        final success = await ApiService.deleteCartItem(
          cartId: cartId,
        );
        if (success) {
          setState(() => _isProcessingAction = false);
          _fetchCartItems(quiet: true);
        } else {
          // Revert on failure
          setState(() {
            _cartItems.insert(index, originalItem);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete item')),
          );
        }
      } catch (e) {
        debugPrint('Error deleting item: $e');
        setState(() {
          _cartItems.insert(index, originalItem);
        });
      }
    }
  }

  Future<void> _deleteSavedItem(dynamic item) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Saved Item'),
        content: const Text(
          'Are you sure you want to remove this item from your saved items?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final index = _savedItems.indexWhere((i) => i.id == item.id);
      if (index == -1) return;
      final originalItem = _savedItems[index];

      setState(() {
        _isProcessingAction = true;
        _savedItems.removeAt(index);
      });

      try {
        final success = await ApiService.deleteCartItem(
          cartId: item.id,
        );
        if (success) {
          setState(() => _isProcessingAction = false);
          _fetchCartItems(quiet: true);
        } else {
          // Revert on failure
          setState(() {
            _isProcessingAction = false;
            _savedItems.insert(index, originalItem);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete saved item')),
          );
        }
      } catch (e) {
        debugPrint('Error deleting saved item: $e');
        setState(() {
          _isProcessingAction = false;
          _savedItems.insert(index, originalItem);
        });
      }
    }
  }

  Future<void> _toggleSaveForLater(dynamic item, int isSaved) async {
    // Note: 'item' could be from _cartItems (Datum) or _savedItems (saved_model.Datum)
    // Both have .id, .product, .variant, .quantity

    final originalCartItems = List<dynamic>.from(_cartItems);
    final originalSavedItems = List<dynamic>.from(_savedItems);

    setState(() {
      if (isSaved == 1) {
        _isProcessingAction = true;
        // Move from Cart to Saved
        _cartItems.removeWhere((i) => i.id == item.id);
      } else {
        // Move from Saved to Cart (adding saved item to cart)
        // Show loading indicator on button instead of global loader
        _addingSavedItemIds.add(item.id);
      }
    });

    try {
      final bool isProduct = item.itemType == 'product';
      bool success = false;

      if (isProduct) {
        success = await ApiService.addProductToCart(
          productId: item.item.id,
          variantId: item.variant.id,
          quantity: item.quantity,
          isSavedForLater: isSaved,
        );
      } else {
        // Food items
        success = await ApiService.addFoodToCart(
          itemId: item.item.id,
          quantity: item.quantity,
          restaurantId: item.item.restaurant.id,
          restaurantName: item.item.restaurant.name,
          restaurantAddress: item.item.restaurant.address,
          isSavedForLater: isSaved,
        );
      }

      if (success) {
        setState(() {
          if (isSaved == 1) {
            _isProcessingAction = false;
          } else {
            _addingSavedItemIds.remove(item.id);
            _savedItems.removeWhere((i) => i.id == item.id);
          }
        });
        _fetchCartItems(quiet: true);
      } else {
        // Revert on failure
        setState(() {
          if (isSaved == 1) {
            _isProcessingAction = false;
            _cartItems = originalCartItems;
            _savedItems = originalSavedItems;
          } else {
            _addingSavedItemIds.remove(item.id);
          }
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to save item')));
      }
    } catch (e) {
      debugPrint('Error toggling save for later: $e');
      setState(() {
        if (isSaved == 1) {
          _isProcessingAction = false;
          _cartItems = originalCartItems;
          _savedItems = originalSavedItems;
        } else {
          _addingSavedItemIds.remove(item.id);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppTheme.instance,
      builder: (context, _) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: Column(
                      children: [
                        // Top row with Back and Checkout button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Builder(
                              builder: (context) {
                                // ModalRoute.of(context)?.canPop correctly resolves
                                // to the navigator that owns this CartScreen instance —
                                // whether it's the tab 4 nested navigator (root = can't pop)
                                // or the root GetX navigator (pushed standalone = can pop).
                                final canPop =
                                    ModalRoute.of(context)?.canPop ?? false;
                                return TextButton(
                                  onPressed: canPop
                                      ? () => Navigator.of(context).pop()
                                      : null,
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Back',
                                    style: TextStyle(
                                      color: canPop
                                          ? const Color(0xFF4D555C)
                                          : Colors.transparent,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              },
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                if (!GuestChecker.check()) return;
                                if (_cartItems.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'There is no cart items to proceed',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                setState(() => _isProcessingAction = true);
                                try {
                                  final response =
                                      await ApiService.listUserAddresses();

                                  bool hasAddresses = false;
                                  int? selectedAddressId;

                                  if (response != null &&
                                      response.data != null &&
                                      response.data!.isNotEmpty) {
                                    hasAddresses = true;
                                    final defaultAddr = response.data!
                                        .where((a) => a.isDefault)
                                        .toList();
                                    if (defaultAddr.isNotEmpty) {
                                      selectedAddressId =
                                          defaultAddr.first.addressId;
                                    } else {
                                      selectedAddressId =
                                          response.data!.first.addressId;
                                    }
                                  }

                                  if (hasAddresses &&
                                      selectedAddressId != null) {
                                    final success =
                                        await ApiService.updateCheckoutAddress(
                                          addressId: selectedAddressId,
                                        );

                                    if (success && mounted) {
                                      final instructions =
                                          await ApiService.getDeliveryInstructions();
                                      bool hasInstructions = false;
                                      if (instructions != null &&
                                          instructions['status'] == 1) {
                                        final data = instructions['data'];
                                        if (data != null &&
                                            data['property_type_id'] != null &&
                                            data['property_type_id'] > 0) {
                                          hasInstructions = true;
                                        }
                                      }

                                      if (!mounted) return;
                                      setState(
                                        () => _isProcessingAction = false,
                                      );

                                      if (hasInstructions) {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const CheckoutScreen(),
                                          ),
                                        );
                                      } else {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const DeliveryInstructionsScreen(
                                                  isInitialFlow: true,
                                                ),
                                          ),
                                        );
                                      }
                                      if (mounted) {
                                        _fetchCartItems(quiet: true);
                                      }
                                    } else if (mounted) {
                                      setState(
                                        () => _isProcessingAction = false,
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Failed to update address',
                                          ),
                                        ),
                                      );
                                    }
                                  } else {
                                    if (!mounted) return;
                                    setState(() => _isProcessingAction = false);
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const UserAddressListScreen(
                                              isFromCheckout: true,
                                              isInitialFlow: true,
                                            ),
                                      ),
                                    );
                                    if (mounted) {
                                      _fetchCartItems(quiet: true);
                                    }
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    setState(() => _isProcessingAction = false);
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.instance.mutedColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'PROCEED TO CHECKOUT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontFamily: 'ITC Avant Garde Gothic Pro',
                                  fontWeight: FontWeight.w600,
                                  height: 1.30,
                                  letterSpacing: 0.48,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Your Cart heading with icon
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Your Cart',
                          style: TextStyle(
                            color: Color(0xFF4D555C),
                            fontSize: 18,
                            fontFamily: 'ITC Avant Garde Gothic Pro',
                            fontWeight: FontWeight.w600,
                            height: 1.30,
                            letterSpacing: -0.54,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildCartIconWithBadge(count: _apiCartCount),
                            if (_cartItems.isNotEmpty) ...
                              [
                                const SizedBox(height: 4),
                                Text(
                                  'Total: \$${_calculateCartTotal().toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Color(0xFF4D555C),
                                    fontSize: 13,
                                    fontFamily: 'ITC Avant Garde Gothic Pro',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Cart Items List and Saved Items
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Cart Items List
                                if (_cartItems.isNotEmpty) ...[
                                  Builder(builder: (context) {
                                    final products = _cartItems.where((item) => item.itemType == 'product').toList();
                                    final foods = _cartItems.where((item) => item.itemType == 'food').toList();
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (products.isNotEmpty)
                                          ListView.builder(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                                            itemCount: products.length,
                                            itemBuilder: (context, index) {
                                              return _buildCartItemCard(
                                                products[index],
                                              );
                                            },
                                          ),
                                        if (foods.isNotEmpty) ...[
                                          Padding(
                                            padding: EdgeInsets.only(
                                              left: 16,
                                              right: 16,
                                              top: products.isNotEmpty ? 8 : 16,
                                              bottom: 12,
                                            ),
                                            child: const Text(
                                              'Hot foods',
                                              style: TextStyle(
                                                color: Color(0xFF4D555C),
                                                fontSize: 16,
                                                fontFamily:
                                                    'ITC Avant Garde Gothic Pro',
                                                fontWeight: FontWeight.w600,
                                                height: 1.30,
                                                letterSpacing: -0.48,
                                              ),
                                            ),
                                          ),
                                          ListView.builder(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                            itemCount: foods.length,
                                            itemBuilder: (context, index) {
                                              return _buildCartItemCard(
                                                foods[index],
                                              );
                                            },
                                          ),
                                        ],
                                      ],
                                    );
                                  }),
                                ]
                                else
                                  Container(
                                    margin: const EdgeInsets.all(16),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 40,
                                      horizontal: 20,
                                    ),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                          'assets/images/box.png', // Using available box.png as a placeholder for empty cart
                                          width: 120,
                                          height: 120,
                                          color: Colors.grey.shade300,
                                        ),
                                        const SizedBox(height: 20),
                                        const Text(
                                          'Your cart is empty',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Color(0xFF4D555C),
                                            fontSize: 18,
                                            fontFamily:
                                                'ITC Avant Garde Gothic Pro',
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Looks like you haven\'t added anything yet.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Color(0xFF7A8D7C),
                                            fontSize: 14,
                                            fontFamily:
                                        'ITC Avant Garde Gothic Pro',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                // Don't Forget Your Usuals Section
                                if (_usualItems.isNotEmpty) ...[
                                  _buildUsualsSection(),
                                  const SizedBox(height: 16),
                                ],
                                // Your Saved Items Section
                                if (_savedItems.isNotEmpty) ...[
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    decoration: ShapeDecoration(
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          child: const Text(
                                            'Your Saved Items',
                                            style: TextStyle(
                                              color: Color(0xFF4D555C),
                                              fontSize: 16,
                                              fontFamily:
                                                  'ITC Avant Garde Gothic Pro',
                                              fontWeight: FontWeight.w600,
                                              height: 1.30,
                                              letterSpacing: -0.48,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 180,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                            ),
                                            itemCount: _savedItems.length,
                                            itemBuilder: (context, index) {
                                              return _buildSavedItemCard(
                                                _savedItems[index],
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ],
                            ),
                          ),
                  ),
                ],
              ),
              // Semi-transparent overlay loader
              if (_isProcessingAction)
                Container(
                  color: Colors.black.withOpacity(0.1),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
        );
      },
    );
  }

  Widget _buildCartItemCard(dynamic item) {
    final bool isProduct = item.itemType == 'product';
    final quantity = item.quantity;

    final String name = isProduct ? item.item.productName : item.item.name;
    final String image = isProduct ? item.item.productImage : item.item.image;
    final String size = isProduct
        ? (item.variant?.varientSize ?? "Standard")
        : "Standard";
    final String price = isProduct
        ? (item.variant?.productPrice ?? "0.00")
        : item.item.price;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: AppTheme.instance.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: isProduct
                        ? 'https://spicekart1.mockupz.in/storage/products/$image'
                        : 'https://spicekart1.mockupz.in/storage/food_items/$image',
                    fit: BoxFit.contain,
                    memCacheWidth: 85,
                    fadeInDuration: const Duration(milliseconds: 150),
                    placeholder: (context, url) =>
                        Container(color: AppTheme.instance.backgroundColor),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.image_not_supported),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      name,
                      style: const TextStyle(
                        color: Color(0xFF4D555C),
                        fontSize: 13,
                        fontFamily: 'ITC Avant Garde Gothic Pro',
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Weight
                    if (isProduct)
                      Text(
                        size,
                        style: const TextStyle(
                          color: Color(0xFF4D555C),
                          fontSize: 12,
                          fontFamily: 'ITC Avant Garde Gothic Pro',
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                    // Unit Price
                    Text(
                      '\$$price',
                      style: const TextStyle(
                        color: Color(0xFF4D555C),
                        fontSize: 12,
                        fontFamily: 'ITC Avant Garde Gothic Pro',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Price and Quantity Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Total Price (Quantity * Price)
                  Text(
                    '\$${((double.tryParse(price.toString()) ?? 0.0) * quantity).toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFF171717),
                      fontSize: 15,
                      fontFamily: 'ITC Avant Garde Gothic Pro',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Quantity Selector
                  Container(
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppTheme.instance.secondaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Minus button
                        IconButton(
                          icon: const Icon(
                            Icons.remove,
                            size: 14,
                            color: Color(0xFFffffff),
                          ),
                          onPressed: () =>
                              _updateCartItem(item.id, 'decrement'),
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                        ),
                        // Quantity display
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          constraints: const BoxConstraints(minWidth: 20),
                          child: Text(
                            '$quantity',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                        ),
                        // Plus button
                        IconButton(
                          icon: const Icon(
                            Icons.add,
                            size: 14,
                            color: Color(0xFFffffff),
                          ),
                          onPressed: () =>
                              _updateCartItem(item.id, 'increment'),
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          // Save For Later and Delete buttons
          Row(
            children: [
              GestureDetector(
                onTap: () => _toggleSaveForLater(item, 1),
                child: Container(
                  width: 89,
                  height: 21,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        width: 0.50,
                        color: Color(0x918B9D8D),
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Save for later',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF4D555C),
                        fontSize: 10,
                        fontFamily: 'ITC Avant Garde Gothic Pro',
                        fontWeight: FontWeight.w500,
                        height: 1.30,
                        letterSpacing: 0.10,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _deleteItem(item.id),
                child: Container(
                  width: 50,
                  height: 21,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        width: 0.50,
                        color: Color(0x918B9D8D),
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Delete',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF4D555C),
                        fontSize: 10,
                        fontFamily: 'ITC Avant Garde Gothic Pro',
                        fontWeight: FontWeight.w500,
                        height: 1.30,
                        letterSpacing: 0.10,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSavedItemCard(dynamic item) {
    final bool isProduct = item.itemType == 'product';
    final bool isFood = item.itemType == 'food';

    final String name = isProduct ? item.item.productName : item.item.name;
    final String image = isProduct ? item.item.productImage : item.item.image;
    final String price = isProduct
        ? (item.variant.storePrice ?? item.variant.productPrice).toString()
        : item.item.price;

    return Container(
      width: 140,
      height: 180,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Product Image Container with Badge and Add Button
          SizedBox(
            width: 140,
            height: 110,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Image background container
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const ShapeDecoration(
                    color: Color(0xFFF9F9F9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(2)),
                    ),
                  ),
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: isProduct
                          ? 'https://spicekart1.mockupz.in/storage/products/$image'
                          : 'https://spicekart1.mockupz.in/storage/food_items/$image',
                      fit: BoxFit.contain,
                      memCacheWidth: 85,
                      fadeInDuration: const Duration(milliseconds: 150),
                      placeholder: (context, url) =>
                          Container(color: const Color(0xFFF9F9F9)),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
                // Delete button (top-left corner - extending outside)
                Positioned(
                  top: -4,
                  left: -4,
                  child: GestureDetector(
                    onTap: () => _deleteSavedItem(item),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                            width: 1,
                            color: Colors.red,
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 16,
                      ),
                    ),
                  ),
                ),
                // Move to cart button (corner - extending outside)
                Positioned(
                  bottom: -4,
                  right: -4,
                  child: GestureDetector(
                    onTap: () {
                      if (_addingSavedItemIds.contains(item.id)) return;
                      _toggleSaveForLater(item, 0);
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: ShapeDecoration(
                        color: _addingSavedItemIds.contains(item.id)
                            ? const Color(0xFF4EAEF7)
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                            width: 1,
                            color: Color(0xFF4EAEF7),
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      child: _addingSavedItemIds.contains(item.id)
                          ? const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.add,
                              color: Color(0xFF4EAEF7),
                              size: 16,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          // Price
          Text(
            '\$$price',
            style: const TextStyle(
              color: Color(0xFF4D555C),
              fontSize: 12,
              fontFamily: 'ITC Avant Garde Gothic Pro',
              fontWeight: FontWeight.w500,
            ),
          ),
          // Product Name
          Text(
            name,
            style: const TextStyle(
              color: Color(0xFF4D555C),
              fontSize: 11,
              fontFamily: 'ITC Avant Garde Gothic Pro',
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          // Quantity with dropdown (Size)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  isProduct
                      ? (item as saved_model.Datum).variant?.varientSize ?? "Standard"
                      : isFood
                      ? (item.variant?.toString() ?? "Standard")
                      : "Standard",
                  style: const TextStyle(
                    color: Color(0xFF4EAEF7),
                    fontSize: 11,
                    fontFamily: 'ITC Avant Garde Gothic Pro',
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(
                Icons.arrow_drop_down,
                size: 12,
                color: Color(0xFF4EAEF7),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsualsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              "Don't Forget Your Usuals",
              style: TextStyle(
                color: Color(0xFF4D555C),
                fontSize: 18,
                fontFamily: 'ITC Avant Garde Gothic Pro',
                fontWeight: FontWeight.w600,
                height: 1.30,
                letterSpacing: -0.54,
              ),
            ),
          ),
          SizedBox(
            height: 230,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _usualItems.length,
              itemBuilder: (context, index) {
                return _buildUsualProductCard(_usualItems[index]);
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildUsualProductCard(usuals.Datum usualItem) {
    final product = usualItem.item;
    final isFood = usualItem.itemType == 'food';
    final variant =
        _selectedUsualVariants[product.id] ??
        (product.variants.isNotEmpty ? product.variants.first : null);

    final price = variant != null ? '\$${variant.productPrice}' : '\$0.00';
    final weight = variant != null ? variant.varientSize : 'N/A';

    return GestureDetector(
      onTap: () {
        if (!isFood) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(productId: product.id),
            ),
          );
        }
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Container
            SizedBox(
              width: 140,
              height: 110,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: ShapeDecoration(
                      color: AppTheme.instance.backgroundColor,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1,
                          color: AppTheme.instance.secondaryColor.withOpacity(
                            0.2,
                          ),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Center(
                      child: product.productImage.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: isFood
                                  ? 'https://spicekart1.mockupz.in/storage/food_items/${product.productImage}'
                                  : 'https://spicekart1.mockupz.in/storage/products/${product.productImage}',
                              fit: BoxFit.contain,
                              memCacheWidth: 85,
                              fadeInDuration: const Duration(milliseconds: 150),
                              placeholder: (context, url) => Container(
                                color: AppTheme.instance.backgroundColor,
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.image, color: Colors.grey),
                            )
                          : const Icon(Icons.image, color: Colors.grey),
                    ),
                  ),
                  // Add button
                  Positioned(
                    bottom: -4,
                    right: -4,
                    child: GestureDetector(
                      onTap: () {
                        if (variant == null) return;
                        if (_addingUsualProductIds.contains(product.id)) return;
                        _addUsualToCart(usualItem, variant);
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _addingUsualProductIds.contains(product.id)
                              ? AppTheme.instance.secondaryColor
                              : Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: AppTheme.instance.secondaryColor,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: _addingUsualProductIds.contains(product.id)
                            ? const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                Icons.add,
                                color: AppTheme.instance.secondaryColor,
                                size: 16,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Price
            Text(
              price,
              style: const TextStyle(
                color: Color(0xFF171717),
                fontSize: 15,
                fontWeight: FontWeight.w600,
                fontFamily: 'ITC Avant Garde Gothic Pro',
              ),
            ),
            const SizedBox(height: 4),
            // Product Name
            Text(
              product.productName,
              style: const TextStyle(
                color: Color(0xFF4D555C),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontFamily: 'ITC Avant Garde Gothic Pro',
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Variant dropdown-like row
            isFood
                ? Text(
                    weight,
                    style: TextStyle(
                      color: AppTheme.instance.secondaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'ITC Avant Garde Gothic Pro',
                    ),
                  )
                : GestureDetector(
                    onTap: () => _showUsualVariantPicker(product),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          weight,
                          style: TextStyle(
                            color: AppTheme.instance.secondaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'ITC Avant Garde Gothic Pro',
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 16,
                          color: AppTheme.instance.secondaryColor,
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _addUsualToCart(
    usuals.Datum usualItem,
    usuals.Variant variant,
  ) async {
    final product = usualItem.item;
    final isFood = usualItem.itemType == 'food';
    if (!GuestChecker.check(
      action: PendingAction(
        type: PendingActionType.cart,
        productId: product.id,
        variantId: variant.id,
        quantity: 1,
      ),
    )) {
      return;
    }

    setState(() {
      _addingUsualProductIds.add(product.id);
    });

    try {
      final success = isFood
          ? await ApiService.addFoodToCart(
              itemId: product.id,
              quantity: 1,
              restaurantId: product.restaurant?.id ?? 0,
              restaurantName: product.restaurant?.name ?? "",
              restaurantAddress: product.restaurant?.address ?? "",
            )
          : await ApiService.addProductToCart(
              productId: product.id,
              variantId: variant.id,
              quantity: 1,
            );
      if (success) {
        setState(() => _addingUsualProductIds.remove(product.id));
        await _fetchCartItems(quiet: true);
        if (!mounted) return;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            content: Text('${product.productName} added to cart'),
          ),
        );
      } else {
        setState(() {
          _addingUsualProductIds.remove(product.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add usual item to cart')),
        );
      }
    } catch (e) {
      debugPrint('Error adding usual to cart: $e');
      setState(() {
        _addingUsualProductIds.remove(product.id);
      });
    }
  }


  void _showUsualVariantPicker(usuals.Item product) {
    if (product.variants.isEmpty) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Variant',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF374338),
                  fontFamily: 'ITC Avant Garde Gothic Pro',
                ),
              ),
              const SizedBox(height: 10),
              ...product.variants.map((v) {
                final isSelected =
                    (_selectedUsualVariants[product.id]?.id ??
                        product.variants.first.id) ==
                    v.id;
                return ListTile(
                  title: Text(v.varientSize),
                  trailing: Text('\$${v.productPrice}'),
                  selected: isSelected,
                  selectedTileColor: AppTheme.instance.backgroundColor,
                  onTap: () {
                    setState(() {
                      _selectedUsualVariants[product.id] = v;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: 50),
            ],
          ),
        );
      },
    );
  }
}
