import 'package:get/get.dart';
import '../services/api_service.dart';
import '../model/category_list.dart';
import '../model/weekly_deals.dart' as weekly;
import '../model/banners_response.dart' as banners;

class HomeController extends GetxController {
  static HomeController get to => Get.find();

  final categories = <Category>[].obs;
  final isLoadingCategories = true.obs;

  final weeklyDeals = <weekly.Datum>[].obs;
  final isLoadingWeeklyDeals = true.obs;

  final bannersList = <banners.Datum>[].obs;
  final isLoadingBanners = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
    if (ApiService.accessToken != null) {
      ApiService.getProfile();
    }
  }

  Future<void> fetchAll() async {
    await Future.wait([
      fetchCategories(),
      fetchWeeklyDeals(),
      fetchBanners(),
    ]);
  }

  Future<void> refreshData() async {
    // We can clear or just fetch. Usually fetching again is cleaner.
    await fetchAll();
  }

  Future<void> fetchCategories() async {
    isLoadingCategories.value = true;
    try {
      final response = await ApiService.listAllCategories();
      if (response != null && response.status == 1) {
        categories.value = response.data;
      }
    } catch (e) {
      print('Error fetching categories: $e');
    } finally {
      isLoadingCategories.value = false;
    }
  }

  Future<void> fetchWeeklyDeals() async {
    isLoadingWeeklyDeals.value = true;
    try {
      final response = await ApiService.getWeekDealsProducts();
      if (response != null && response.status == 1) {
        weeklyDeals.value = response.data;
      }
    } catch (e) {
      print('Error fetching weekly deals: $e');
    } finally {
      isLoadingWeeklyDeals.value = false;
    }
  }

  Future<void> fetchBanners() async {
    isLoadingBanners.value = true;
    try {
      final response = await ApiService.getBanners();
      if (response != null && response.status == 1) {
        bannersList.value = response.data;
      }
    } catch (e) {
      print('Error fetching banners: $e');
    } finally {
      isLoadingBanners.value = false;
    }
  }
}
