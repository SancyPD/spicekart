import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme.dart';
import '../services/api_service.dart';
import '../model/banner_products.dart';
import 'product_detail_screen.dart';

class BannerProductsScreen extends StatefulWidget {
  final int bannerId;
  final String bannerName;

  const BannerProductsScreen({
    super.key,
    required this.bannerId,
    required this.bannerName,
  });

  @override
  State<BannerProductsScreen> createState() => _BannerProductsScreenState();
}

class _BannerProductsScreenState extends State<BannerProductsScreen> {
  late Future<BannerProducts?> _bannerProductsFuture;
  final Map<int, Variant> _selectedVariants = {};

  @override
  void initState() {
    super.initState();
    _bannerProductsFuture = ApiService.getBannerProducts(widget.bannerId);
    // Set system status bar style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top section with Back button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF4D555C)),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.bannerName,
                      style: const TextStyle(
                        color: Color(0xFF323C42),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Product Grid
            Expanded(
              child: FutureBuilder<BannerProducts?>(
                future: _bannerProductsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.data.product.isEmpty) {
                    return const Center(child: Text('No products found for this banner.'));
                  }

                  final products = snapshot.data!.data.product;

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.44,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return _buildProductCard(products[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
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
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Container
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
                      child: product.productImage.isNotEmpty
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
                    child: Icon(
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
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              product.productName,
              style: const TextStyle(
                color: Color(0xFF4D555C),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _showVariantPicker(product),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    weight,
                    style: const TextStyle(
                      color: Color(0xFF6D7A82),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: Color(0xFF6D7A82),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVariantPicker(Product product) {
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
                  onTap: () {
                    setState(() {
                      _selectedVariants[product.id] = variant;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
