import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:spicekart/model/wishlist_response.dart';
import 'package:spicekart/services/api_service.dart';
import 'package:spicekart/utils/app_theme.dart';
import 'product_detail_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  bool _isLoading = true;
  List<Datum> _wishlistItems = [];
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  int _lastPage = 1;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _fetchWishlist();
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
        _fetchWishlist(loadMore: true);
      }
    }
  }

  Future<void> _fetchWishlist({bool loadMore = false}) async {
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
      final data = await ApiService.listFavourites(page: _currentPage);
      if (mounted) {
        setState(() {
          if (loadMore) {
            _wishlistItems.addAll(data?.data ?? []);
          } else {
            _wishlistItems = data?.data ?? [];
          }
          _lastPage = data?.meta?.lastPage ?? 1;
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
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
        backgroundColor: Colors.grey.shade100,
        body: SafeArea(
          child: Column(
            children: [
              // Custom Header
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Back',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF4D555C),
                          fontWeight: FontWeight.w600,
                          fontFamily: 'ITC Avant Garde Gothic Pro',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'My Wishlist',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.instance.secondaryColor,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'ITC Avant Garde Gothic Pro',
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _wishlistItems.isEmpty
                        ? _buildEmptyState()
                        : _buildWishlist(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_outline, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'Your wishlist is empty',
            style: TextStyle(
              color: Color(0xFF4D555C),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some products to your wishlist to see them here.',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlist() {
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            controller: _scrollController,
            cacheExtent: 1000.0,
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _wishlistItems.length,
            itemBuilder: (context, index) {
              final item = _wishlistItems[index];
              return _buildProductCard(item.product);
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
    );
  }

  Widget _buildProductCard(Product product) {
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: CachedNetworkImage(
                        imageUrl: 'https://spicekart1.mockupz.in/storage/products/${product.productImage}',
                        fit: BoxFit.contain,
                        width: double.infinity,
                        memCacheWidth: 400,
                        fadeInDuration: const Duration(milliseconds: 100),
                        placeholder: (context, url) => Container(
                          color: Colors.grey.shade100,
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.broken_image, size: 50),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.productName,
                        style: const TextStyle(
                          color: Color(0xFF4D555C),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () async {
                  final success = await ApiService.removeFromWishlist(product.id);
                  if (success) {
                    _fetchWishlist();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to remove from wishlist')),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/favorite.png',
                    width: 20,
                    height: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}