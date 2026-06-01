import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../utils/app_theme.dart';
import '../controllers/delivery_instructions_controller.dart';
import '../model/property_types.dart' as pt;

class DeliveryInstructionsScreen extends StatefulWidget {
  final bool isInitialFlow;
  const DeliveryInstructionsScreen({super.key, this.isInitialFlow = false});

  @override
  State<DeliveryInstructionsScreen> createState() => _DeliveryInstructionsScreenState();
}

class _DeliveryInstructionsScreenState extends State<DeliveryInstructionsScreen> {
  late DeliveryInstructionsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(DeliveryInstructionsController(isInitialFlow: widget.isInitialFlow));
    
    // Use addPostFrameCallback to ensure context is available for ModalRoute
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        if (args.containsKey('isDeliveryCodeGenerated')) {
          controller.isDeliveryCodeGenerated.value =
              args['isDeliveryCodeGenerated'] == true;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFE5E7E9),
        body: SafeArea(
          child: Column(
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      behavior: HitTestBehavior.opaque,
                      child: const Padding(
                        padding: EdgeInsets.only(top: 8, bottom: 8, right: 20),
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
                    const SizedBox(height: 8),
                    // Title
                    const Text(
                      'Delivery Instructions',
                      style: TextStyle(
                        color: Color(0xFF4D555C),
                        fontSize: 16,
                        fontFamily: 'ITC Avant Garde Gothic Pro',
                        fontWeight: FontWeight.w600,
                        height: 1.30,
                        letterSpacing: -0.48,
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      _buildDeliveryOptionsCard(),
                      const SizedBox(height: 12),

                      // Property Type Section
                      const Text(
                        'Property Type',
                        style: TextStyle(
                          color: Color(0xFF4D555C),
                          fontSize: 14,
                          fontFamily: 'ITC Avant Garde Gothic Pro',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Obx(() => controller.isLoading.value && controller.propertyTypes.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: controller.propertyTypes.map((type) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: _buildPropertyTypeButton(controller, type),
                                  );
                                }).toList(),
                              ),
                            )),
                      const SizedBox(height: 24),
                      // Gate or call box Code Section
                     /* const Text(
                        'Gate or call box Code',
                        style: TextStyle(
                          color: Color(0xFF4D555C),
                          fontSize: 14,
                          fontFamily: 'ITC Avant Garde Gothic Pro',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 1.50,
                              color: Color(0x99BCC5CC),
                            ),
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                        child: TextField(
                          controller: controller.gateCodeController,
                          decoration: const InputDecoration(
                            hintText: 'Does the driver need a gate code,call box, etc',
                            hintStyle: TextStyle(
                              color: Color(0xFF555555),
                              fontSize: 15,
                              fontFamily: 'ITC Avant Garde Gothic Pro',
                              fontWeight: FontWeight.w500,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),*/
                      // Dropoff Location Section
                      const Text(
                        'Dropoff Location',
                        style: TextStyle(
                          color: Color(0xFF4D555C),
                          fontSize: 14,
                          fontFamily: 'ITC Avant Garde Gothic Pro',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: _buildDropoffLocationButton(controller, 'Front Door'),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: _buildDropoffLocationButton(controller, 'Garage Door'),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: _buildDropoffLocationButton(controller, 'No Preference'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Delivery Notes Section
                      const Text(
                        'Delivery Notes',
                        style: TextStyle(
                          color: Color(0xFF4D555C),
                          fontSize: 14,
                          fontFamily: 'ITC Avant Garde Gothic Pro',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: controller.deliveryNotesController,
                        maxLines: 4,
                        style: const TextStyle(
                          color: Color(0xFF555555),
                          fontSize: 16,
                          fontFamily: 'ITC Avant Garde Gothic Pro',
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0x9BBCC4CB),
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Disclaimer
                      const Text(
                        "We’ll make every effort to fulfill your delivery preferences. However, availability and operational factors may prevent us from accommodating all requests.",
                        style: TextStyle(
                          color: Color(0xFF4D555C),
                          fontSize: 14,
                          fontFamily: 'ITC Avant Garde Gothic Pro',
                          fontWeight: FontWeight.w500,
                          height: 1.30,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: Obx(() => ElevatedButton(
                          onPressed: controller.isLoading.value ? null : () => controller.saveDeliveryInstructions(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.instance.secondaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  widget.isInitialFlow ? 'PROCEED TO CHECKOUT' : 'SAVE',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontFamily: 'ITC Avant Garde Gothic Pro',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        )),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildDeliveryOptionsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Obx(
            () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildDeliveryOption(
                    title: 'Leave at my door',
                    isSelected: !controller.isDeliveryCodeGenerated.value,
                    onTap: () =>
                    controller.isDeliveryCodeGenerated.value = false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDeliveryOption(
                    title: 'Hand it to me (verification code required)',
                    isSelected: controller.isDeliveryCodeGenerated.value,
                    onTap: () =>
                    controller.isDeliveryCodeGenerated.value = true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              controller.isDeliveryCodeGenerated.value
                  ? 'Provide your 6-digit code to the driver when your order arrives. Please be available to receive your delivery. Once delivered, customers are responsible for all items, including refrigerated and frozen products.'
                  : 'Your order will be left at your door. Make sure you\'re present for this no contact delivery. You are responsible for your items, including chilled food.',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontFamily: 'ITC Avant Garde Gothic Pro',
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryOption({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.instance.secondaryColor : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppTheme.instance.secondaryColor
                : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF4D555C),
            fontSize: 13,
            fontFamily: 'ITC Avant Garde Gothic Pro',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyTypeButton(DeliveryInstructionsController controller, pt.Datum type) {
    return Obx(() {
      final isSelected = controller.selectedPropertyTypeId.value == type.id;
      return GestureDetector(
        onTap: () {
          controller.selectedPropertyTypeId.value = type.id;
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.instance.mutedColor : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppTheme.instance.mutedColor : const Color(0xffBCC5CC),
            ),
          ),
          child: Text(
            type.typeName,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF4D555C),
              fontSize: 14,
              fontFamily: 'ITC Avant Garde Gothic Pro',
              fontWeight: FontWeight.w500,
              height: 1.30,
              letterSpacing: -0.42,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildDropoffLocationButton(DeliveryInstructionsController controller, String option) {
    return Obx(() {
      final isSelected = controller.selectedDropoffLocation.value == option;
      return GestureDetector(
        onTap: () {
          controller.selectedDropoffLocation.value = option;
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.instance.mutedColor : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppTheme.instance.mutedColor : const Color(0xffBCC5CC),
            ),
          ),
          child: Text(
            option,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF4D555C),
              fontSize: 14,
              fontFamily: 'ITC Avant Garde Gothic Pro',
              fontWeight: FontWeight.w500,
              height: 1.30,
              letterSpacing: -0.42,
            ),
          ),
        ),
      );
    });
  }
}

