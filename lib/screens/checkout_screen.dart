import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spicekart/screens/cart_screen.dart';
import 'package:spicekart/screens/categories_screen.dart';
import 'package:spicekart/screens/home_screen.dart';
import 'package:spicekart/screens/hot_food_screen.dart';
import '../utils/app_theme.dart';
import 'package:spicekart/screens/delivery_instructions_screen.dart';
import 'package:spicekart/screens/payment_method_screen.dart';
import 'package:spicekart/services/api_service.dart';
import 'order_success_screen.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:spicekart/model/cart_list_response.dart';
import 'cart_screen.dart';

import '../model/checkout_preview_response.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _currentIndex = 4; // Cart is at index 4
  String? _selectedDeliverySlot = 'Tomorrow';
  int? _selectedTipPercentage;
  String? _selectedPaymentMethod;
  final TextEditingController _couponController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  bool _isWalletRedeemed = false;
  int _cartCount = 0;
  bool _isLoading = true;
  CheckoutPreviewResponse? _checkoutData;
  List<Datum> _cartItems = [];
  List<dynamic> _deliverySlots = [];
  bool _isOtpSent = false;
  bool _isPhoneVerified = false;
  bool _isVerifyingOtp = false;
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _couponController.dispose();
    _mobileNumberController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchCartCount();
    _fetchCheckoutPreview();
  }

  Future<void> _fetchCheckoutPreview() async {
    setState(() => _isLoading = true);
    
    final checkoutFuture = ApiService.checkoutPreview();
    final cartFuture = ApiService.listCartItems();
    final slotsFuture = ApiService.listDeliverySlots();
    
    final results = await Future.wait([checkoutFuture, cartFuture, slotsFuture]);
    final response = results[0] as CheckoutPreviewResponse?;
    final cartResponse = results[1] as CartListResponse?;
    final slotsResponse = results[2] as List<dynamic>?;

    if (mounted) {
      setState(() {
        _checkoutData = response;
        if (response != null &&
            response.data.totalAmountSummary.tipPercent > 0) {
          _selectedTipPercentage = response.data.totalAmountSummary.tipPercent;
        } else {
          _selectedTipPercentage = null;
        }
        
        if (cartResponse != null && cartResponse.status == 1) {
          _cartItems = cartResponse.data.where((item) => item.isSavedForLater == 0).toList();
        } else {
          _cartItems = [];
        }

        _deliverySlots = slotsResponse ?? [];
        
        if (response != null && response.data.cart.checkoutPhone.isNotEmpty) {
          _mobileNumberController.text = response.data.cart.checkoutPhone;
          // Note: you can optionally pre-set _isPhoneVerified here if standard requires
        }

        _isLoading = false;
      });
    }
  }

  Future<void> _sendOtp() async {
    final phone = _mobileNumberController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a mobile number')));
      return;
    }
    setState(() => _isVerifyingOtp = true);
    final success = await ApiService.sendCheckoutPhoneOtp(phone);
    setState(() => _isVerifyingOtp = false);
    if (success) {
      setState(() => _isOtpSent = true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP sent successfully')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to send OTP')));
    }
  }

  Future<void> _verifyOtp() async {
    final phone = _mobileNumberController.text.trim();
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter the OTP')));
      return;
    }
    setState(() => _isVerifyingOtp = true);
    final success = await ApiService.verifyCheckoutPhoneOtp(phone, otp);
    setState(() => _isVerifyingOtp = false);
    if (success) {
      setState(() {
        _isPhoneVerified = true;
        _isOtpSent = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Phone number verified')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid OTP')));
    }
  }



  void _updateQuantity(int cartItemId, String action) async {
    setState(() => _isLoading = true);
    final success = await ApiService.updateCartItem(
      cartItemId: cartItemId,
      action: action,
    );
    if (success) {
      await _fetchCheckoutPreview();
      await _fetchCartCount();
      if (_cartItems.isEmpty) {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const CartScreen()),
            (route) => false,
          );
        }
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _deleteCartItem(int cartItemId) async {
    setState(() => _isLoading = true);
    final success = await ApiService.deleteCartItem(cartItemId);
    if (success) {
      await _fetchCheckoutPreview();
      await _fetchCartCount();
      if (_cartItems.isEmpty) {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const CartScreen()),
            (route) => false,
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete item')));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchCartCount() async {
    final count = await ApiService.getCartCount();
    setState(() {
      _cartCount = count;
    });
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    if (Navigator.canPop(context))
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
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
                      ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      const Text(
                        'Checkout',
                        style: TextStyle(
                          color: Color(0xFF4D555C),
                          fontSize: 18,
                          fontFamily: 'ITC Avant Garde Gothic Pro',
                          fontWeight: FontWeight.w600,
                          height: 1.30,
                          letterSpacing: -0.54,
                        ),
                      ),
                      SizedBox(height: 15),
                      if (_isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (_checkoutData == null || _cartItems.isEmpty)
                        const Center(
                          child: Text(
                            'Your cart is empty',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      else ...[
                        // Cart Items Section
                        _buildCartItemsCard(),
                        const SizedBox(height: 16),
                        // Wallet Balance Section
                        _buildWalletBalanceCard(),
                        const SizedBox(height: 16),
                        // Apply Coupon Section
                        _buildCouponCard(),
                        const SizedBox(height: 16),
                        // Delivery Address Section
                        _buildDeliveryAddressCard(),
                        const SizedBox(height: 16),
                        // Delivery Slots Section
                        _buildDeliverySlotsCard(),
                        const SizedBox(height: 16),
                        // Delivery Instructions Section
                        _buildDeliveryInstructionsCard(),
                        const SizedBox(height: 16),
                        // Tip Your Driver Section
                        _buildTipDriverCard(),
                        const SizedBox(height: 16),
                        // Mobile Number Section
                        _buildMobileNumberCard(),
                        const SizedBox(height: 16),
                        // Bill Details Section
                        _buildBillDetailsCard(),
                        const SizedBox(height: 16),
                        // Payment Options Section
                        _buildPaymentOptionsCard(),
                        const SizedBox(height: 16),

                        // Outer GestureDetector for processing checkout
                        GestureDetector(
                          onTap: _processCheckout,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: ShapeDecoration(
                              color: AppTheme.instance.secondaryLightBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'TOTAL: \$${_checkoutData!.data.totalAmountSummary.total.toStringAsFixed(2)} - CHECKOUT',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'ITC Avant Garde Gothic Pro',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20), // Space for bottom button
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Checkout Button (Fixed at bottom)
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
                    MaterialPageRoute(
                      builder: (context) => const CategoriesScreen(),
                    ),
                    (route) => false,
                  );
                } else if (index == 2) {
                  // Hot food icon tapped
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HotFoodScreen(),
                    ),
                    (route) => false,
                  );
                } else if (index == 4) {
                  // Cart icon tapped
                  if (_currentIndex != index) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CartScreen(),
                      ),
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

  Widget _buildCartItemsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ...List.generate(_cartItems.length, (index) {
            return _buildCartItem(_cartItems[index], index, _cartItems.length);
          }),
        ],
      ),
    );
  }

  Widget _buildCartItem(Datum item, int index, int totalLength) {
    final quantity = item.quantity;
    return Container(
      margin: EdgeInsets.only(bottom: index < totalLength - 1 ? 16 : 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.instance.lightBlueBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                'https://spicekart.mockupz.in/storage/products/${item.product.productImage}',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.image_not_supported);
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.productName,
                  style: const TextStyle(
                    color: Color(0xFF4D555C),
                    fontSize: 14,
                    fontFamily: 'ITC Avant Garde Gothic Pro',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.variant.varientSize,
                  style: const TextStyle(
                    color: Color(0xFF4D555C),
                    fontSize: 12,
                    fontFamily: 'ITC Avant Garde Gothic Pro',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                if (item.variant.productPrice != null)
                  Text(
                    '\$${item.variant.productPrice}',
                    style: const TextStyle(
                      color: Color(0xFF4D555C),
                      fontSize: 12,
                      fontFamily: 'ITC Avant Garde Gothic Pro',
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                const SizedBox(height: 8),
                // Delete button
                GestureDetector(
                  onTap: () => _deleteCartItem(item.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Delete',
                      style: TextStyle(
                        color: Color(0xFF4D555C),
                        fontSize: 10,
                        fontFamily: 'ITC Avant Garde Gothic Pro',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Price and Quantity
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${item.variant.storePrice ?? item.variant.productPrice}',
                style: const TextStyle(
                  color: Color(0xFF171717),
                  fontSize: 14,
                  fontFamily: 'ITC Avant Garde Gothic Pro',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              // Quantity Selector
              Container(
                height: 28,
                decoration: BoxDecoration(
                  color: AppTheme.instance.secondaryLightBlue,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.remove,
                        size: 14,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        if (quantity > 1) {
                          _updateQuantity(item.id, 'decrease');
                        } else {
                          _deleteCartItem(item.id);
                        }
                      },
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      constraints: const BoxConstraints(minWidth: 20),
                      child: Text(
                        '$quantity',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add,
                        size: 14,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        _updateQuantity(item.id, 'increase');
                      },
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWalletBalanceCard() {
    final balance = _checkoutData?.data.totalAmountSummary.walletBalance ?? 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.instance.mutedBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Wallet Balance',
                  style: TextStyle(
                    color: Color(0xFF4D555C),
                    fontSize: 14,
                    fontFamily: 'ITC Avant Garde Gothic Pro',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Available: \$${balance.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12,
                    fontFamily: 'ITC Avant Garde Gothic Pro',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {
              setState(() {
                _isWalletRedeemed = !_isWalletRedeemed;
              });
              // We could potentially call an API to apply wallet balance if that exists,
              // but for now, just toggling state locally.
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: _isWalletRedeemed
                    ? Colors.grey
                    : AppTheme.instance.mutedBlue,
              ),
              backgroundColor: _isWalletRedeemed
                  ? Colors.grey.shade200
                  : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              _isWalletRedeemed ? 'Redeemed' : 'Redeem',
              style: TextStyle(
                color: _isWalletRedeemed
                    ? Colors.grey.shade700
                    : AppTheme.instance.mutedBlue,
                fontSize: 12,
                fontFamily: 'ITC Avant Garde Gothic Pro',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFE3F2FD),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_offer,
                  color: AppTheme.instance.mutedBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Apply Coupon',
                style: TextStyle(
                  color: Color(0xFF4D555C),
                  fontSize: 14,
                  fontFamily: 'ITC Avant Garde Gothic Pro',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: _couponController,
                    decoration: const InputDecoration(
                      hintText: 'Enter coupon code',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddressCard() {
    final addressObj = _checkoutData?.data.cart.address;
    String addressText = 'No address selected';
    if (addressObj != null && addressObj.addressLine1.isNotEmpty) {
      addressText =
          '${addressObj.addressLine1}, ${addressObj.city} ${addressObj.postalCode}';
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFE3F2FD),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_on,
                  color: AppTheme.instance.mutedBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Delivery Address',
                style: TextStyle(
                  color: Color(0xFF4D555C),
                  fontSize: 14,
                  fontFamily: 'ITC Avant Garde Gothic Pro',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                'Deliver to ',
                style: TextStyle(
                  color: Color(0xFF4D555C),
                  fontSize: 14,
                  fontFamily: 'ITC Avant Garde Gothic Pro',
                  fontWeight: FontWeight.w500,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Handle location selection
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Selected location',
                      style: TextStyle(
                        color: AppTheme.instance.mutedBlue,
                        fontSize: 14,
                        fontFamily: 'ITC Avant Garde Gothic Pro',
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down,
                      color: AppTheme.instance.mutedBlue,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            addressText,
            style: const TextStyle(
              color: Color(0xFF4D555C),
              fontSize: 14,
              fontFamily: 'ITC Avant Garde Gothic Pro',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliverySlotsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFE3F2FD),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF63A6D1),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Delivery Slots',
                style: TextStyle(
                  color: Color(0xFF4D555C),
                  fontSize: 14,
                  fontFamily: 'ITC Avant Garde Gothic Pro',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_deliverySlots.isEmpty)
            const Text(
              'Now there is no delivery slots',
              style: TextStyle(
                color: Color(0xFFF44336),
                fontSize: 14,
                fontFamily: 'ITC Avant Garde Gothic Pro',
                fontWeight: FontWeight.w500,
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = (constraints.maxWidth - 12) / 2;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _deliverySlots.map((slot) {
                    final day = slot['day']?.toString() ?? slot['date']?.toString() ?? 'Date';
                    final time = slot['time']?.toString() ?? slot['slot']?.toString() ?? 'Slot';
                    return SizedBox(
                      width: itemWidth,
                      child: _buildSlotButton(day, time),
                    );
                  }).toList(),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSlotButton(String day, String time) {
    final isSelected = _selectedDeliverySlot == day;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDeliverySlot = day;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF63A6D1) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              day,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF63A6D1)
                    : const Color(0xFF4D555C),
                fontSize: 14,
                fontFamily: 'ITC Avant Garde Gothic Pro',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF63A6D1)
                    : Colors.grey.shade600,
                fontSize: 12,
                fontFamily: 'ITC Avant Garde Gothic Pro',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryInstructionsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.local_shipping,
              color: Colors.amber.shade800,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Delivery instructions.',
              style: TextStyle(
                color: Color(0xFF4D555C),
                fontSize: 14,
                fontFamily: 'ITC Avant Garde Gothic Pro',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DeliveryInstructionsScreen(),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF63A6D1)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Edit',
              style: TextStyle(
                color: Color(0xFF63A6D1),
                fontSize: 12,
                fontFamily: 'ITC Avant Garde Gothic Pro',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipDriverCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFE3F2FD),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.directions_car,
                  color: Color(0xFF63A6D1),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tip Your Driver (optional)',
                      style: TextStyle(
                        color: Color(0xFF4D555C),
                        fontSize: 14,
                        fontFamily: 'ITC Avant Garde Gothic Pro',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '100% goes to the driver',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontFamily: 'ITC Avant Garde Gothic Pro',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildTipButton(5)),
              const SizedBox(width: 8),
              Expanded(child: _buildTipButton(10)),
              const SizedBox(width: 8),
              Expanded(child: _buildTipButton(15)),
              const SizedBox(width: 8),
              Expanded(child: _buildTipButton(18)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTipButton(int percentage) {
    final isSelected = _selectedTipPercentage == percentage;
    return GestureDetector(
      onTap: () async {
        setState(() => _isLoading = true);
        final success = await ApiService.applyTip(percentage);
        if (success) {
          if (mounted) {
            _selectedTipPercentage = percentage;
            await _fetchCheckoutPreview();
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to apply tip')),
            );
            setState(() => _isLoading = false);
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF63A6D1) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          '$percentage%',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected
                ? const Color(0xFF63A6D1)
                : const Color(0xFF4D555C),
            fontSize: 12,
            fontFamily: 'ITC Avant Garde Gothic Pro',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildMobileNumberCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFE3F2FD),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.phone,
                  color: Color(0xFF63A6D1),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Mobile number',
                style: TextStyle(
                  color: Color(0xFF4D555C),
                  fontSize: 14,
                  fontFamily: 'ITC Avant Garde Gothic Pro',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'We may contact you for delivery updates',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontFamily: 'ITC Avant Garde Gothic Pro',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: _mobileNumberController,
                    keyboardType: TextInputType.phone,
                    readOnly: _isPhoneVerified,
                    decoration: const InputDecoration(
                      hintText: 'Enter Mobile Number',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (!_isPhoneVerified)
                ElevatedButton(
                  onPressed: _isVerifyingOtp ? null : _sendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF63A6D1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isVerifyingOtp
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(
                          _isOtpSent ? 'Resend' : 'Send OTP',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontFamily: 'ITC Avant Garde Gothic Pro',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                )
              else
                const Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Icon(Icons.check_circle, color: Color(0xFF38B547), size: 28),
                ),
            ],
          ),
          if (_isOtpSent && !_isPhoneVerified) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Enter OTP',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isVerifyingOtp ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38B547),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isVerifyingOtp
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text(
                          'Verify OTP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'ITC Avant Garde Gothic Pro',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBillDetailsCard() {
    final summary = _checkoutData?.data.totalAmountSummary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bill Details',
            style: TextStyle(
              color: Color(0xFF4D555C),
              fontSize: 16,
              fontFamily: 'ITC Avant Garde Gothic Pro',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _buildBillRow(
            'Subtotal',
            '\$${summary?.subtotal.toStringAsFixed(2) ?? '0.00'}',
          ),
          const SizedBox(height: 8),
          if ((summary?.discount ?? 0) > 0) ...[
            _buildBillRow(
              'Discount',
              '-\$${summary!.discount.toStringAsFixed(2)}',
              valueColor: const Color(0xFF38B547),
            ),
            const SizedBox(height: 8),
          ],
          _buildBillRow(
            'Delivery Fee',
            '\$${summary?.deliveryFee.toStringAsFixed(2) ?? '0.00'}',
          ),
          const SizedBox(height: 8),
          _buildBillRow(
            'Estimated Tax',
            '\$${summary?.tax.toStringAsFixed(2) ?? '0.00'}',
          ),
          if ((summary?.tipAmount ?? 0) > 0) ...[
            const SizedBox(height: 8),
            _buildBillRow(
              'Driver Tip',
              '\$${summary!.tipAmount.toStringAsFixed(2)}',
            ),
          ],
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  color: Color(0xFF4D555C),
                  fontSize: 18,
                  fontFamily: 'ITC Avant Garde Gothic Pro',
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '\$${summary?.total.toStringAsFixed(2) ?? '0.00'}',
                style: const TextStyle(
                  color: Color(0xFF4D555C),
                  fontSize: 18,
                  fontFamily: 'ITC Avant Garde Gothic Pro',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF4D555C),
            fontSize: 14,
            fontFamily: 'ITC Avant Garde Gothic Pro',
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? const Color(0xFF4D555C),
            fontSize: 14,
            fontFamily: 'ITC Avant Garde Gothic Pro',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOptionsCard() {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PaymentMethodScreen()),
        );
        if (result != null && result is String) {
          setState(() {
            _selectedPaymentMethod = result;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.instance.lightBlueBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.payment,
                    color: Color(0xFF63A6D1),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _selectedPaymentMethod ?? 'Payment options',
                  style: const TextStyle(
                    color: Color(0xFF4D555C),
                    fontSize: 14,
                    fontFamily: 'ITC Avant Garde Gothic Pro',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
          ],
        ),
      ),
    );
  }

  Future<void> _processCheckout() async {
    if (!_isPhoneVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please verify your mobile number first')),
      );
      return;
    }

    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method first')),
      );
      return;
    }

    final totalAmount = _checkoutData?.data.totalAmountSummary.total ?? 0.0;
    if (totalAmount <= 0) return;

    // E.g., handling Card payments via Stripe
    if (_selectedPaymentMethod == 'Master Card' ||
        _selectedPaymentMethod == 'Visa' ||
        _selectedPaymentMethod == 'Apple Pay' ||
        _selectedPaymentMethod == 'Google Pay') {
      setState(() => _isLoading = true);

      // 1. Fetch Payment Intent (Client Secret) from backend
      final clientSecret = await ApiService.createStripePaymentIntent(
        amount: totalAmount,
      );

      if (clientSecret == null) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to initialize Stripe checkout'),
            ),
          );
        }
        return;
      }

      // 2. Initialize the Payment Sheet
      try {
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: 'SpiceKart',
            style: ThemeMode.light,
          ),
        );
      } catch (e) {
        setState(() => _isLoading = false);
        print("Error initializing Payment Sheet: $e");
        return;
      }

      setState(() => _isLoading = false);

      // 3. Present the Payment Sheet
      try {
        await Stripe.instance.presentPaymentSheet();
        // If we get past presentPaymentSheet without an exception, it succeeded.

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OrderSuccessScreen()),
          );
        }
      } on StripeException catch (e) {
        print('Stripe Error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Payment canceled or failed: \${e.error.localizedMessage}',
              ),
            ),
          );
        }
      } catch (e) {
        print('Error presenting payment sheet: $e');
      }
    } else if (_selectedPaymentMethod == 'Paypal') {
      // Implement PayPal logic later or navigate directly to success/fake handling
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const OrderSuccessScreen()),
      );
    }
  }
}
