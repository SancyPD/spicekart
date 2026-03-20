import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme.dart';
import 'package:spicekart/services/api_service.dart';
import 'checkout_screen.dart';
import 'add_edit_address_screen.dart';
import 'user_address_list_screen.dart';
import 'home_screen.dart';
import 'categories_screen.dart';
import 'hot_food_screen.dart';
import 'cart_screen.dart';

class DeliveryInstructionsScreen extends StatefulWidget {
  const DeliveryInstructionsScreen({super.key});

  @override
  State<DeliveryInstructionsScreen> createState() =>
      _DeliveryInstructionsScreenState();
}

class _DeliveryInstructionsScreenState
    extends State<DeliveryInstructionsScreen> {
  int _currentIndex = 4; // Cart is at index 4
  String? _selectedPropertyType = 'House';
  String? _selectedDropoffLocation = 'Front Door';
  final TextEditingController _gateCodeController = TextEditingController();
  final TextEditingController _deliveryNotesController = TextEditingController(
    text: 'Ring door bell',
  );
  int _cartCount = 0;
  bool _isLoading = false;


  @override
  void initState() {
    super.initState();
    _fetchCartCount();
    // Set system status bar style
    _fetchCartCount();
  }

  @override
  void dispose() {
    _gateCodeController.dispose();
    _deliveryNotesController.dispose();
    super.dispose();
  }

  Future<void> _fetchCartCount() async {
    final count = await ApiService.getCartCount();
    setState(() {
      _cartCount = count;
    });
  }

  int _getPropertyTypeId(String? type) {
    switch (type) {
      case 'House':
        return 1;
      case 'Apartment':
        return 2;
      case 'Business':
        return 3;
      case 'Other':
        return 4;
      default:
        return 1;
    }
  }

  Future<void> _saveDeliveryInstructions() async {
    setState(() => _isLoading = true);

    final success = await ApiService.addDeliveryInstructions(
      propertyTypeId: _getPropertyTypeId(_selectedPropertyType),
      gateCode: _gateCodeController.text,
      deliveryNotes: _deliveryNotesController.text,
      dropOffLocation: _selectedDropoffLocation ?? 'Front Door',
    );

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        setState(() => _isLoading = true);
        final addressResponse = await ApiService.listUserAddresses();
        setState(() => _isLoading = false);
        
        if (!mounted) return;

        if (addressResponse != null && addressResponse.data != null && addressResponse.data!.isNotEmpty) {
          // Addresses exist -> Show Address List
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UserAddressListScreen(),
            ),
          );
        } else {
          // No addresses -> Show Add Address screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditAddressScreen(isFirstAddress: true),
            ),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save delivery instructions')),
        );
      }
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
      backgroundColor: Color(0xFFE5E7E9),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
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
                  const SizedBox(height: 8),
                  // Title
                  const Text(
                    'Delivery Instructions',
                    style: TextStyle(
                      color: Color(0xFF4D555C),
                      fontSize: 16,
                      fontFamily: 'ITC Avant Garde Gothic Pro',
                      fontWeight: FontWeight.w600,
                      height: 1.30,
                      letterSpacing: -0.48,
                    ),
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
                    // Property Type Section
                    const Text(
                      'Property Type',
                      style: TextStyle(
                        color: Color(0xFF4D555C),
                        fontSize: 14,
                        fontFamily: 'ITC Avant Garde Gothic Pro',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildPropertyTypeButton('House')),
                        const SizedBox(width: 8),
                        Expanded(child: _buildPropertyTypeButton('Apartment')),
                        const SizedBox(width: 8),
                        Expanded(child: _buildPropertyTypeButton('Business')),
                        const SizedBox(width: 8),
                        Expanded(child: _buildPropertyTypeButton('Other')),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Gate or call box Code Section
                    const Text(
                      'Gate or call box Code',
                      style: TextStyle(
                        color: Color(0xFF4D555C),
                        fontSize: 14,
                        fontFamily: 'ITC Avant Garde Gothic Pro',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 1.50,
                            color: const Color(0x99BCC5CC),
                          ),
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      child: TextField(
                        controller: _gateCodeController,
                        decoration: InputDecoration(
                          hintText:
                              'Does the driver need a gate code,call box, etc',
                          hintStyle: TextStyle(
                            color: const Color(0xFF555555),
                            fontSize: 15,
                            fontFamily: 'ITC Avant Garde Gothic Pro',
                            fontWeight: FontWeight.w500,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Delivery Notes Section
                    const Text(
                      'Delivery Notes',
                      style: TextStyle(
                        color: Color(0xFF4D555C),
                        fontSize: 14,
                        fontFamily: 'ITC Avant Garde Gothic Pro',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _deliveryNotesController,
                      maxLines: 4,
                      style: TextStyle(
                        color: const Color(0xFF555555),
                        fontSize: 16,
                        fontFamily: 'ITC Avant Garde Gothic Pro',
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Color(0x9BBCC4CB),
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(16),

                      ),
                    ),
                    const SizedBox(height: 24),
                    // Dropoff Location Section
                    const Text(
                      'Dropoff Location',
                      style: TextStyle(
                        color: const Color(0xFF4D555C),
                        fontSize: 16,
                        fontFamily: 'ITC Avant Garde Gothic Pro',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildRadioOption('Front Door'),
                    _buildRadioOption('Back Door'),
                    _buildRadioOption('Side Porch'),
                    _buildRadioOption('Garage Door'),
                    _buildRadioOption('No Preference'),
                    const SizedBox(height: 32),


                    // Disclaimer
                    Text(
                      "We'll do our best to deliver according to your preferences, but we may not always be able to follow them",
                      style: TextStyle(
                        color: const Color(0xFF4D555C),
                        fontSize: 16,
                        fontFamily: 'ITC Avant Garde Gothic Pro',
                        fontWeight: FontWeight.w500,
                        height: 1.30,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveDeliveryInstructions,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF38B547),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'SAVE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'ITC Avant Garde Gothic Pro',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 32),
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
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                  (route) => false,
                );
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
      ),)
    );
  }

  Widget _buildPropertyTypeButton(String type) {
    final isSelected = _selectedPropertyType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPropertyType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.instance.mutedBlue : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.instance.mutedBlue : Color(0xffBCC5CC),
          ),
        ),
        child: Text(
          type,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF4D555C),
            fontSize: 14,
            fontFamily: 'ITC Avant Garde Gothic Pro',
            fontWeight: FontWeight.w500,
            height: 1.30,
            letterSpacing: -0.42,
          ),
        ),
      ),
    );
  }

  Widget _buildRadioOption(String option) {
    final isSelected = _selectedDropoffLocation == option;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedDropoffLocation = option;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Radio<String>(
              value: option,
              groupValue: _selectedDropoffLocation,
              onChanged: (value) {
                setState(() {
                  _selectedDropoffLocation = value;
                });
              },
              activeColor: AppTheme.instance.mutedBlue,
            ),
            Text(
              option,
              style: TextStyle(
                color: const Color(0xFF4D555C),
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
}
