import 'package:get/get.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';

class ThemeController extends GetxController {
  static ThemeController get to => Get.find();

  final isLoading = false.obs;
  DateTime? _lastCheckTime;

  @override
  void onInit() {
    super.onInit();
    fetchActiveTheme();
  }

  Future<void> fetchActiveTheme() async {
    _lastCheckTime = DateTime.now();
    isLoading.value = true;
    try {
      final response = await ApiService.getCurrentActiveThemeByPlatform(platform: 'mobile');
      if (response != null && response['status'] == 1) {
        final data = response['data'];
        if (data != null) {
          final String themeName = data['name'] ?? 'Blue';
          final List<dynamic> colorsList = data['theme_colors'] ?? [];
          AppTheme.instance.updateThemeFromColorsList(colorsList, themeName);
        }
      }
    } catch (e) {
      print('Error fetching active theme: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Checks for theme updates on every navigation, with a 5-second throttle
  Future<void> checkThemeOnNavigation() async {
    final now = DateTime.now();
    if (_lastCheckTime == null || 
        now.difference(_lastCheckTime!).inSeconds > 5) {
      print('Checking for theme update on navigation...');
      await fetchActiveTheme();
    }
  }

  void updateTheme(String themeName) {
    AppTheme.instance.setThemeByName(themeName);
  }
}
