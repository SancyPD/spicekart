import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme.dart';
import 'package:spicekart/screens/region_selection_screen.dart';
import 'package:spicekart/screens/wishlist_screen.dart';
import '../services/api_service.dart';
import '../model/serach_response.dart' as search;
import 'brand_category_screen.dart';
import 'cart_screen.dart';
import 'my_account_screen.dart';
import 'hot_food_screen.dart';
import '../model/category_list.dart';
import '../model/weekly_deals.dart' as weekly;
import 'product_detail_screen.dart';
import 'categories_screen.dart';
import 'category_screen.dart';
import 'banner_products_screen.dart';

import '../model/banners_response.dart' as banners;

class HomeScreen extends StatefulWidget {
  final String selectedRegion; // Step 1: Add parameter

  const HomeScreen({
    super.key,
    this.selectedRegion =
        'Kerala', // Default for now to avoid breaking existing calls elsewhere if any
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;
  String _currentTime = '';
  int _currentIndex = 0; // For bottom navigation
  int? _selectedCategoryIndex; // Track selected category
  List<Category> _categories = [];
  bool _isLoadingCategories = true;
  List<weekly.Datum> _weeklyDeals = [];
  bool _isLoadingWeeklyDeals = true;
  int _cartCount = 0;
  List<banners.Datum> _banners = [];
  bool _isLoadingBanners = true;

  // Search related variables
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final GlobalKey _searchFieldKey = GlobalKey();
  List<search.Datum> _searchResults = [];
  bool _isSearching = false;
  bool _showSearchDropdown = false;
  Timer? _debounceTimer;
  search.Datum? _selectedProduct;

  // Map to store selected variant for each weekly deal product
  final Map<int, weekly.Variant> _selectedDealVariants = {};

  @override
  void initState() {
    super.initState();
    _updateTime();
    // Update time every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _updateTime());

    // Add search listener
    _searchController.addListener(_onSearchChanged);

    _fetchCategories();
    _fetchWeeklyDeals();
    _fetchCartCount();
    _fetchBanners();
  }

  void _updateTime() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    setState(() {
      _currentTime = '$hour:$minute';
    });
  }

  void _onSearchChanged() {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // If search is empty, hide dropdown
    if (_searchController.text.isEmpty) {
      setState(() {
        _showSearchDropdown = false;
        _searchResults = [];
        _selectedProduct = null;
      });
      return;
    }

    if (_selectedProduct != null &&
        _searchController.text == _selectedProduct!.productName) {
      return;
    }

    if (_selectedProduct != null &&
        _searchController.text != _selectedProduct!.productName) {
      setState(() {
        _selectedProduct = null;
      });
    }

    // Debounce search - wait 500ms after user stops typing
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(_searchController.text);
    });
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });

    try {
      final response = await ApiService.listAllCategories();
      if (response != null && response.status == 1) {
        setState(() {
          _categories = response.data;
          _isLoadingCategories = false;
        });
      } else {
        setState(() {
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      print('Error fetching categories: $e');
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _fetchWeeklyDeals() async {
    setState(() {
      _isLoadingWeeklyDeals = true;
    });

    try {
      final response = await ApiService.getWeekDealsProducts();
      if (response != null && response.status == 1) {
        setState(() {
          _weeklyDeals = response.data;
          _isLoadingWeeklyDeals = false;
        });
      } else {
        setState(() {
          _isLoadingWeeklyDeals = false;
        });
      }
    } catch (e) {
      print('Error fetching weekly deals: $e');
      setState(() {
        _isLoadingWeeklyDeals = false;
      });
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _showSearchDropdown = true;
    });

    try {
      final response = await ApiService.searchProducts(query);

      if (response != null && response.status == 1) {
        setState(() {
          _searchResults = response.data;
          _isSearching = false;
        });
      } else {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    } catch (e) {
      print('Search error: $e');
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  Future<void> _fetchCartCount() async {
    final count = await ApiService.getCartCount();
    setState(() {
      _cartCount = count;
    });
  }

  Future<void> _fetchBanners() async {
    setState(() {
      _isLoadingBanners = true;
    });

    try {
      final response = await ApiService.getBanners();
      if (response != null && response.status == 1) {
        setState(() {
          _banners = response.data;
          _isLoadingBanners = false;
        });
      } else {
        setState(() {
          _isLoadingBanners = false;
        });
      }
    } catch (e) {
      print('Error fetching banners: $e');
      setState(() {
        _isLoadingBanners = false;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _debounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  double _getDropdownTop() {
    try {
      final RenderBox? renderBox =
          _searchFieldKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final position = renderBox.localToGlobal(Offset.zero);
        final height = renderBox.size.height;
        return position.dy + height;
      }
    } catch (e) {
      print('Error calculating dropdown position: $e');
    }
    return 200; // Fallback position
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final screenWidth = MediaQuery.of(context).size.width;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppTheme.instance.primaryDeepBlue,
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
                    color: AppTheme.instance.primaryDeepBlue,
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
                              'Spicekart',
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

                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.favorite_border,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const WishlistScreen()),
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
                            Text(
                              "Selected location", // Use selected region here
                              style: const TextStyle(
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
                        const Padding(
                          padding: EdgeInsets.only(left: 28),
                          child: Text(
                            'Bagby Houston, TX 77002',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Colors.white70,
                            ),
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
                        if (!_isLoadingBanners && _banners.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            child: SizedBox(
                              height: 120, // Fixed height for banner
                              child: PageView.builder(
                                itemCount: _banners.length,
                                itemBuilder: (context, index) {
                                  final banner = _banners[index];
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
                                      child: Image.network(
                                        'https://spicekart.mockupz.in/storage/banners/app/${banner.bannerImageApp}',
                                        width: double.infinity,
                                        fit: BoxFit.contain,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.broken_image,
                                                  size: 50,
                                                ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        if (_isLoadingBanners)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(child: CircularProgressIndicator()),
                          ),
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
                              decoration: InputDecoration(
                                hintText: 'Search for...',
                                hintStyle: const TextStyle(
                                  color: Color(0xff4D555C),
                                  fontSize: 14,
                                ),
                                suffixIcon: _selectedProduct != null
                                    ? IconButton(
                                        icon:  Icon(
                                          Icons.arrow_forward,
                                          size: 20,
                                          color: AppTheme.instance.primaryDeepBlue,
                                        ),
                                        onPressed: () {
                                          final productId =
                                              _selectedProduct!.id;
                                          _searchController.clear();
                                          setState(() {
                                            _selectedProduct = null;
                                          });
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ProductDetailScreen(
                                                    productId: productId,
                                                  ),
                                            ),
                                          );
                                        },
                                      )
                                    : _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear, size: 20),
                                        onPressed: () {
                                          _searchController.clear();
                                          FocusScope.of(context).unfocus();
                                          setState(() {
                                            _showSearchDropdown = false;
                                            _searchResults = [];
                                            _selectedProduct = null;
                                          });
                                        },
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
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const RegionSelectionScreen(),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.instance.secondaryLightBlue,
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
                                  widget.selectedRegion,
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
                              _isLoadingCategories
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : GridView.builder(
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 4,
                                            mainAxisSpacing: 16,
                                            crossAxisSpacing: 16,
                                            childAspectRatio: 0.65,
                                          ),
                                      itemCount: _categories.length,
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        return _buildCategoryCard(
                                          index,
                                          _categories[index],
                                        );
                                      },
                                    ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        // Weekly Deals Section
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
                              _isLoadingWeeklyDeals
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : GridView.builder(
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
                                      itemCount: _weeklyDeals.length,
                                      itemBuilder: (context, index) {
                                        return _buildProductCard(
                                          _weeklyDeals[index],
                                        );
                                      },
                                    ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Search Results Dropdown Overlay - Positioned above all content
            if (_showSearchDropdown)
              Positioned(
                top: _getDropdownTop(),
                left: 16,
                right: 16,
                child: Material(
                  elevation: 8,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 300),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: _isSearching
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : _searchResults.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              'No products found',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xff4D555C),
                                fontSize: 14,
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: _searchResults.length,
                            separatorBuilder: (context, index) =>
                                Divider(height: 1, color: Colors.grey.shade200),
                            itemBuilder: (context, index) {
                              final product = _searchResults[index];
                              return ListTile(
                                title: Text(
                                  product.productName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF323C42),
                                  ),
                                ),
                                subtitle: Text(
                                  product.productDescription,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xff4D555C),
                                  ),
                                ),
                                onTap: () {
                                  // Handle product selection
                                  print(
                                    'Selected product: ${product.productName}',
                                  );
                                  setState(() {
                                    _showSearchDropdown = false;
                                    _selectedProduct = product;
                                    _searchController.text =
                                        product.productName;
                                  });
                                  _searchFocusNode.unfocus();
                                  // Navigation is now handled by the suffix arrow icon
                                },
                              );
                            },
                          ),
                  ),
                ),
              ),
          ],
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
            bottom: false,
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                if (index == 0) {
                  // Home icon tapped
                  if (_currentIndex != index) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                      (route) => false,
                    );
                  }
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
        ),
      ),
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
                          ? Image.network(
                              'https://spicekart.mockupz.in/storage/products/${product.productImage}',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset(
                                    'assets/images/no_image.png',
                                    fit: BoxFit.contain,
                                  ),
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
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(
                        color: AppTheme.instance.secondaryLightBlue,
                        width: 1,
                      ),
                    ),
                    child:  Icon(
                      Icons.add,
                      color: AppTheme.instance.secondaryLightBlue,
                      size: 15,
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
                  selectedTileColor: AppTheme.instance.lightBlueBg,
                  onTap: () {
                    setState(() {
                      _selectedDealVariants[product.id] = variant;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
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
                    ? AppTheme.instance.lightBlueBg
                    : AppTheme.instance.lightBlueBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child:
                  category.categoryImage != null &&
                      category.categoryImage.toString().isNotEmpty
                  ? Image.network(
                      'https://spicekart.mockupz.in/storage/categories/${category.categoryImage}',
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
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
              color: isSelected ? AppTheme.instance.secondaryLightBlue : Color(0xFF374338),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
