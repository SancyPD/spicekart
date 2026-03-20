import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme.dart';
import 'product_detail_screen.dart';

class BrandCategoryScreen extends StatefulWidget {
  final String categoryName;
  
  const BrandCategoryScreen({
    super.key,
    this.categoryName = 'Biscuits',
  });

  @override
  State<BrandCategoryScreen> createState() => _BrandCategoryScreenState();
}

class _BrandCategoryScreenState extends State<BrandCategoryScreen> {
  String? _selectedBrand;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedBrand = 'BRITANNIA'; // Default selected brand
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top section with Back button and Search
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Back button
                  Row(
                    children: [
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
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Color(0xff9FA6AD),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search for...',
                        hintStyle: TextStyle(
                          color: const Color(0xFF4D555C),
                          fontSize: 19,
                          fontFamily: 'ITC Avant Garde Gothic Pro',
                          fontWeight: FontWeight.w500,
                        ),
                        suffixIcon: Padding(
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
                ],
              ),
            ),
            // Category Title and Brand Filters
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Title
                  Text(
                    widget.categoryName,
                    style: TextStyle(
                      color: const Color(0xFF364238),
                      fontSize: 14,
                      fontFamily: 'ITC Avant Garde Gothic Pro',
                      fontWeight: FontWeight.w600,

                    ),
                  ),
                  const SizedBox(height: 16),
                  // Brand Logos Row
                  SizedBox(
                    height: 60,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildBrandLogo('BRITANNIA', 'assets/images/britannia.png'),
                        const SizedBox(width: 12),
                        _buildBrandLogo('pepsi', 'assets/images/pepsi.png'),
                        const SizedBox(width: 12),
                        _buildBrandLogo('Eastern', 'assets/images/eastern.png'),
                        const SizedBox(width: 12),
                        _buildBrandLogo('Maggi', 'assets/images/maggi.png'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Product Grid
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.55,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    return _buildProductCard(index);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandLogo(String brandName, String imageAsset) {
    final isSelected = _selectedBrand == brandName;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBrand = brandName;
        });
      },
      child: Container(
        width: 87,
        height: 55,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              color: isSelected
                  ? const Color(0xFF34B355):Color(0x677E6A3D),
            ),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        child: Center(
          child: Image.asset(
            imageAsset,
            width: 50,
            height: 50,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(int index) {
    // Product data - replace with actual product images when available
    final products = [
      {
        'id': 1,
        'image': 'assets/images/g_logo.png', // Placeholder - replace with actual biscuit image
        'name': 'Britannia Marie Gold Biscuits',
        'price': r'$0.75',
        'weight': '250g',
        'hasDiscount': false,
      },
      {
        'id': 2,
        'image': 'assets/images/g_logo.png',
        'name': 'Britannia 50 50 Biscuits',
        'price': r'$0.75',
        'weight': '250g',
        'hasDiscount': true,
      },
      {
        'id': 3,
        'image': 'assets/images/g_logo.png',
        'name': 'Good Day Biscuits',
        'price': r'$0.75',
        'weight': '250g',
        'hasDiscount': true,
      },
      {
        'id': 4,
        'image': 'assets/images/g_logo.png',
        'name': 'Britannia Marie Gold Family Pack',
        'price': r'$0.75',
        'weight': '250g',
        'hasDiscount': true,
      },
      {
        'id': 5,
        'image': 'assets/images/g_logo.png',
        'name': 'Nutri Choice Cracker',
        'price': r'$0.75',
        'weight': '250g',
        'hasDiscount': true,
      },
      {
        'id': 6,
        'image': 'assets/images/g_logo.png',
        'name': 'Vita Marie Gold',
        'price': r'$0.75',
        'weight': '250g',
        'hasDiscount': true,
      },
    ];

    final product = products[index];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              productId: product['id'] as int,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        // Product Image Container with Badge and Add Button
        AspectRatio(
          aspectRatio: 1.0,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Image background container
              Container(
                width: double.infinity,
                height: double.infinity,
                padding: EdgeInsets.all(10.0),
                decoration:  ShapeDecoration(
                  color: AppTheme.instance.lightBlueBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                  ),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/marie_gold.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            // Discount badge
           /* if (product['hasDiscount'] == true)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '20% Off',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),*/
            // Add to cart button (corner - extending outside)
            Positioned(
              bottom: -4,
              right: -4,
              child: Container(
                width: 24,
                height: 24,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 1,
                      color: AppTheme.instance.secondaryLightBlue,
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                child: Icon(
                  Icons.add,
                  color: AppTheme.instance.secondaryLightBlue,
                  size: 16,
                ),
              ),
            ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // Price
        Text(
          product['price'] as String,
          style: TextStyle(
            color: const Color(0xFF171717),
            fontSize: 16,
            fontFamily: 'ITC Avant Garde Gothic Pro',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        // Product Name
        Text(
          product['name'] as String,
          style: const TextStyle(
            color: Color(0xFF4D555C),
            fontSize: 14,
            fontFamily: 'ITC Avant Garde Gothic Pro',
            fontWeight: FontWeight.w500,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        // Quantity with dropdown
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              product['weight'] as String,
              style: TextStyle(
                color: AppTheme.instance.secondaryLightBlue,
                fontSize: 11,
                fontFamily: 'ITC Avant Garde Gothic Pro',
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              size: 12,
              color: AppTheme.instance.secondaryLightBlue,
            ),
          ],
        ),
      ],)
    );
  }
}