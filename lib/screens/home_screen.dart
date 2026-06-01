import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';
import '../screens/region_selection_screen.dart';
import '../screens/wishlist_screen.dart';
import 'brand_category_screen.dart';
import 'cart_screen.dart';
import '../utils/guest_checker.dart';
import 'my_account_screen.dart';
import 'hot_food_screen.dart';
import 'usual_items_screen.dart';
import '../model/category_list.dart';
import '../model/weekly_deals.dart' as weekly;
import 'product_detail_screen.dart';
import 'categories_screen.dart';
import 'category_screen.dart';
import 'banner_products_screen.dart';
import 'search_screen.dart';
import 'notifications_screen.dart';

import 'user_address_list_screen.dart';
import 'add_edit_address_screen.dart';
import '../model/user_address.dart';
import '../model/address_list_response.dart';
import '../model/zip_code_list_response.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../controllers/cart_controller.dart';
import '../controllers/home_controller.dart';

class HomeScreen extends StatefulWidget {
  final String selectedRegion; // Step 1: Add parameter

  const HomeScreen({
    super.key,
    this.selectedRegion = '', // Empty by default
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;
  String _currentTime = '';
  final HomeController homeController = HomeController.to;
  List<UserAddress> _userAddresses = [];
  final Set<int> _addingProductIds = {};
  UserAddress? _defaultAddress;
  bool _isLoadingAddresses = true;
  int _selectedCategoryIndex = -1;

  // Search related variables
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final GlobalKey _searchFieldKey = GlobalKey();

  // Map to store selected variant for each weekly deal product
  final Map<int, weekly.Variant> _selectedDealVariants = {};

  @override
  void initState() {
    super.initState();
    _updateTime();
    // Update time every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _updateTime());

    _fetchUserAddresses();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowPincodePopup();
    });
  }

  Future<void> _checkAndShowPincodePopup() async {
    if (ApiService.accessToken == null) return;
    
    final seen = await ApiService.checkPincodePopupSeen();
    if (!seen) {
      _showPincodePopup();
    }
  }

