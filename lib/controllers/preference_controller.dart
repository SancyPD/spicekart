import 'package:get/get.dart';
import '../services/api_service.dart';

class PreferenceController extends GetxController {
  final selectedRegion = ''.obs;

  @override
  void onInit() {
    super.onInit();
    selectedRegion.value = ApiService.selectedRegion ?? '';
  }

  void updateRegion(String regionTitle) {
    selectedRegion.value = regionTitle;
  }
}
