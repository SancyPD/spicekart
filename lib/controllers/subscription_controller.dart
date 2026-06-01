import 'package:get/get.dart';
import '../model/subscription_plans.dart';
import '../services/api_service.dart';

class SubscriptionController extends GetxController {
  final isLoading = true.obs;
  final plans = <Datum>[].obs;
  final selectedPlanCode = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPlans();
  }

  Future<void> fetchPlans() async {
    isLoading.value = true;
    final response = await ApiService.getSubscriptionPlans();
    if (response != null && response.data.isNotEmpty) {
      plans.assignAll(response.data);
      selectedPlanCode.value = response.data.first.code; // Select the first plan by default
    }
    isLoading.value = false;
  }

  void selectPlan(String code) {
    selectedPlanCode.value = code;
  }
}
