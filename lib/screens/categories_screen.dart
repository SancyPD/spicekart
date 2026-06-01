import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../utils/app_theme.dart';
import '../services/api_service.dart';
import '../model/category_list.dart';
import 'category_screen.dart';
import 'cart_screen.dart';
import '../controllers/main_controller.dart';

import 'package:cached_network_image/cached_network_image.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<Category> _categories = [];
  bool _isLoading = true;
  Worker? _refreshWorker;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _refreshWorker = ever<int>(
      MainController.to.categoriesRefreshTick,
      (_) => _fetchCategories(),
    );
  }

  @override
  void dispose() {
    _refreshWorker?.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.listAllCategories();
      if (response != null && response.status == 1) {
        setState(() {
          _categories = response.data;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error fetching categories: $e');
      setState(() => _isLoading = false);
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
            'All Categories',
            style: TextStyle(
              color: Color(0xFF374338),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  return _buildCategoryCard(_categories[index]);
                },
              ),
      ),
        );
      },
    );
  }

  Widget _buildCategoryCard(Category category) {
    return GestureDetector(
      onTap: () {
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
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.instance.backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Center(
                child: category.categoryImage != null && category.categoryImage.toString().isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: 'https://spicekart1.mockupz.in/storage/categories/${category.categoryImage}',
                        fit: BoxFit.contain,
                        placeholder: (context, url) => Container(
                          color: AppTheme.instance.backgroundColor.withOpacity(0.5),
                        ),
                        errorWidget: (context, url, error) => const Icon(Icons.category, color: Colors.blue),
                      )
                    : const Icon(Icons.category, color: Colors.blue),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category.categoryName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374338),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

}
