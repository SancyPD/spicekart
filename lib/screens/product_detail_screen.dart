import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/app_theme.dart';
import 'package:spicekart/model/product_detail_response.dart' as pd;
import 'package:spicekart/services/api_service.dart';
import 'package:spicekart/screens/full_screen_image_viewer.dart';
import 'cart_screen.dart';
import '../utils/guest_checker.dart';
import 'product_reviews_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  pd.ProductDetailResponse? _productDetail;
  bool _isLoading = true;
  int _quantity = 1;
  int _selectedVariantIndex = 0;
  bool _isAboutExpanded = false;
  int _currentImageIndex = 0;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _fetchProductDetails();
  }

  Future<void> _fetchProductDetails() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await ApiService.getProductDetails(widget.productId);
      if (response != null && response.status == 1) {
        setState(() {
          _productDetail = response;
          _isLoading = false;
          _isFavorite = response.data.isFavourite;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching product details: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (!GuestChecker.check(
      action: PendingAction(
        type: PendingActionType.wishlist,
        productId: widget.productId,
      ),
    )) return;

    final success = _isFavorite
        ? await ApiService.removeFromWishlist(widget.productId)
        : await ApiService.addFavourite(widget.productId);

    if (success) {
      setState(() {
        _isFavorite = !_isFavorite;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite ? 'Added to favorites' : 'Removed from favorites',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update favorite status')),
      );
    }
  }

  Future<void> _addToCart() async {
    if (_productDetail == null) return;

    final data = _productDetail!.data;
    if (data.variants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No variants available for this product')),
      );
      return;
    }

    final variant = data.variants[_selectedVariantIndex];

    if (!GuestChecker.check(
      action: PendingAction(
        type: PendingActionType.cart,
        productId: data.id,
        variantId: variant.id,
        quantity: _quantity,
      ),
    )) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await ApiService.addProductToCart(
        productId: data.id,
        variantId: variant.id,
        quantity: _quantity,
        isSavedForLater: 0,
      );

      setState(() {
        _isLoading = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            content: Text('${data.productName} added to cart'),
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
          const SnackBar(content: Text('Failed to add product to cart')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        child: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    if (_productDetail == null) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        child: Scaffold(
          appBar: AppBar(title: const Text('Product Details')),
          body: const Center(child: Text('Failed to load product details')),
        ),
      );
    }

    final data = _productDetail!.data;
    final variant = data.variants.isNotEmpty
        ? data.variants[_selectedVariantIndex]
        : null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6F7),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(data.productName),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image Section
                    _buildImageSection(data),

                    const SizedBox(height: 16),

                    // Product Info Card
                    _buildProductInfoCard(data, variant),

                    const SizedBox(height: 12),

                    // Pack Sizes Section
                    if (data.variants.length > 1) _buildPackSizesSection(data),

                    const SizedBox(height: 12),

                    // View Product Details / About Section
                    _buildAboutSection(data),

                    const SizedBox(height: 12),
                     // Ratings & Reviews
                    _buildRatingsSection(data),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Add to Cart Bottom Bar
            _buildBottomBar(),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Container(
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
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF4D555C),
                    fontWeight: FontWeight.w600,
                    fontFamily: 'ITC Avant Garde Gothic Pro',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              /* GestureDetector(
                onTap: () {},
                child: Image.asset(
                  'assets/images/search.png',
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                ),
              ),*/
              const SizedBox(width: 20),
              GestureDetector(
                onTap: _toggleFavorite,
                child: Image.asset(
                  _isFavorite
                      ? 'assets/images/favorite.png'
                      : 'assets/images/heart.png',
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(pd.Data data) {
    final List<String> imageUrls = [];
    if (data.images.isNotEmpty) {
      imageUrls.addAll(data.images.map((img) => img.productImage));
    } else {
      imageUrls.add(data.productImage);
    }

    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          SizedBox(
            height: 300,
            child: PageView.builder(
              itemCount: imageUrls.length,
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenImageViewer(
                          imageUrls: imageUrls,
                          initialIndex: index,
                        ),
                      ),
                    );
                  },
                  child: CachedNetworkImage(
                    imageUrl: 'https://spicekart1.mockupz.in/storage/products/${imageUrls[index]}',
                    height: 300,
                    fit: BoxFit.contain,
                    memCacheWidth: 1000, // Higher resolution for detail view
                    fadeInDuration: const Duration(milliseconds: 150),
                    placeholder: (context, url) => Container(
                      color: Colors.grey.shade50,
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.image, size: 100),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          // Quantity Selector and Pagination Dot Placeholder
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.instance.secondaryColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.remove,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () {
                          if (_quantity > 1) {
                            setState(() => _quantity--);
                          }
                        },
                      ),
                      Text(
                        '$_quantity',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() => _quantity++);
                        },
                      ),
                    ],
                  ),
                ),
                Row(
                  children: List.generate(
                    imageUrls.length,
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(left: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == _currentImageIndex
                            ? AppTheme.instance.secondaryColor
                            : const Color(0xFFC8D3D9),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfoCard(pd.Data data, pd.Variant? variant) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
              Text(
                data.brandName,
                style: TextStyle(
                  color: AppTheme.instance.secondaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppTheme.instance.secondaryColor,
                size: 18,
              ),
              const Spacer(),
              Row(
                children: [
                  Image.asset(
                    'assets/images/star.png',
                    width: 17,
                    height: 17,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(width: 4),
                  Text(
                    data.averageRating.toString(),
                    style: TextStyle(
                      fontFamily: 'ITC Avant Garde Gothic Pro',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Color(0xFF29551B),
                    ),
                  ),
                  Text(
                    ' | ${data.totalRatings.toString()}',
                    style: TextStyle(
                      fontFamily: 'ITC Avant Garde Gothic Pro',
                      color: Color(0xFF9AA097),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "${data.productName}- ${variant!.varientSize}",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374338),
            ),
          ),
          /* const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFD2E9D8)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.bolt, color: Color(0xFF4EAEF7), size: 16),
                SizedBox(width: 4),
                Text(
                  '1 day',
                  style: TextStyle(
                    color: Color(0xFF4D555C),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),*/
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                variant != null ? '\$${variant.productPrice}' : '\$0.0',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF171717),
                ),
              ),
              /* const SizedBox(width: 12),
              const Text(
                '\$0.75',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7A8D7C),
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.lineThrough,
                ),
              ),*/

              /* const SizedBox(width: 12),
             Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFBC1759),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '50% Off',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),*/
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPackSizesSection(pd.Data data) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF374338),
                    fontFamily: 'ITC Avant Garde Gothic Pro',
                  ),
                  children: [
                    const TextSpan(text: 'Pack Sizes: '),
                    TextSpan(
                      text: data.variants.isNotEmpty
                          ? data.variants[_selectedVariantIndex].varientSize
                          : '',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF4D555C)),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: data.variants.asMap().entries.map((entry) {
                int idx = entry.key;
                pd.Variant v = entry.value;
                bool isSelected = _selectedVariantIndex == idx;

                return GestureDetector(
                  onTap: () => setState(() => _selectedVariantIndex = idx),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 120,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.instance.backgroundColor
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.instance.secondaryColor
                            : const Color(0xFFCCE6FA),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          color: Colors.white,
                          child: Text(
                            v.varientSize,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF374338),
                            ),
                          ),
                        ),

                        const SizedBox(height: 4),
                        Text(
                          '\$${v.productPrice}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF374338),
                          ),
                        ),
                        const SizedBox(height: 2),
                        /*Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                             Text(
                              '\$0.75',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFFC8D3D9),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                             SizedBox(width: 4),
                             Text(
                              '50% Off',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFFE31E24),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),*/
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(pd.Data data) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            title: const Center(
              child: Text(
                'View Product Details',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'ITC Avant Garde Gothic Pro',
                  color: Color(0xFF4D555C),
                ),
              ),
            ),
            onTap: () {},
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'About The Product',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'ITC Avant Garde Gothic Pro',
                        color: Color(0xFF4D555C),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isAboutExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: const Color(0xFF4D555C),
                      ),
                      onPressed: () =>
                          setState(() => _isAboutExpanded = !_isAboutExpanded),
                    ),
                  ],
                ),
                if (_isAboutExpanded) ...[
                  const SizedBox(height: 8),
                  Text(
                    data.productDescription,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'ITC Avant Garde Gothic Pro',
                      color: Color(0xFF4D555C),

                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingsSection(pd.Data data) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductReviewsScreen(
              ratings: data.ratings,
              productName: data.productName,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ratings & Reviews',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF374338),
                    fontWeight: FontWeight.w700,
                    fontFamily: 'ITC Avant Garde Gothic Pro',
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.chevron_right,
                    color: Color(0xFF4D555C),
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Verified Purchases Only',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF4D555C),
                fontWeight: FontWeight.w500,
                fontFamily: 'ITC Avant Garde Gothic Pro',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  data.averageRating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF374338),
                    fontWeight: FontWeight.w700,
                    fontFamily: 'ITC Avant Garde Gothic Pro',
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  children: List.generate(
                    5,
                    (index) {
                      double ratingValue = data.averageRating.toDouble();
                      IconData icon;
                      if (ratingValue >= index + 1) {
                        icon = Icons.star;
                      } else if (ratingValue > index) {
                        icon = Icons.star_half;
                      } else {
                        icon = Icons.star_border;
                      }
                      return Icon(
                        icon,
                        color: const Color(0xFF3EA334),
                        size: 20,
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '(${data.totalRatings} Ratings And ${data.ratings.length} Reviews)',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF4D555C),
                fontWeight: FontWeight.w500,
                fontFamily: 'ITC Avant Garde Gothic Pro',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _addToCart,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.instance.secondaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'ADD',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'ITC Avant Garde Gothic Pro',
            ),
          ),
        ),
      ),
    );
  }
}
