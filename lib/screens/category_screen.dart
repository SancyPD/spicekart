import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme.dart';
import '../services/api_service.dart';
import '../model/brands.dart' as brands;
import '../model/products_list_response.dart' as products;
import 'product_detail_screen.dart';

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
  // Map to store selected variant for each product ID
  final Map<int, products.Variant> _selectedVariants = {};

  @override
  void initState() {
    super.initState();
    _fetchBrands();
    _fetchProducts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterProducts();
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

  Future<void> _fetchProducts() async {
    setState(() => _isLoadingProducts = true);
    try {
      final response = await ApiService.listProducts(
        categoryId: widget.categoryId,
        brandId: _selectedBrandId,
      );
      if (response != null && response.status == 1) {
        setState(() {
          _allProducts = response.data;
          _isLoadingProducts = false;
          _filterProducts();
        });
      } else {
        setState(() => _isLoadingProducts = false);
      }
    } catch (e) {
      print('Error fetching products: $e');
      setState(() => _isLoadingProducts = false);
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
    _fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
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
                                ? Image.network(
                                    'https://spicekart.mockupz.in/storage/brands/${brand.brandImage}',
                                    width: 60,
                                    height: 40,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) => Text(
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
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.55,
                        ),
                        itemCount: _filteredProducts.length,
                        itemBuilder: (context, index) {
                          return _buildProductCard(_filteredProducts[index]);
                        },
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
                    color: AppTheme.instance.lightBlueBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: product.productImage.isNotEmpty
                        ? Image.network(
                            'https://spicekart.mockupz.in/storage/products/${product.productImage}',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, color: Colors.grey),
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
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppTheme.instance.secondaryLightBlue, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child:  Icon(
                      Icons.add,
                      color: AppTheme.instance.secondaryLightBlue,
                      size: 16,
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
                Text(
                  weight,
                  style: TextStyle(
                    color: AppTheme.instance.secondaryLightBlue,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                 Icon(
                  Icons.arrow_drop_down,
                  size: 14,
                  color: AppTheme.instance.secondaryLightBlue,
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
                  selectedTileColor: AppTheme.instance.lightBlueBg,
                  onTap: () {
                    setState(() {
                      _selectedVariants[product.id] = variant;
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
}
