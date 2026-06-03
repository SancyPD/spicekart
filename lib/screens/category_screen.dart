import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/app_theme.dart';
import '../services/api_service.dart';
import '../model/brands.dart' as brands;
import '../model/products_list_response.dart' as products;
import '../model/serach_response.dart' as search;
import 'product_detail_screen.dart';
import 'cart_screen.dart';
import '../utils/guest_checker.dart';

class CategoryScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const CategoryScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<brands.Datum> _brands = [];
  List<products.Datum> _allProducts = [];
  List<products.Datum> _filteredProducts = [];
  int? _selectedBrandId;
  bool _isLoadingBrands = true;
  bool _isLoadingProducts = true;
  bool _isSearching = false;
  Timer? _searchDebounce;
  final Set<int> _addingProductIds = {};
  // Map to store selected variant for each product ID
  final Map<int, products.Variant> _selectedVariants = {};
  late double screenWidth;
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  int _lastPage = 1;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _fetchBrands();
    _fetchProducts();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingProducts && !_isLoadingMore && _currentPage < _lastPage) {
        if (_isSearching) {
          _fetchSearchProducts(loadMore: true);
        } else {
          _fetchProducts(loadMore: true);
        }
      }
    }
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      final query = _searchController.text.trim();
      if (query.isEmpty) {
        _isSearching = false;
        _fetchProducts();
      } else {
        _fetchSearchProducts();
      }
    });
  }

  Future<void> _fetchBrands() async {
    setState(() => _isLoadingBrands = true);
    try {
      final response = await ApiService.listBrands(categoryId: widget.categoryId);
      if (response != null && response.status == 1) {
        setState(() {
          _brands = response.data;
          _isLoadingBrands = false;
        });
      } else {
        setState(() => _isLoadingBrands = false);
      }
    } catch (e) {
      print('Error fetching brands: $e');
      setState(() => _isLoadingBrands = false);
    }
  }

  Future<void> _fetchProducts({bool loadMore = false}) async {
    if (loadMore) {
      setState(() => _isLoadingMore = true);
      _currentPage++;
    } else {
      setState(() {
        _isLoadingProducts = true;
        _currentPage = 1;
      });
    }

    try {
      final response = await ApiService.listProducts(
        categoryId: widget.categoryId,
        brandId: _selectedBrandId,
        page: _currentPage,
      );
      if (response != null && response.status == 1) {
        setState(() {
          if (loadMore) {
            _allProducts.addAll(response.data);
          } else {
            _allProducts = response.data;
          }
          _lastPage = response.meta?.lastPage ?? 1;
          _isLoadingProducts = false;
          _isLoadingMore = false;
          _filterProducts();
        });
      } else {
        setState(() {
          if (!loadMore) {
            _allProducts = [];
            _filteredProducts = [];
          }
          _isLoadingProducts = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      print('Error fetching products: $e');
      setState(() {
        if (!loadMore) {
          _allProducts = [];
          _filteredProducts = [];
        }
        _isLoadingProducts = false;
        _isLoadingMore = false;
      });
    }
  }

  products.Datum _mapSearchProductToProductsDatum(search.Datum item) {
    return products.Datum(
      id: item.id,
      slug: item.slug,
      productName: item.productName,
      productDescription: item.productDescription,
      productBarcode: item.productBarcode,
      categoryId: item.categoryId,
      categoryName: item.categoryName,
      brandId: item.brandId,
      brandName: item.brandName,
      productImage: item.productImage,
      metaTitle: item.metaTitle,
      metaDescription: item.metaDescription,
      metaKeywords: item.metaKeywords,
      productTax: item.productTax,
      productStatus: item.productStatus,
      variants: item.variants
          .map(
            (v) => products.Variant(
              id: v.id,
              productId: v.productId,
              varientSize: v.varientSize,
              productPrice: v.productPrice,
              storePrice: v.storePrice,
            ),
          )
          .toList(),
      regions: const [],
      ratings: const [],
    );
  }

  Future<void> _fetchSearchProducts({bool loadMore = false}) async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    if (loadMore) {
      setState(() => _isLoadingMore = true);
      _currentPage++;
    } else {
      setState(() {
        _isSearching = true;
        _isLoadingProducts = true;
        _currentPage = 1;
      });
    }

    try {
      final response = await ApiService.searchProducts(
        query,
        categoryId: widget.categoryId,
        brandId: _selectedBrandId,
        page: _currentPage,
      );

      if (response != null && response.status == 1) {
        final mapped = response.data.map(_mapSearchProductToProductsDatum).toList();
        setState(() {
          if (loadMore) {
            _allProducts.addAll(mapped);
          } else {
            _allProducts = mapped;
          }
          _lastPage = response.meta?.lastPage ?? 1;
          _isLoadingProducts = false;
          _isLoadingMore = false;
          _filterProducts();
        });
      } else {
        setState(() {
          if (!loadMore) {
            _allProducts = [];
            _filteredProducts = [];
          }
          _isLoadingProducts = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      print('Error searching products: $e');
      setState(() {
        if (!loadMore) {
          _allProducts = [];
          _filteredProducts = [];
        }
        _isLoadingProducts = false;
        _isLoadingMore = false;
      });
    }
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _allProducts.where((product) {
        final matchesSearch = product.productName.toLowerCase().contains(query);
        return matchesSearch;
      }).toList();
    });
  }

  void _onBrandSelected(int? brandId) {
    if (_selectedBrandId == brandId) {
      setState(() => _selectedBrandId = null);
    } else {
      setState(() => _selectedBrandId = brandId);
    }
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      _fetchSearchProducts();
    } else {
      _fetchProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
     screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 80,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Center(
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
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xff9FA6AD), width: 1),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for...',
                  hintStyle: const TextStyle(
                    color: Color(0xFF4D555C),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20, color: Color(0xFF4D555C)),
                          onPressed: () {
                            _searchController.clear();
                            FocusScope.of(context).unfocus();
                          },
                        )
                      : Padding(
                          padding: const EdgeInsets.all(12),
                          child: Image.asset(
                            'assets/images/search.png',
                            width: 20,
                            height: 20,
                            fit: BoxFit.contain,
                          ),
                        ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),

          // Category Name
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              widget.categoryName,
              style: const TextStyle(
                color: Color(0xFF364238),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Brands List
          SizedBox(
            height: 70,
            child: _isLoadingBrands
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _brands.length,
                    itemBuilder: (context, index) {
                      final brand = _brands[index];
                      final isSelected = _selectedBrandId == brand.id;
                      return GestureDetector(
                        onTap: () => _onBrandSelected(brand.id),
                        child: Container(
                          width: 90,
                          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF34B355) : const Color(0x677E6A3D),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: brand.brandImage.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: 'https://spicekart1.mockupz.in/storage/brands/${brand.brandImage}',
                                    width: 60,
                                    height: 40,
                                    fit: BoxFit.contain,
                                    placeholder: (context, url) => Container(
                                      width: 60,
                                      height: 40,
                                      color: AppTheme.instance.backgroundColor.withOpacity(0.5),
                                    ),
                                    errorWidget: (context, url, error) => Text(
                                      brand.brandName,
                                      style: const TextStyle(fontSize: 10),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                : Text(
                                    brand.brandName,
                                    style: const TextStyle(fontSize: 10),
                                    textAlign: TextAlign.center,
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          const SizedBox(height: 16),

          // Product Grid
          Expanded(
            child: _isLoadingProducts
                ? const Center(child: CircularProgressIndicator())
                : _filteredProducts.isEmpty
                    ? const Center(child: Text('No products found'))
                    : Column(
                        children: [
                          Expanded(
                            child: GridView.builder(
                              controller: _scrollController,
                              cacheExtent: 1000.0,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.50,
                              ),
                              itemCount: _filteredProducts.length,
                              itemBuilder: (context, index) {
                                return _buildProductCard(_filteredProducts[index]);
                              },
                            ),
                          ),
                          if (_isLoadingMore)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(products.Datum product) {
    // Get selected variant or default to first one
    final variant = _selectedVariants[product.id] ?? 
                   (product.variants.isNotEmpty ? product.variants.first : null);
    
    final price = variant != null ? '\$${variant.productPrice}' : '\$0.00';
    final weight = variant != null ? variant.varientSize : 'N/A';
    
    // For demo purposes, we'll assume a 20% discount if the price ends in .75 as in the image
    final bool hasDiscount = true; 

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(productId: product.id),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image Container
          AspectRatio(
            aspectRatio: 1.0,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: AppTheme.instance.backgroundColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: product.productImage.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: 'https://spicekart1.mockupz.in/storage/products/${product.productImage}',
                            height: double.infinity,
                            fit: BoxFit.contain,
                            memCacheWidth: 250, // Optimize memory for 3-column grid
                            fadeInDuration: const Duration(milliseconds: 150),
                            placeholder: (context, url) => Container(
                              color: AppTheme.instance.backgroundColor.withOpacity(0.5),
                            ),
                            errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.grey),
                          )
                        : const Icon(Icons.image, color: Colors.grey),
                  ),
                ),
                // Discount badge
                /*if (hasDiscount)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE31E24),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: const Text(
                        '20% Off',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),*/
                // Add button
                Positioned(
                  bottom: -4,
                  right: -4,
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
                        Future.delayed(const Duration(seconds: 5), () {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        });
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
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppTheme.instance.secondaryColor, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
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
            ),
          ),
          const SizedBox(height: 2),
          // Product Name
          Text(
            product.productName,
            style: const TextStyle(
              color: Color(0xFF4D555C),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Quantity / Weight
          GestureDetector(
            onTap: () => _showVariantPicker(product),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    weight,
                    style: TextStyle(
                      color: AppTheme.instance.secondaryColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  size: 14,
                  color: AppTheme.instance.secondaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showVariantPicker(products.Datum product) {
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
                final isSelected = (_selectedVariants[product.id]?.id ?? product.variants.first.id) == variant.id;
                return ListTile(
                  title: Text(variant.varientSize),
                  trailing: Text('\$${variant.productPrice}'),
                  selected: isSelected,
                  selectedTileColor: AppTheme.instance.backgroundColor,
                  onTap: () {
                    setState(() {
                      _selectedVariants[product.id] = variant;
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
}
