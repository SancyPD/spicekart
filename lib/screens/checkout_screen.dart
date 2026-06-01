import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:spicekart/model/delivery_slots.dart';

import '../controllers/checkout_controller.dart';

import '../utils/app_theme.dart';
import 'package:spicekart/screens/delivery_instructions_screen.dart';
import 'package:spicekart/screens/payment_method_screen.dart';
import 'package:spicekart/screens/user_address_list_screen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';


class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final CheckoutController controller = Get.put(CheckoutController());

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

  Future<void> _showCustomTipDialog() async {
    final current = controller.appliedCustomTipDollars.value;
    final textController = TextEditingController(
      text: current != null && current > 0 ? current.toStringAsFixed(2) : '',
    );

    final double? entered = await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Custom tip amount'),
          content: TextField(
            controller: textController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              hintText: 'Enter amount in dollars (e.g. 3.50)',
              prefixText: '\$ ',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final raw = textController.text.trim().replaceAll('\$', '');
                final value = double.tryParse(raw);
                Navigator.pop(context, value);
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );

    if (entered == null) return;
    final amount = double.parse(entered.clamp(0, 99999).toStringAsFixed(2));
    if (amount <= 0) {
      await controller.applyTipPercent(0);
      return;
    }
    await controller.applyCustomTipDollars(amount);
  }

  Future<String?> _getOneSignalPlayerId() async {
    try {
      return OneSignal.User.pushSubscription.id;
    } catch (e) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args.containsKey('isDeliveryCodeGenerated')) {
        controller.isDeliveryCodeGenerated.value =
            args['isDeliveryCodeGenerated'] == true;
      }
      controller.fetchCheckoutPreview();
    });
  }

  @override
  void dispose() {
    super.dispose();
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
        body: Obx(
          () => Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    // Header Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Back button
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            behavior: HitTestBehavior.opaque,
                            child: const Padding(
                              padding: EdgeInsets.only(
                                top: 8,
                                bottom: 8,
                                right: 20,
                              ),
                              child: Text(
                                'Back',
                                style: TextStyle(
                                  color: Color(0xFF4D555C),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildCartIconWithBadge(
                                count: controller.apiCartCount.value,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\$${(controller.checkoutData.value?.data.totalAmountSummary?.total ?? 0.0).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Color(0xFF4D555C),
                                  fontSize: 12,
                                  fontFamily: 'ITC Avant Garde Gothic Pro',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
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
                            if (!controller.isLoading.value &&
                                (controller.checkoutData.value == null ||
                                    controller.cartItems.isEmpty))
                              const Center(
                                child: Text(
                                  'Your cart is empty',
                                  style: TextStyle(fontSize: 16),
                                ),
                              )
                            else if (controller.checkoutData.value != null &&
                                controller.cartItems.isNotEmpty) ...[
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
                                onTap: () async {
                                  final playerId =
                                      await _getOneSignalPlayerId();
                                  controller.processCheckout(playerId);
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: ShapeDecoration(
                                    color: AppTheme.instance.secondaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Place Order - TOTAL \$${(controller.checkoutData.value?.data.totalAmountSummary?.total ?? 0.0).toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontFamily:
                                            'ITC Avant Garde Gothic Pro',
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Space for bottom button
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (controller.isLoading.value)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartItemsCard() {
    final products = controller.cartItems.where((item) => item.itemType == 'product').toList();
    final foods = controller.cartItems.where((item) => item.itemType == 'food').toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (products.isNotEmpty) ...[
            ...List.generate(products.length, (index) {
              return _buildCartItem(
                products[index],
                index,
                products.length,
              );
            }),
          ],
          if (foods.isNotEmpty) ...[
            if (products.isNotEmpty) const SizedBox(height: 20),
            const Text(
              'Hot foods',
              style: TextStyle(
                color: Color(0xFF4D555C),
                fontSize: 14,
                fontFamily: 'ITC Avant Garde Gothic Pro',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(foods.length, (index) {
              return _buildCartItem(
                foods[index],
                index,
                foods.length,
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildCartItem(dynamic item, int index, int totalLength) {
    final quantity = item.quantity;
    final bool isProduct = item.itemType == 'product';

    final String name = isProduct ? item.item.productName : item.item.name;
    final String image = isProduct ? item.item.productImage : item.item.image;
    final String price = isProduct
        ? item.variant?.productPrice
        : item.item.price;
    final String? size = isProduct ? item.variant?.varientSize : null;

    return Container(
      margin: EdgeInsets.only(bottom: index < totalLength - 1 ? 16 : 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.instance.backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                isProduct
                    ? 'https://spicekart1.mockupz.in/storage/products/$image'
                    : 'https://spicekart1.mockupz.in/storage/food_items/$image',
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
                  name,
                  style: const TextStyle(
                    color: Color(0xFF4D555C),
                    fontSize: 12,
                    fontFamily: 'ITC Avant Garde Gothic Pro',
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (size != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    size,
                    style: const TextStyle(
                      color: Color(0xFF4D555C),
                      fontSize: 12,
                      fontFamily: 'ITC Avant Garde Gothic Pro',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: 1),
                Text(
                  '\$$price',
                  style: const TextStyle(
                    color: Color(0xFF4D555C),
                    fontSize: 10,
                    fontFamily: 'ITC Avant Garde Gothic Pro',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                // Delete button
                GestureDetector(
                  onTap: () async {
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
                            child: const Text(
                              'DELETE',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      controller.deleteCartItem(item.id);
                    }
                  },
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
                '\$${((double.tryParse(price.toString()) ?? 0.0) * quantity).toStringAsFixed(2)}',
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
                  color: AppTheme.instance.secondaryColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.remove,
                        size: 12,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        if (quantity > 1) {
                          controller.updateQuantity(item.id, 'decrement');
                        }
                      },
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      constraints: const BoxConstraints(minWidth: 20),
                      child: Text(
                        '$quantity',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add,
                        size: 12,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        controller.updateQuantity(item.id, 'increment');
                      },
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
    );
  }

  Widget _buildWalletBalanceCard() {
    final balance =
        controller.checkoutData.value?.data.totalAmountSummary?.walletBalance ??
        0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.instance.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.instance.iconBgColor,
              shape: BoxShape.circle,
            ),
            padding: EdgeInsets.all(10),
            child: Image.asset(
              'assets/images/wallet.png',
              color: AppTheme.instance.secondaryColor,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.account_balance_wallet, size: 10),
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
              controller.applyWallet(!controller.isWalletRedeemed.value);
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: controller.isWalletRedeemed.value
                    ? Colors.grey
                    : AppTheme.instance.mutedColor,
              ),
              backgroundColor: controller.isWalletRedeemed.value
                  ? Colors.grey.shade200
                  : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              controller.isWalletRedeemed.value ? 'Redeemed' : 'Redeem',
              style: TextStyle(
                color: controller.isWalletRedeemed.value
                    ? Colors.grey.shade700
                    : AppTheme.instance.mutedColor,
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
                decoration: BoxDecoration(
                  color: AppTheme.instance.iconBgColor,
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(10),
                child: Image.asset(
                  'assets/images/ticket_discount.png',
                  color: AppTheme.instance.secondaryColor,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.local_offer, size: 20),
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
                    controller: controller.couponController,
                    onSubmitted: (_) => controller.applyCoupon(),
                    decoration: InputDecoration(
                      hintText: 'Enter coupon code',
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: controller.applyCoupon,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (controller
                          .checkoutData
                          .value
                          ?.data
                          .totalAmountSummary
                          ?.discount !=
                      null &&
                  controller
                          .checkoutData
                          .value!
                          .data
                          .totalAmountSummary!
                          .discount >
                      0)
                TextButton(
                  onPressed: controller.removeCoupon,
                  child: const Text(
                    'Remove',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddressCard() {
    final addressObj = controller.checkoutData.value?.data.cart?.address;
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
                decoration: BoxDecoration(
                  color: AppTheme.instance.iconBgColor,
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(10),
                child: Image.asset(
                  'assets/images/location_ic.png',
                  color: AppTheme.instance.secondaryColor,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.location_on, size: 20),
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
                onTap: () async {
                  await Get.to(
                    () => const UserAddressListScreen(isFromCheckout: true),
                  );
                  controller.fetchCheckoutPreview();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Selected location',
                      style: TextStyle(
                        color: AppTheme.instance.mutedColor,
                        fontSize: 14,
                        fontFamily: 'ITC Avant Garde Gothic Pro',
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down,
                      color: AppTheme.instance.mutedColor,
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
                decoration: BoxDecoration(
                  color: AppTheme.instance.iconBgColor,
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(10),
                child: Image.asset(
                  'assets/images/box.png',
                  color: AppTheme.instance.secondaryColor,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.calendar_today, size: 20),
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
          if (controller.deliverySlots.isEmpty)
            const Text(
              'Now there is no delivery slots',
              style: TextStyle(
                color: Color(0xFFF44336),
                fontSize: 14,
                fontFamily: 'ITC Avant Garde Gothic Pro',
                fontWeight: FontWeight.w500,
              ),
            )
          else ...[
            // Date Selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: controller.deliverySlots.map((dateDatum) {
                  return _buildDateButton(dateDatum);
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            // Slots Grid for Selected Date
            if (controller.selectedDeliveryDate.value != null)
              LayoutBuilder(
                builder: (context, constraints) {
                  final slots = controller.selectedDeliveryDate.value!.slots;
                  final itemWidth = (constraints.maxWidth - 12) / 2;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: slots.map((slot) {
                      return SizedBox(
                        width: itemWidth,
                        child: _buildSlotButton(slot),
                      );
                    }).toList(),
                  );
                },
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateButton(DeliverySlot dateDatum) {
    final isSelected = controller.selectedDeliveryDate.value == dateDatum;
    final date = dateDatum.deliveryDate;

    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    final isTomorrow = date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
    final dayLabel = isToday
        ? 'Today'
        : isTomorrow
            ? 'Tomorrow'
            : _getDayName(date.weekday);
    final dateLabel = '${date.month}/${date.day}';

    return GestureDetector(
      onTap: () {
        if (dateDatum.slots.isNotEmpty) {
          controller.updateSelectedSlot(dateDatum, dateDatum.slots.first);
        } else {
          controller.selectedDeliveryDate.value = dateDatum;
        }
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.instance.secondaryColor : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : AppTheme.instance.secondaryColor.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayLabel,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF171717),
                fontSize:dayLabel =='Today' || dayLabel == 'Tomorrow'? 10: 15,
                fontFamily: 'ITC Avant Garde Gothic Pro',
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              dateLabel,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF4D555C),
                fontSize: 14,
                fontFamily: 'ITC Avant Garde Gothic Pro',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  Widget _buildSlotButton(Slot slot) {
    final isSelected = controller.selectedSlot.value == slot;
    return GestureDetector(
      onTap: () {
        if (controller.selectedDeliveryDate.value != null) {
          controller.updateSelectedSlot(
            controller.selectedDeliveryDate.value!,
            slot,
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.instance.secondaryColor
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            "${slot.startTime} - ${slot.endTime}",
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF4D555C),
              fontSize: 12,
              fontFamily: 'ITC Avant Garde Gothic Pro',
              fontWeight: FontWeight.w600,
            ),
          ),
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
            width: 71,
            height: 71,
            child: Image.asset(
              'assets/images/delivery_inst.png',
              width: 24,
              height: 24,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.local_shipping,
                color: Colors.amber.shade800,
                size: 24,
              ),
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
            onPressed: () async {
              await Get.to(
                () => const DeliveryInstructionsScreen(),
                arguments: {
                  'isDeliveryCodeGenerated': controller.isDeliveryCodeGenerated.value,
                },
              );
              controller.fetchCheckoutPreview();
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppTheme.instance.mutedColor),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Edit',
              style: TextStyle(
                color: AppTheme.instance.mutedColor,
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
                decoration: BoxDecoration(
                  color: AppTheme.instance.iconBgColor,
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(10),
                child: Image.asset(
                  'assets/images/tip_ic.png',
                  width: 24,
                  height: 24,
                  color: AppTheme.instance.secondaryColor,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.directions_car, size: 20),
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
              Expanded(child: _buildNoTipButton()),
              const SizedBox(width: 8),
              Expanded(child: _buildCustomTipButton()),
            ],
          ),
          Builder(
            builder: (_) {
              final summary =
                  controller.checkoutData.value?.data.totalAmountSummary;
              final tip = summary == null
                  ? 0.0
                  : ((summary.tipAmount as num?) ?? 0).toDouble();
              if (tip <= 0) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: 'ITC Avant Garde Gothic Pro',
                      color: Color(0xFF4D555C),
                    ),
                    children: [
                      const TextSpan(
                        text: 'Your tip: ',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text: '\$${tip.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTipButton(int percentage) {
    final isSelected =
        controller.appliedTipType.value == 'percent' &&
        controller.appliedPercentTip.value == percentage;
    return GestureDetector(
      onTap: () {
        if (isSelected) {
          controller.applyTipPercent(0);
        } else {
          controller.applyTipPercent(percentage);
        }
      },
      child: Container(
        height: 40,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF63A6D1) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '$percentage%',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFF63A6D1)
                  : const Color(0xFF4D555C),
              fontSize: 11,
              fontFamily: 'ITC Avant Garde Gothic Pro',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoTipButton() {
    final isSelected =
        controller.appliedTipType.value == 'percent' &&
        controller.appliedPercentTip.value == 0;
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          controller.applyTipPercent(0);
        }
      },
      child: Container(
        height: 40,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF63A6D1) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'No tip',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFF63A6D1)
                  : const Color(0xFF4D555C),
              fontSize: 11,
              fontFamily: 'ITC Avant Garde Gothic Pro',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTipButton() {
    final isSelected = controller.appliedTipType.value == 'custom';
    final dollars = controller.appliedCustomTipDollars.value;
    final label = (dollars != null && dollars > 0)
        ? 'Custom\n(\$${dollars.toStringAsFixed(2)})'
        : 'Custom';

    return GestureDetector(
      onTap: _showCustomTipDialog,
      child: Container(
        height: 40,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF63A6D1) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFF63A6D1)
                  : const Color(0xFF4D555C),
              fontSize: 11,
              fontFamily: 'ITC Avant Garde Gothic Pro',
              fontWeight: FontWeight.w600,
            ),
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
                decoration: BoxDecoration(
                  color: AppTheme.instance.iconBgColor,
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(10),
                child: Image.asset(
                  'assets/images/mob_ic.png',
                  width: 24,
                  height: 24,
                  color: AppTheme.instance.secondaryColor,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.phone, size: 20),
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
            'We may contact you for delivery updates(This is mandatory)',
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
                    controller: controller.mobileNumberController,
                    keyboardType: TextInputType.phone,
                    readOnly: controller.isPhoneVerified.value,
                    onTap: () {
                      if (controller.isPhoneVerified.value) {
                        controller.isEditMobileVisible.value = true;
                      }
                    },
                    decoration: const InputDecoration(
                      hintText: 'Enter Mob.no(e.g. +12125550123)',
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
              if (!controller.isPhoneVerified.value)
                ElevatedButton(
                  onPressed: controller.isVerifyingOtp.value
                      ? null
                      : controller.sendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.instance.tertiaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: controller.isVerifyingOtp.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          controller.isOtpSent.value ? 'Resend' : 'Send OTP',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontFamily: 'ITC Avant Garde Gothic Pro',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                )
              else ...[
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF38B547),
                  size: 28,
                ),
                if (controller.isEditMobileVisible.value) ...[
                  const SizedBox(width: 4),
                  TextButton(
                    onPressed: controller.editMobileNumber,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Edit',
                      style: TextStyle(
                        color: Color(0xFF63A6D1),
                        fontSize: 14,
                        fontFamily: 'ITC Avant Garde Gothic Pro',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
          if (controller.isOtpSent.value &&
              !controller.isPhoneVerified.value) ...[
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
                      controller: controller.otpController,
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
                  onPressed: controller.isVerifyingOtp.value
                      ? null
                      : controller.verifyOtp,
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
                  child: controller.isVerifyingOtp.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
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
    final summary = controller.checkoutData.value?.data.totalAmountSummary;
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
              '-\$${summary?.discount.toStringAsFixed(2) ?? '0.00'}',
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
          _buildDriverTipRowIfAny(summary),
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

  /// Driver tip from checkout preview (product or food); show only when amount > 0.
  Widget _buildDriverTipRowIfAny(dynamic summary) {
    final tip = summary == null
        ? 0.0
        : ((summary.tipAmount as num?) ?? 0).toDouble();
    if (tip <= 0) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        _buildBillRow('Driver Tip', '\$${tip.toStringAsFixed(2)}'),
      ],
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
        final result = await Get.to(
          () => const PaymentMethodScreen(fromCheckout: true),
        );
        if (result != null && result is String) {
          controller.selectedPaymentMethod.value = result;
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
                    color: AppTheme.instance.iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(10),
                  child: Image.asset(
                    'assets/images/options_ic.png',
                    width: 24,
                    height: 24,
                    color: AppTheme.instance.secondaryColor,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.payment, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.selectedPaymentMethod.value == 'stripe'
                            ? 'Credit/ Debit card'
                            : controller.selectedPaymentMethod.value ==
                                  'apple_pay'
                            ? 'Apple Pay'
                            : controller.selectedPaymentMethod.value ==
                                  'google_pay'
                            ? 'Google Pay'
                            : (controller.selectedPaymentMethod.value ??
                                  'Payment options'),
                        style: const TextStyle(
                          color: Color(0xFF4D555C),
                          fontSize: 14,
                          fontFamily: 'ITC Avant Garde Gothic Pro',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (controller.selectedPaymentMethod.value == 'stripe' &&
                          controller.selectedPaymentMethodSummary.value !=
                              null &&
                          controller
                              .selectedPaymentMethodSummary.value!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            controller.selectedPaymentMethodSummary.value!,
                            style: const TextStyle(
                              color: Color(0xFF7F858A),
                              fontSize: 12,
                              fontFamily: 'ITC Avant Garde Gothic Pro',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
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
}
