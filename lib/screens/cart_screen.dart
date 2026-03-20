import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme.dart';
import 'package:spicekart/model/cart_list_response.dart';
import 'package:spicekart/model/saved_items_response.dart' as saved_model;
import 'package:spicekart/services/api_service.dart';
import 'delivery_instructions_screen.dart';
import 'home_screen.dart';
import 'categories_screen.dart';
import 'hot_food_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int _currentIndex = 4; // Cart is at index 4
  List<Datum> _cartItems = [];
  List<saved_model.Datum> _savedItems = [];
  bool _isLoading = true;
  int _cartCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchCartItems();
    _fetchCartCount();
    _fetchCartCount();
  }

  Future<void> _fetchCartCount() async {
    final count = await ApiService.getCartCount();
    setState(() {
      _cartCount = count;
    });
  }

  Future<void> _fetchCartItems() async {
    setState(() => _isLoading = true);
    try {
      final cartResponseFuture = ApiService.listCartItems();
      final savedResponseFuture = ApiService.getSavedItemsList();

      final results = await Future.wait([cartResponseFuture, savedResponseFuture]);
      final cartResponse = results[0] as CartListResponse?;
      final savedResponse = results[1] as saved_model.SavedItemsResponse?;

      setState(() {
        if (cartResponse != null && cartResponse.status == 1) {
          _cartItems = cartResponse.data.where((item) => item.isSavedForLater == 0).toList();
        } else {
          _cartItems = [];
        }

        if (savedResponse != null && savedResponse.status == 1) {
          _savedItems = savedResponse.data;
        } else {
          _savedItems = [];
        }
        _isLoading = false;
      });
      _fetchCartCount();
    } catch (e) {
      print('Error fetching cart items: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateCartItem(int cartItemId, String action) async {
    try {
      final success = await ApiService.updateCartItem(
        cartItemId: cartItemId,
        action: action,
      );
      if (success) {
        _fetchCartItems();
      }
    } catch (e) {
      print('Error updating cart item: $e');
    }
  }

  Future<void> _deleteItem(int cartId) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to remove this item from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'DELETE',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final success = await ApiService.deleteCartItem(cartId);
        if (success) {
          _fetchCartItems();
        }
      } catch (e) {
        print('Error deleting item: $e');
      }
    }
  }

  Future<void> _toggleSaveForLater(dynamic item, int isSaved) async {
    try {
      final success = await ApiService.addToCart(
        productId: item.product.id,
        variantId: item.variant.id,
        quantity: item.quantity,
        isSavedForLater: isSaved,
      );
      if (success) {
        _fetchCartItems();
      }
    } catch (e) {
      print('Error toggling save for later: $e');
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
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  // Top row with Back and Checkout button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (Navigator.canPop(context))
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Back',
                            style: TextStyle(
                              color: Color(0xFF4D555C),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      if (!Navigator.canPop(context))
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Back',
                          style: TextStyle(
                            color: Colors.transparent,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_cartItems.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('There is no cart items to proceed'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DeliveryInstructionsScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.instance.mutedBlue,
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
            // Your Cart heading with icon
            Padding(
              padding: const EdgeInsets.only(left: 16,right: 16,top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your Cart',
                    style: TextStyle(
                      color:  Color(0xFF4D555C),
                      fontSize: 18,
                      fontFamily: 'ITC Avant Garde Gothic Pro',
                      fontWeight: FontWeight.w600,
                      height: 1.30,
                      letterSpacing: -0.54,
                    ),
                  ),
                  Stack(
                    children: [
                      const Icon(
                        Icons.shopping_cart,
                        size: 28,
                        color: Color(0xFF4D555C),
                      ),
                      if (_cartCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              _cartCount > 9 ? '9+' : '$_cartCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
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
                          if (_cartItems.isNotEmpty)
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              itemCount: _cartItems.length,
                              itemBuilder: (context, index) {
                                return _buildCartItemCard(_cartItems[index]);
                              },
                            )
                          else
                            Container(
                              margin: const EdgeInsets.all(16),
                              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
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
                                      fontFamily: 'ITC Avant Garde Gothic Pro',
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
                                      fontFamily: 'ITC Avant Garde Gothic Pro',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          // Your Saved Items Section
                          if (_savedItems.isNotEmpty) ...[
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                        fontFamily: 'ITC Avant Garde Gothic Pro',
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
                                        return _buildSavedItemCard(_savedItems[index]);
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
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              if (index == 0) {
                // Home icon tapped
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
                );
              } else if (index == 1) {
                // Categories icon tapped
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const CategoriesScreen()),
                  (route) => false,
                );
              } else if (index == 2) {
                // Hot food icon tapped
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HotFoodScreen()),
                  (route) => false,
                );
              } else if (index == 4) {
                // Cart icon tapped
                if (_currentIndex != index) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                    (route) => false,
                  );
                }
              } else {
                setState(() {
                  _currentIndex = index;
                });
              }
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppTheme.instance.mutedBlue,
            unselectedItemColor: Colors.grey,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.grid_view),
                label: 'Categories',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.restaurant),
                label: 'Hot food',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.refresh),
                label: 'Usuals',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    const Icon(Icons.shopping_cart),
                    if (_cartCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            _cartCount > 9 ? '9+' : '$_cartCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                label: 'Cart',
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildCartItemCard(Datum item) {
    final quantity = item.quantity;
    final product = item.product;
    final variant = item.variant;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.instance.lightBlueBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    'https://spicekart.mockupz.in/storage/products/${product.productImage}',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
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
                      product.productName,
                      style: const TextStyle(
                        color: Color(0xFF4D555C),
                        fontSize: 15,
                        fontFamily: 'ITC Avant Garde Gothic Pro',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Weight
                    Text(
                      variant.varientSize,
                      style: const TextStyle(
                        color: Color(0xFF4D555C),
                        fontSize: 12,
                        fontFamily: 'ITC Avant Garde Gothic Pro',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Unit Price
                    Text(
                      '\$${variant.productPrice}',
                      style: const TextStyle(
                        color: Color(0xFF4D555C),
                        fontSize: 12,
                        fontFamily: 'ITC Avant Garde Gothic Pro',
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.lineThrough,
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
                    '\$${(double.parse(variant.productPrice) * quantity).toStringAsFixed(2)}',
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
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.instance.secondaryLightBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Minus button
                        IconButton(
                          icon: const Icon(
                            Icons.remove,
                            size: 16,
                            color: Color(0xFFffffff),
                          ),
                          onPressed: () => _updateCartItem(item.id, 'decrement'),
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(
                            minWidth: 28,
                            minHeight: 28,
                          ),
                        ),
                        // Quantity display
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          constraints: const BoxConstraints(minWidth: 20),
                          child: Text(
                            '$quantity',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                        ),
                        // Plus button
                        IconButton(
                          icon: const Icon(
                            Icons.add,
                            size: 16,
                            color: Color(0xFFffffff),
                          ),
                          onPressed: () => _updateCartItem(item.id, 'increment'),
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(
                            minWidth: 28,
                            minHeight: 28,
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

  Widget _buildSavedItemCard(saved_model.Datum item) {
    final product = item.product;
    final variant = item.variant;

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
                  decoration:  ShapeDecoration(
                    color: AppTheme.instance.lightBlueBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(2)),
                    ),
                  ),
                  child: Center(
                    child: Image.network(
                      'https://spicekart.mockupz.in/storage/products/${product.productImage}',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
                // Discount badge placeholder
                /*if (item['hasDiscount'] == true)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '20% Off',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),*/
                // Move to cart button (corner - extending outside)
                Positioned(
                  bottom: -4,
                  right: -4,
                  child: GestureDetector(
                    onTap: () => _toggleSaveForLater(item, 0),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                            width: 1,
                            color: Color(0xFF4EAEF7),
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      child: const Icon(
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
            '\$${variant.productPrice}',
            style: const TextStyle(
              color: Color(0xFF4D555C),
              fontSize: 12,
              fontFamily: 'ITC Avant Garde Gothic Pro',
              fontWeight: FontWeight.w500,
            ),
          ),
          // Product Name
          Text(
            product.productName,
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
                  variant.varientSize,
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
}
