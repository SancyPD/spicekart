import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/app_theme.dart';
import '../services/api_service.dart';
import '../model/usuals_response.dart' as usuals;
import 'product_detail_screen.dart';
import 'home_screen.dart';
import 'categories_screen.dart';
import 'hot_food_screen.dart';
import 'cart_screen.dart';
import '../utils/guest_checker.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class UsualItemsScreen extends StatefulWidget {
  const UsualItemsScreen({super.key});

  @override
  State<UsualItemsScreen> createState() => _UsualItemsScreenState();
}

class _UsualItemsScreenState extends State<UsualItemsScreen> {
  List<usuals.Datum> _usualItems = [];
  bool _isLoading = true;
  final Map<int, usuals.Variant> _selectedVariants = {};
  final ScrollController _scrollController = ScrollController();
  final Set<int> _addingProductIds = {};
  int _currentPage = 1;
  int _lastPage = 1;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _fetchUsualItems();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && !_isLoadingMore && _currentPage < _lastPage) {
        _fetchUsualItems(loadMore: true);
      }
    }
  }

  Future<void> _fetchUsualItems({bool loadMore = false}) async {
    if (loadMore) {
      setState(() => _isLoadingMore = true);
      _currentPage++;
    } else {
      setState(() {
        _isLoading = true;
        _currentPage = 1;
      });
    }

    try {
      final response = await ApiService.listUsualItems(
      );
      if (response != null && response.status == 1) {
        setState(() {
          if (loadMore) {
            _usualItems.addAll(response.data);
          } else {
            _usualItems = response.data;
          }
          _isLoading = false;
          _isLoadingMore = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      print('Error fetching usual items: $e');
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            'My Usuals',
            style: TextStyle(
              color: Color(0xFF374338),
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'ITC Avant Garde Gothic Pro',
            ),
          ),
          centerTitle: true,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _usualItems.isEmpty
                ? const Center(child: Text('No usual items found'))
                : Column(
                    children: [
                      Expanded(
                        child: GridView.builder(
                          controller: _scrollController,
                          cacheExtent: 1000.0,
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.55,
                          ),
                          itemCount: _usualItems.length,
                          itemBuilder: (context, index) {
                            return _buildProductCard(_usualItems[index].item);
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
        );
      },
    );
  }

  Widget _buildProductCard(usuals.Item product) {
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
                              color: AppTheme.instance.backgroundColor,
                            ),
                            errorWidget: (context, url, error) => const Icon(Icons.image, color: Colors.grey),
                          )
                        : const Icon(Icons.image, color: Colors.grey),
                  ),
                ),
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
          Text(
            price,
            style: const TextStyle(
              color: Color(0xFF171717),
              fontSize: 15,
              fontWeight: FontWeight.w600,
              fontFamily: 'ITC Avant Garde Gothic Pro',
            ),
          ),
          const SizedBox(height: 2),
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
                      fontFamily: 'ITC Avant Garde Gothic Pro',
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

  void _showVariantPicker(usuals.Item product) {
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
