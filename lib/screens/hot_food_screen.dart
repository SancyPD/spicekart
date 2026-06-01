import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/app_theme.dart';
import '../services/api_service.dart';
import '../model/resturant_response.dart';
import 'restaurant_menu_screen.dart';

class HotFoodScreen extends StatefulWidget {
  const HotFoodScreen({super.key});

  @override
  State<HotFoodScreen> createState() => _HotFoodScreenState();
}

class _HotFoodScreenState extends State<HotFoodScreen> {
  int? _selectedRestaurantIndex;
  List<Datum> _restaurants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRestaurants();
  }

  @override
  void dispose() {
    super.dispose();
  }



  Future<void> _fetchRestaurants() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.getRestaurants();

      if (response != null && response.status == 1) {
        setState(() {
          _restaurants = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching restaurants: $e');
      setState(() {
        _isLoading = false;
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
        backgroundColor: Colors.grey.shade100,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    const Text(
                      'Top Indian Restaurants\nIn Houston',
                      style: TextStyle(
                        color: Color(0xFF4D555C),
                        fontSize: 22,
                        fontFamily: 'ITC Avant Garde Gothic Pro',
                        fontWeight: FontWeight.w500,
                        height: 1.30,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _restaurants.isEmpty
                              ? const Center(child: Text('No restaurants found'))
                              : RefreshIndicator(
                                  onRefresh: () => _fetchRestaurants(),
                                  child: ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: _restaurants.length,
                                    itemBuilder: (context, index) {
                                      return _buildRestaurantCard(_restaurants[index], index);
                                    },
                                  ),
                                ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
        );
      },
    );
  }

  Widget _buildRestaurantCard(Datum restaurant, int index) {
    final isSelected = _selectedRestaurantIndex == index;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RestaurantMenuScreen(
              restaurantName: restaurant.name,
              restaurantId: restaurant.id,
            ),
          )
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.instance.backgroundColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CachedNetworkImage(
                imageUrl: 'https://spicekart1.mockupz.in/storage/restaurants/${restaurant.image}',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 200,
                  color: Colors.grey.shade200,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 200,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                color: isSelected ? AppTheme.instance.secondaryColor : Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.name,
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF4D555C),
                        fontSize: 18,
                        fontFamily: 'ITC Avant Garde Gothic Pro',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: isSelected ? Colors.white : const Color(0xFF4D555C),
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            restaurant.address,
                            style: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFF4D555C),
                              fontSize: 14,
                              fontFamily: 'ITC Avant Garde Gothic Pro',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