  Future<String?> _showDeliverablePincodesDialog(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Deliverable Zipcodes',
            style: TextStyle(
              color: AppTheme.instance.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: FutureBuilder<ZipCodeListResponse?>(
              future: ApiService.listAllZipcodesWithZones(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || snapshot.data == null) {
                  return const Center(child: Text('Failed to load zipcodes'));
                }
                
                final zipcodes = snapshot.data!.data;
                if (zipcodes.isEmpty) {
                  return const Center(child: Text('No deliverable zipcodes available'));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: zipcodes.length,
                  itemBuilder: (context, index) {
                    final item = zipcodes[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      leading: Icon(Icons.location_on, color: AppTheme.instance.primaryColor),
                      title: Text(
                        item.zipCode,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Text(
                        '${item.cityName} (${item.zone.name})',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      onTap: () {
                        Navigator.of(dialogContext).pop(item.zipCode);
                      },
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'CLOSE',
                style: TextStyle(
                  color: AppTheme.instance.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showPincodePopup() {
    final TextEditingController pincodeController = TextEditingController();
    String errorMessage = '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                'Delivery Location',
                style: TextStyle(
                  color: AppTheme.instance.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Please enter your delivery zipcode to verify.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: pincodeController,
                    decoration: InputDecoration(
                      labelText: 'Enter Zipcode',
                      hintText: 'e.g. 02108',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: errorMessage.isNotEmpty ? Colors.red : Colors.grey.shade400,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: errorMessage.isNotEmpty ? Colors.red : AppTheme.instance.primaryColor,
                          width: 2,
                        ),
                      ),
                      prefixIcon: const Icon(Icons.location_on_outlined),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      if (errorMessage.isNotEmpty) {
                        setDialogState(() {
                          errorMessage = '';
                        });
                      }
                    },
                  ),
                  if (errorMessage.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            errorMessage,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () async {
                            final selectedZipcode = await _showDeliverablePincodesDialog(context);
                            if (selectedZipcode != null) {
                              setDialogState(() {
                                pincodeController.text = selectedZipcode;
                                errorMessage = '';
                              });
                            }
                          },
                          child: const Icon(
                            Icons.info_outline,
                            color: Colors.red,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      FocusScope.of(context).unfocus();
                      final enteredPincode = pincodeController.text.trim();
                      if (enteredPincode.isEmpty) return;
                      
                      setDialogState(() {
                        errorMessage = '';
                      });

                      final response = await ApiService.findValidZipCode(enteredPincode);
                      bool isValid = response;

                      if (isValid) {
                        await ApiService.savePincode(enteredPincode);
                        await ApiService.setPincodePopupSeen();
                        if (!mounted) return;
                        Navigator.of(context).pop();
                      } else {
                        setDialogState(() {
                          errorMessage = 'We do not cater to this zip code as of now !';
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.instance.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      'VERIFY',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _fetchUserAddresses() async {
    setState(() {
      _isLoadingAddresses = true;
    });

    try {
      final response = await ApiService.listUserAddresses();
      if (response != null && response.status == 1 && response.data != null) {
        setState(() {
          _userAddresses = response.data!;
          _defaultAddress = _userAddresses.firstWhere(
            (addr) => addr.isDefault,
            orElse: () => _userAddresses.isNotEmpty
                ? _userAddresses.first
                : UserAddress(
                    addressLine1: '',
                    city: '',
                    state: '',
                    country: '',
                    postalCode: '',
                    addressType: '',
                    isDefault: false,
                  ),
          );
          if (_userAddresses.isEmpty) _defaultAddress = null;
          _isLoadingAddresses = false;
        });
      } else {
        setState(() {
          _userAddresses = [];
          _defaultAddress = null;
          _isLoadingAddresses = false;
        });
      }
    } catch (e) {
      print('Error fetching addresses: $e');
      setState(() {
        _isLoadingAddresses = false;
      });
    }
  }

  void _updateTime() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    setState(() {
      _currentTime = '$hour:$minute';
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppTheme.instance,
      builder: (context, _) {
        final statusBarHeight = MediaQuery.of(context).padding.top;
    final screenWidth = MediaQuery.of(context).size.width;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppTheme.instance.primaryColor,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            // Main content
            Column(
              children: [
                // Blue Header Section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.instance.primaryColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Spicekart title and icons row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'SpiceKart',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.notifications_outlined,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    if (!GuestChecker.check()) return;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const NotificationsScreen(),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.favorite_border,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    if (!GuestChecker.check(
                                      action:  PendingAction(
                                        type: PendingActionType.wishlist,
                                      ),
                                    )) return;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const WishlistScreen(),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.person_outline,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const MyAccountScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        // const SizedBox(height: 16),
                        // Location section
                        GestureDetector(
                          onTap: () async {
                            if (_userAddresses.isEmpty) {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AddEditAddressScreen(),
                                ),
                              );
                              if (!mounted) return;
                              if (result == true) {
                                _fetchUserAddresses();
                              }
                            } else {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const UserAddressListScreen(
                                    isFromCheckout: false,
                                  ),
                                ),
                              );
                              if (!mounted) return;
                              if (result == true || result == null) {
                                _fetchUserAddresses();
                              }
                            }
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Deliver to',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    "Selected location",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.only(left: 28),
                                child: _isLoadingAddresses
                                    ? const SizedBox(
                                        height: 12,
                                        width: 12,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white70,
                                        ),
                                      )
                                    : Text(
                                        _defaultAddress != null
                                            ? '${_defaultAddress!.addressLine1}${_defaultAddress!.city.isNotEmpty ? ', ${_defaultAddress!.city}' : ''}${_defaultAddress!.postalCode.isNotEmpty ? ', ${_defaultAddress!.postalCode}' : ''}'
                                            : 'Add new address',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white70,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Main scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Promotional Banner
                        Obx(() {
                          if (homeController.isLoadingBanners.value) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          if (homeController.bannersList.isEmpty) return const SizedBox.shrink();
                          
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            child: SizedBox(
                              height: 120, // Fixed height for banner
                              child: PageView.builder(
                                itemCount: homeController.bannersList.length,
                                itemBuilder: (context, index) {
                                  final banner = homeController.bannersList[index];
                                  return GestureDetector(
                                    onTap: () async {
                                      final response = await ApiService.getBannerProducts(banner.id);
                                      if (response != null && response.data.product.isNotEmpty) {
                                        if (!mounted) return;
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => BannerProductsScreen(
                                              bannerId: banner.id,
                                              bannerName: banner.title,
                                            ),
                                          ),
                                        );
                                      } else {
                                        if (!mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('No products available for this banner')),
                                        );
                                      }
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: CachedNetworkImage(
                                        imageUrl: 'https://spicekart1.mockupz.in/storage/banners/app/${banner.bannerImageApp}',
                                        width: double.infinity,
                                        fit: BoxFit.contain,
                                        memCacheWidth: 800, // Optimize memory for banner
                                        fadeInDuration: const Duration(milliseconds: 150),
                                        placeholder: (context, url) => Container(
                                          color: Colors.grey.shade100,
                                        ),
                                        errorWidget: (context, url, error) => const Icon(
                                          Icons.broken_image,
                                          size: 50,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        }),
                        // Search Bar
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Container(
                            key: _searchFieldKey,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              onChanged: (_) {
                                // Rebuild to toggle suffix (clear/arrow) visibility while typing.
                                setState(() {});
                              },
                              onSubmitted: (value) {
                                if (value.isNotEmpty) {
                                  _searchFocusNode.unfocus();
                                  _searchController.clear();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SearchScreen(initialQuery: value),
                                    ),
                                  );
                                }
                              },
                              decoration: InputDecoration(
                                hintText: 'Search for...',
                                hintStyle: const TextStyle(
                                  color: Color(0xff4D555C),
                                  fontSize: 14,
                                ),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.clear, size: 20),
                                            onPressed: () {
                                              _searchController.clear();
                                              FocusScope.of(context).unfocus();
                                            },
                                          ),
                                          IconButton(
                                            icon:  Icon(
                                              Icons.arrow_forward,
                                              size: 20,
                                              color: AppTheme.instance.primaryColor,
                                            ),
                                            onPressed: () {
                                              final query = _searchController.text;
                                              _searchFocusNode.unfocus();
                                              _searchController.clear();
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => SearchScreen(initialQuery: query),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Image.asset(
                                          'assets/images/search.png',
                                          width: 25,
                                          height: 25,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Region Filter Bar
                        GestureDetector(
                          onTap: () async {
                            final result = await Get.to(() => const RegionSelectionScreen(fromHome: true));
                            if (mounted && result != null) {
                              homeController.refreshData();
                              setState(() {});
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.instance.secondaryColor,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                 Text(
                                   (ApiService.selectedRegion != null && ApiService.selectedRegion!.isNotEmpty)
                                       ? ApiService.selectedRegion!
                                       : (widget.selectedRegion.isNotEmpty ? widget.selectedRegion : 'Kerala'),
                                  // Use selected region here as well
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Shop by Category Section
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Shop by Category',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF374338),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Obx(() {
                                if (homeController.isLoadingCategories.value) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                return GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 4,
                                        mainAxisSpacing: 16,
                                        crossAxisSpacing: 16,
                                        childAspectRatio: 0.6,
                                      ),
                                  itemCount: homeController.categories.length,
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  physics:
                                      const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return _buildCategoryCard(
                                      index,
                                      homeController.categories[index],
                                    );
                                  },
                                );
                              }),
                            ],
                          ),
                        ),
                        // Weekly Deals Section
                        Obx(() {
                          if (!homeController.isLoadingWeeklyDeals.value && homeController.weeklyDeals.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Column(
                            children: [
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Weekly Deals',
                                      style: TextStyle(
                                        color: Color(0xFF374338),
                                        fontSize: 14,
                                        fontFamily: 'ITC Avant Garde Gothic Pro',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    if (homeController.isLoadingWeeklyDeals.value)
                                      const Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    else
                                      GridView.builder(
                                        shrinkWrap: true,
                                        padding: EdgeInsets.zero,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 3,
                                              crossAxisSpacing: 12,
                                              mainAxisSpacing: 16,
                                              childAspectRatio: 0.52,
                                            ),
                                        itemCount: homeController.weeklyDeals.length,
                                        itemBuilder: (context, index) {
                                          return _buildProductCard(
                                            homeController.weeklyDeals[index],
                                          );
                                        },
                                      ),
                                    const SizedBox(height: 32),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
        );
      },
    );
  }

  Widget _buildProductCard(weekly.Datum deal) {
    final product = deal.products;
    // Get selected variant or default to first one
    final variant =
        _selectedDealVariants[product.id] ??
        (product.variants.isNotEmpty ? product.variants.first : null);

    final price = variant != null ? '\$${variant.productPrice}' : '\$0.00';
    final weight = variant != null ? variant.varientSize : 'N/A';
    final hasDiscount = false; // Add discount logic if available in the model

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(productId: product.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Container with Border and Add Button
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: const Color(0xFFC8D3D9),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child:
                          product.productImage != null &&
                              product.productImage.toString().isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: 'https://spicekart1.mockupz.in/storage/products/${product.productImage}',
                              fit: BoxFit.contain,
                              // memCacheWidth: 85, // Optimize memory for thumbnails
                              fadeInDuration: const Duration(milliseconds: 150),
                              placeholder: (context, url) => Container(
                                color: AppTheme.instance.backgroundColor.withOpacity(0.5),
                              ),
                              errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.grey),
                            )
                          : Image.asset(
                              'assets/images/no_image.png',
                              fit: BoxFit.contain,
                            ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -5,
                  right: -5,
                  child: GestureDetector(
                    onTap: () async {
                      if (variant == null) return;

                      if (!GuestChecker.check(
                        action: PendingAction(
                          type: PendingActionType.cart,
                          productId: product.id.toInt(),
                          variantId: variant.id.toInt(),
                          quantity: 1,
                        ),
                      )) return;

                      HapticFeedback.lightImpact();
                      setState(() {
                        _addingProductIds.add(product.id.toInt());
                      });

                      final success = await ApiService.addProductToCart(
                        productId: product.id.toInt(),
                        variantId: variant.id.toInt(),
                        quantity: 1,
                      );
                      if (!mounted) return;
                      setState(() {
                        _addingProductIds.remove(product.id.toInt());
                      });
                      if (success) {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            duration: const Duration(seconds: 5),
                            behavior: SnackBarBehavior.floating,
                            content: Text('${product.productName} added to cart'),
                            action: SnackBarAction(
                              label: 'View Cart',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const CartScreen()),
                                );
                              },
                            ),
                          ),
                        );
                        // Force hide after 5 sec
                         ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        // homeController.refreshData(); // Optional refresh if needed
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to add to cart')),
                        );
                      }
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _addingProductIds.contains(product.id.toInt()) ? AppTheme.instance.secondaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(
                          color: AppTheme.instance.secondaryColor,
                          width: 1,
                        ),
                      ),
                      child: _addingProductIds.contains(product.id.toInt())
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
                              size: 15,
                            ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              price,
              style: const TextStyle(
                color: Color(0xFF171717),
                fontSize: 16,
                fontFamily: 'ITC Avant Garde Gothic Pro',
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              product.productName,
              style: const TextStyle(
                color: Color(0xFF4D555C),
                fontSize: 14,
                fontFamily: 'ITC Avant Garde Gothic Pro',
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _showDealVariantPicker(product),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    weight,
                    style: const TextStyle(
                      color: Color(0xFF6D7A82),
                      fontSize: 14,
                      fontFamily: 'ITC Avant Garde Gothic Pro',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Image.asset(
                    'assets/images/arrow_down.png',
                    height: 12,
                    width: 12,
                    color: const Color(0xFF6D7A82),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDealVariantPicker(weekly.Products product) {
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
                ),
              ),
              const SizedBox(height: 10),
              ...product.variants.map((variant) {
                final isSelected =
                    (_selectedDealVariants[product.id]?.id ??
                        product.variants.first.id) ==
                    variant.id;
                return ListTile(
                  title: Text(variant.varientSize),
                  trailing: Text('\$${variant.productPrice}'),
                  selected: isSelected,
                  selectedTileColor: AppTheme.instance.backgroundColor,
                  onTap: () {
                    setState(() {
                      _selectedDealVariants[product.id] = variant;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
              const SizedBox(height: 50),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryCard(int index, Category category) {
    final isSelected = _selectedCategoryIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategoryIndex = index;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryScreen(
              categoryId: category.id,
              categoryName: category.categoryName,
            ),
          ),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.only(left: 5, right: 5, top: 3, bottom: 3),
              decoration: ShapeDecoration(
                color: isSelected
                    ? AppTheme.instance.backgroundColor
                    : AppTheme.instance.backgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child:
                  category.categoryImage != null &&
                      category.categoryImage.toString().isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: 'https://spicekart1.mockupz.in/storage/categories/${category.categoryImage}',
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => Container(
                        width: 40,
                        height: 40,
                        color: AppTheme.instance.backgroundColor.withOpacity(0.5),
                      ),
                      errorWidget: (context, url, error) => Image.asset(
                        'assets/images/no_image.png',
                        width: 40,
                        height: 40,
                        fit: BoxFit.contain,
                      ),
                    )
                  : Image.asset(
                      'assets/images/no_image.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category.categoryName,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected ? AppTheme.instance.secondaryColor : Color(0xFF374338),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
