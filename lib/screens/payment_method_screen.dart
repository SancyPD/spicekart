import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:spicekart/controllers/cart_controller.dart';
import 'package:spicekart/controllers/checkout_controller.dart';
import '../utils/app_theme.dart';
import 'package:spicekart/services/api_service.dart';
import 'package:spicekart/controllers/main_controller.dart';
import 'package:spicekart/screens/main_screen.dart';
import '../model/payment_methods_response.dart' as pm;

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key, this.fromCheckout = false});

  /// When `true` (opened from checkout): only "Credit / Debit card" — no saved cards, no add-new.
  final bool fromCheckout;

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  int _currentIndex = 0;
  bool _loading = true;
  bool _addingPayment = false;
  String? _error;
  List<pm.Datum> _savedMethods = [];

  /// `null` = generic Stripe card flow; otherwise Stripe `pm_` id.
  String? _selectedPaymentMethodId;
  static const String _genericStripeId = 'stripe_generic';

  @override
  void initState() {
    super.initState();
    CartController.to.updateCartCount();
    _restoreFromCheckout();
    _loadPaymentMethods();
  }

  void _restoreFromCheckout() {
    if (!Get.isRegistered<CheckoutController>()) return;
    final c = Get.find<CheckoutController>();
    final pmId = c.selectedStripePaymentMethodId.value;
    if (pmId != null && pmId.isNotEmpty) {
      _selectedPaymentMethodId = pmId;
    } else if (c.selectedPaymentMethod.value == 'stripe') {
      _selectedPaymentMethodId = _genericStripeId;
    }
  }

  Future<void> _loadPaymentMethods() async {

    setState(() {
      _loading = true;
      _error = null;
    });
    final response = await ApiService.getCustomerPaymentmethods();
    if (!mounted) return;
    if (response == null) {
      setState(() {
        _loading = false;
        _error = 'Could not load saved payment methods.';
        _savedMethods = [];
        _selectedPaymentMethodId ??= _genericStripeId;
      });
      _applySelectionToCheckout();
      return;
    }

    final list = response.data.data
        .where((d) => d.type == 'card' && d.card != null && d.card!.last4.isNotEmpty)
        .toList();

    setState(() {
      _loading = false;
      _savedMethods = list;
      if (_selectedPaymentMethodId != null &&
          _selectedPaymentMethodId != _genericStripeId &&
          !_savedMethods.any((e) => e.id == _selectedPaymentMethodId)) {
        _selectedPaymentMethodId = _genericStripeId;
      }
      _selectedPaymentMethodId ??=
          list.isNotEmpty ? list.first.id : _genericStripeId;
    });
    _applySelectionToCheckout();
  }

  Future<void> _addNewPaymentMethod() async {
    if (_addingPayment) return;
    setState(() => _addingPayment = true);
    try {
      final resp = await ApiService.createCustomerPaymentMethod();
      if (!mounted) return;

      if (resp == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not reach the server. Try again.')),
        );
        return;
      }

      if (resp.status != 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resp.message.isNotEmpty ? resp.message : 'Request failed')),
        );
        return;
      }

      final secret = resp.setupIntentClientSecret;
      if (secret == null || secret.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Missing setup information from server.')),
        );
        return;
      }

      final ephemeral = resp.ephemeralKeySecret;
      final customer = resp.customerId;
      final bool hasCustomerSession =
          customer != null &&
          customer.isNotEmpty &&
          ephemeral != null &&
          ephemeral.isNotEmpty;

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          setupIntentClientSecret: secret,
          merchantDisplayName: 'SpiceKart',
          style: ThemeMode.light,
          customerId: hasCustomerSession ? customer : null,
          customerEphemeralKeySecret: hasCustomerSession ? ephemeral : null,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      if (!mounted) return;
      await _loadPaymentMethods();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment method added successfully')),
      );
    } on StripeException catch (e) {
      if (!mounted) return;
      final msg = e.error.localizedMessage ?? e.error.message;
      if (msg != null && msg.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not add card: $e')),
      );
    } finally {
      if (mounted) setState(() => _addingPayment = false);
    }
  }

  void _applySelectionToCheckout() {
    if (!Get.isRegistered<CheckoutController>()) return;
    final c = Get.find<CheckoutController>();
    c.selectedPaymentMethod.value = 'stripe';
    if (_selectedPaymentMethodId == null ||
        _selectedPaymentMethodId == _genericStripeId) {
      c.selectedStripePaymentMethodId.value = null;
      c.selectedPaymentMethodSummary.value = 'Card';
    } else {
      c.selectedStripePaymentMethodId.value = _selectedPaymentMethodId;
      pm.Datum? match;
      for (final e in _savedMethods) {
        if (e.id == _selectedPaymentMethodId) {
          match = e;
          break;
        }
      }
      final card = match?.card;
      c.selectedPaymentMethodSummary.value = _cardSummary(card);
    }
  }

  String _cardSummary(pm.Card? card) {
    if (card == null) return 'Card';
    final brand = _displayBrand(card);
    return '$brand ···· ${card.last4}';
  }

  String _displayBrand(pm.Card card) {
    final d = card.displayBrand.trim();
    if (d.isNotEmpty) return d;
    final b = card.brand.trim();
    if (b.isEmpty) return 'Card';
    return b[0].toUpperCase() + b.substring(1).toLowerCase();
  }

  Widget _brandChip(pm.Card card) {
    final label = _displayBrand(card).toUpperCase();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F71),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label.length > 6 ? label.substring(0, 6) : label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
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
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                   /* const SizedBox(height: 8),
                    const Text(
                      'Payment',
                      style: TextStyle(
                        color: Color(0xFF4D555C),
                        fontSize: 16,
                        fontFamily: 'ITC Avant Garde Gothic Pro',
                        fontWeight: FontWeight.w600,
                        height: 1.30,
                        letterSpacing: -0.48,
                      ),
                    ),*/
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _loading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : _buildPaymentCard(),
                ),
              ),
              if (widget.fromCheckout)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: SafeArea(
                    top: false,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _applySelectionToCheckout();
                          Navigator.pop(context, 'stripe');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.instance.mutedColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'NEXT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'ITC Avant Garde Gothic Pro',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
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
                Get.offAll(() => const MainScreen());
                MainController.to.changeTab(index);
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: AppTheme.instance.primaryColor,
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
                  icon: Obx(() {
                    final cartCount = CartController.to.cartCount.value;
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Icons.shopping_cart),
                        if (cartCount > 0)
                          Positioned(
                            right: -4,
                            top: -4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                cartCount > 99 ? '99+' : '$cartCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  height: 1.0,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    );
                  }),
                  label: 'Cart',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(Icons.account_balance_wallet_outlined,
                    color: AppTheme.instance.secondaryColor, size: 22),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Payment',
                    style: TextStyle(
                      color: Color(0xFF4D555C),
                      fontSize: 18,
                      fontFamily: 'ITC Avant Garde Gothic Pro',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (!widget.fromCheckout)
                  TextButton(
                    onPressed: _addingPayment ? null : _addNewPaymentMethod,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: _addingPayment
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Add new payment',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4D555C),
                            ),
                          ),
                  ),
              ],
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: _tile(
              title: 'Credit / Debit card',
              selected: _selectedPaymentMethodId == _genericStripeId,
              leading: Icon(Icons.credit_card,
                  color: AppTheme.instance.secondaryColor, size: 28),
              onTap: () {
                setState(() => _selectedPaymentMethodId = _genericStripeId);
                _applySelectionToCheckout();
              },
            ),
          ),
          ..._savedMethods.map((m) {
              final card = m.card!;
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _tile(
                  title: 'Ending in ${card.last4}',
                  subtitle: _expLabel(card),
                  selected: _selectedPaymentMethodId == m.id,
                  leading: _brandChip(card),
                  onTap: () {
                    setState(() => _selectedPaymentMethodId = m.id);
                    _applySelectionToCheckout();
                  },
                ),
              );
            }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String? _expLabel(pm.Card card) {
    if (card.expMonth <= 0 || card.expYear <= 0) return null;
    final m = card.expMonth.toString().padLeft(2, '0');
    final y = card.expYear.toString();
    final yy = y.length >= 2 ? y.substring(y.length - 2) : y;
    return 'Expires $m/$yy';
  }

  Widget _tile({
    required String title,
    String? subtitle,
    required Widget leading,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: selected ? const Color(0xFFF1F7FB) : const Color(0xFFF8F9FA),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              leading,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF4D555C),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'ITC Avant Garde Gothic Pro',
                      ),
                    ),
                    if (subtitle != null && subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Color(0xFF7F858A),
                          fontSize: 12,
                          fontFamily: 'ITC Avant Garde Gothic Pro',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
