import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../utils/app_theme.dart';
import 'subscription_agreement_screen.dart';
import '../controllers/subscription_controller.dart';
import '../model/subscription_plans.dart';

class SubscriptionScreen extends StatelessWidget {
  final bool isFromMyAccount;

  const SubscriptionScreen({super.key, this.isFromMyAccount = false});

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    final SubscriptionController controller = Get.put(SubscriptionController());

    return Scaffold(
      backgroundColor: const Color(0xFFEBEFEC),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.plans.isEmpty) {
            return const Center(child: Text('No subscription plans available'));
          }

          final selectedPlan = controller.plans.firstWhere(
            (p) => p.code == controller.selectedPlanCode.value,
            orElse: () => controller.plans.first,
          );

          return Column(
            children: [
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: Row(
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
                            const Spacer(),
                          ],
                        ),
                      ),
                      // Top section with gradient background
                      Container(
                        padding: const EdgeInsets.only(top: 15),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppTheme.instance.tertiaryColor,
                              AppTheme.instance.mutedColor,
                              AppTheme.instance.primaryColor,
                            ],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  'Select A Subscription Plan',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF000000),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Free Trial Banner
                            _buildFreeTrialBanner(selectedPlan),
                            const SizedBox(height: 100), // Overlap space
                          ],
                        ),
                      ),
                      // White rectangle that overlaps the gradient
                      Transform.translate(
                        offset: const Offset(0, -100), // Overlap by 100px
                        child: Container(
                          margin: const EdgeInsets.only(
                            top: 20,
                            left: 24,
                            right: 24,
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 24),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 24),
                                child: Text(
                                  'Select The Best Option For You',
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF4D555C),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Plan Selection Cards
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: Row(
                                  children: controller.plans.map((plan) {
                                    final isSelected =
                                        controller.selectedPlanCode.value ==
                                        plan.code;
                                    return Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            right: plan == controller.plans.last ? 0 : 12),
                                        child: _buildPlanCard(
                                          plan,
                                          isSelected,
                                          controller,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Membership Details
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${selectedPlan.name} Membership',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF4D555C),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Deal Banner
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xff9DA3A8)),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '\$${selectedPlan.price}/${selectedPlan.currency.toLowerCase()} ',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF323C42),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Text(
                                  selectedPlan.code.toLowerCase() == 'executive'
                                      ? 'Designed for our most active and loyal customers, this tier offers the best value and premium perks.'
                                      : 'Essential plan designed to provide great value and minimum delivery fees.',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF4D555C),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Benefits List Container
                              _buildBenefitsContainer(selectedPlan),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Subscribe Button (Fixed at bottom)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: const BoxDecoration(color: Color(0xFFEBEFEC)),
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (selectedPlan.trialDays > 0) {
                          showFreeTrialCupertinoAlert(context, selectedPlan);
                        } else {
                          Get.to(() => SubscriptionAgreementScreen(isFromMyAccount: isFromMyAccount));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.instance.secondaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'SUBSCRIBE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildFreeTrialBanner(Datum selectedPlan) {
    if (selectedPlan.trialDays == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0x78000000), // 47% opacity of black
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppTheme.instance.tertiaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  'You Get The Access To ${selectedPlan.name} Plan',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF062B0A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                children: [
                  TextSpan(text: '${selectedPlan.trialDays} Days '),
                  const TextSpan(
                    text: 'Free Trial',
                    style: TextStyle(
                      color: Color(0xFFFFD700), // Yellow
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Unlimited FREE Deliveries For Orders Above \$${selectedPlan.minOrderForFreeDelivery}.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Enjoy ${selectedPlan.trialDays} days of ${selectedPlan.name.toLowerCase()} membership absolutely free! Get access to benefits including free deliveries and exclusive rewards. No commitment required — your membership will automatically continue as a ${selectedPlan.name.toLowerCase()} membership after the trial period unless cancelled.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(Datum plan, bool isSelected, SubscriptionController controller) {
    return GestureDetector(
      onTap: () => controller.selectPlan(plan.code),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? AppTheme.instance.mutedColor : const Color(0xFFAEC1CC),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.instance.mutedColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.asset(
              isSelected
                  ? 'assets/images/selected_badge.png'
                  : 'assets/images/unselected_badge.png',
              width: 32,
              height: 32,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 8),
            Text(
              plan.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4D555C),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '\$${plan.price}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4D555C),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Per ${plan.currency.toLowerCase()}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xFF999999),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitsContainer(Datum plan) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE4F3FF),
          border: Border.all(
            color: const Color(0xFFB9CFDF),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Membership benefits include:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
                color: Color(0xFF485058),
              ),
            ),
            const SizedBox(height: 12),
            _buildBenefitItem('Free Deliveries for orders above \$${plan.minOrderForFreeDelivery}'),
            const SizedBox(height: 12),
            _buildBenefitItem('\$${plan.deliveryFeeUnderMin} delivery fee for orders under \$${plan.minOrderForFreeDelivery}'),
            const SizedBox(height: 12),
            _buildBenefitItem('\$${plan.cashbackPer100} Cashback for every \$100 you spend'),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF485058),
            ),
          ),
        ),
      ],
    );
  }

  void showFreeTrialCupertinoAlert(BuildContext context, Datum plan) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          content: Text(
            "You will get ${plan.trialDays} days free trial of ${plan.name} plan.",
            textAlign: TextAlign.center,
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.of(context).pop();
                Get.to(() => SubscriptionAgreementScreen(isFromMyAccount: isFromMyAccount));
              },
              child: const Text("Okay"),
            ),
          ],
        );
      },
    );
  }
}
