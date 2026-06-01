import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BrandCategoryController extends GetxController {
  final selectedBrand = 'Britannia'.obs;
  final searchController = TextEditingController();
  final addingProductIds = <int>{}.obs;

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void selectBrand(String brand) {
    selectedBrand.value = brand;
  }
}
