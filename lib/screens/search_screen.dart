import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/app_theme.dart';
import '../services/api_service.dart';
import '../model/serach_response.dart' as search;
import 'product_detail_screen.dart';
import 'cart_screen.dart';
import '../utils/guest_checker.dart';

class SearchScreen extends StatefulWidget {
  final String initialQuery;

  const SearchScreen({
    super.key,
    this.initialQuery = '',
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<search.Datum> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounceTimer;
  final Map<int, search.Variant> _selectedVariants = {};
  final Set<int> _addingProductIds = {};
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  int _lastPage = 1;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery;
    if (widget.initialQuery.isNotEmpty) {
      _performSearch(widget.initialQuery);
    }
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isSearching && !_isLoadingMore && _currentPage < _lastPage) {
        _performSearch(_searchController.text, loadMore: true);
      }
    }
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    if (_searchController.text.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _currentPage = 1;
        _searchResults = [];
      });
      _performSearch(_searchController.text);
    });
  }

  Future<void> _performSearch(String query, {bool loadMore = false}) async {
    if (query.isEmpty) return;

    if (loadMore) {
      setState(() => _isLoadingMore = true);
      _currentPage++;
    } else {
      setState(() {
        _isSearching = true;
        _currentPage = 1;
      });
    }

    try {
      final response = await ApiService.searchProducts(
        query,
        page: _currentPage,
      );
      if (response != null && response.status == 1) {
        setState(() {
          if (loadMore) {
            _searchResults.addAll(response.data);
          } else {
            _searchResults = response.data;
          }
          _lastPage = response.meta?.lastPage ?? 1;
          _isSearching = false;
          _isLoadingMore = false;
        });
      } else {
        setState(() {
          if (!loadMore) _searchResults = [];
          _isSearching = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      print('Search screen error: $e');
      setState(() {
        if (!loadMore) _searchResults = [];
        _isSearching = false;
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4D555C)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Search Products',
          style: TextStyle(
            color: Color(0xFF374338),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                autofocus: widget.initialQuery.isEmpty,
                decoration: InputDecoration(
                  hintText: 'Search for...',
                  hintStyle: const TextStyle(
                    color: Color(0xff4D555C),
                    fontSize: 16,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF4D555C)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchResults = [];
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),

          // Results
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? _buildEmptyState()
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
                                childAspectRatio: 0.55,
                              ),
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                return _buildProductCard(_searchResults[index]);
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: 0.5,
            child: Image.asset(
              'assets/images/search.png',
              width: 80,
              height: 80,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isEmpty
                ? 'Search for your favorite products'
                : 'No products found for "${_searchController.text}"',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xff4D555C),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(search.Datum product) {
    // Get selected variant or default to first one
    final variant = _selectedVariants[product.id] ??
        (product.variants.isNotEmpty ? product.variants.first : null);

    final price = variant != null ? '\$${variant.productPrice}' : '\$0.00';
    final weight = variant != null ? variant.varientSize : 'N/A';

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
                            fit: BoxFit.contain,
                            memCacheWidth: 250,
                            fadeInDuration: const Duration(milliseconds: 150),
                            placeholder: (context, url) => Container(
                              color: AppTheme.instance.backgroundColor.withOpacity(0.5),
                            ),
                            errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.grey),
                          )
                        : const Icon(Icons.image, color: Colors.grey),
                  ),
                ),
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
                          productId: product.id,
                          variantId: variant.id,
                          quantity: 1,
                        ),
                      )) return;

                      HapticFeedback.lightImpact();
                      setState(() {
                        _addingProductIds.add(product.id);
                      });

                      final success = await ApiService.addProductToCart(
                        productId: product.id,
                        variantId: variant.id,
                        quantity: 1,
                      );
                      
                      if (!mounted) return;
                      setState(() {
                        _addingProductIds.remove(product.id);
                      });

                      if (success) {
                        if (mounted) {
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
                            if (mounted) ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          });
                        }
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to add to cart')),
                          );
                        }
                      }
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _addingProductIds.contains(product.id) ? AppTheme.instance.secondaryColor : Colors.white,
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
                      child: _addingProductIds.contains(product.id)
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
          // Quantity / Weight Selector
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

  void _showVariantPicker(search.Datum product) {
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
                final isSelected = (_selectedVariants[product.id]?.id ??
                        product.variants.first.id) ==
                    variant.id;
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
              }),
              const SizedBox(height: 50),
            ],
          ),
        );
      },
    );
  }
}
