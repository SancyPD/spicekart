import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4D555C)),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Terms & Conditions',
          style: TextStyle(
            color: Color(0xFF4D555C),
            fontSize: 18,
            fontFamily: 'ITC Avant Garde Gothic Pro',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Terms & Conditions',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4D555C),
                fontFamily: 'ITC Avant Garde Gothic Pro',
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Effective Date: [Insert Date]',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontFamily: 'ITC Avant Garde Gothic Pro',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome to SpiceKart LLC ("Company," "we," "our," or "us"). These Terms and Conditions ("Terms") govern your access to and use of our website, mobile application, and grocery delivery services (collectively, the "Platform"). By creating an account, subscribing to our services, placing an order, or otherwise using the Platform, you agree to be bound by these Terms.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF4D555C),
                fontFamily: 'ITC Avant Garde Gothic Pro',
                height: 1.5,
              ),
            ),
            _buildSection(
              title: '1. Eligibility',
              content:
                  'You must be at least 18 years old and legally capable of entering into binding agreements to use the Platform.',
            ),
            _buildSection(
              title: '2. Description of Services',
              content:
                  'SpiceKart LLC is an online Indian grocery ordering and delivery platform that enables users to browse, purchase, and receive grocery and household products through scheduled delivery services.\n\nSpiceKart LLC acts solely as a delivery and logistics service provider. Products made available through the Platform may be sourced, purchased, and fulfilled from various independent retail grocery stores, supermarkets, specialty stores, wholesalers, or third-party merchants.\n\nSpiceKart LLC does not manufacture, produce, label, package, or independently guarantee products offered by third-party retail partners. Product availability, pricing, quality, packaging, labeling, ingredients, and inventory are determined by the respective retail stores and suppliers.\n\nBy using the Platform, you acknowledge and agree that SpiceKart LLC facilitates the ordering, shopping, pickup, and delivery process on behalf of customers and participating retail stores.',
            ),
            _buildSection(
              title: '3. Subscription Plans',
              content:
                  'The Platform operates under a subscription-based model. Subscription benefits may include reduced delivery fees, promotional offers, or exclusive pricing.\n\nSubscriptions automatically renew unless canceled before the renewal date. Customers authorize SpiceKart LLC to charge the payment method on file for recurring subscription fees and applicable taxes.',
            ),
            _buildSection(
              title: '4. Orders and Product Availability',
              content:
                  'All orders are subject to product availability and acceptance. SpiceKart LLC reserves the right to refuse or cancel orders due to inventory shortages, pricing errors, suspected fraud, or delivery limitations.',
            ),
            _buildSection(
              title: '5. Pricing and Payments',
              content:
                  'Additional charges may apply, including delivery fees, service fees, taxes, surge pricing, and small-order fees. All payments are processed through third-party payment processors.',
            ),
            _buildSection(
              title: '6. Delivery Terms',
              content:
                  '6.1 Delivery Thermal Tote Bags\n\nTo maintain food quality and temperature control, SpiceKart LLC may provide reusable insulated thermal tote bags with customer orders.\n\nCustomers agree to return all thermal tote bags during their next scheduled delivery. If tote bags are not returned after several reasonable collection attempts, SpiceKart LLC reserves the right to charge a replacement fee of \$4.00 per bag to the customer\'s payment method on file.\n\nCustomers are responsible for maintaining the tote bags in reasonable condition until returned.\n\n6.2 Delivery Windows\n\nDelivery times are estimates only and are not guaranteed. Delays may occur due to weather, traffic, product availability, high demand, or operational interruptions.\n\nCustomers are responsible for providing accurate delivery information and ensuring safe access to the delivery location.',
            ),
            _buildSection(
              title: '7. Refunds and Returns',
              content:
                  'Due to the nature of grocery and perishable products, returns are generally not accepted.\n\nALL SALES OF FROZEN ITEMS ARE FINAL. No refunds, returns, replacements, or credits will be issued for frozen items, including issues caused by customer unavailability, storage conditions after delivery, or delivery delays, except where required by law.\n\nCustomers must report missing, damaged, spoiled, or incorrect items within 24–48 hours of delivery for review.',
            ),
            _buildSection(
              title: '8. Promotions and Credits',
              content:
                  'Promotional offers, referral credits, and discounts may be modified or canceled at any time and may not be exchanged for cash.',
            ),
            _buildSection(
              title: '9. User Conduct',
              content:
                  'Users agree not to misuse the Platform, submit fraudulent information, harass employees or drivers, interfere with operations, or violate applicable laws.',
            ),
            _buildSection(
              title: '10. Disclaimer of Warranties',
              content:
                  'THE PLATFORM AND SERVICES ARE PROVIDED "AS IS" AND "AS AVAILABLE" WITHOUT WARRANTIES OF ANY KIND, EXPRESS OR IMPLIED.\n\nSpiceKart LLC does not guarantee uninterrupted service, product availability, or exact delivery times.',
            ),
            _buildSection(
              title: '11. Limitation of Liability',
              content:
                  'To the maximum extent permitted by law, SpiceKart LLC shall not be liable for indirect, incidental, special, or consequential damages arising from use of the Platform or delivery services.',
            ),
            _buildSection(
              title: '12. Governing Law',
              content:
                  'These Terms shall be governed by the laws of the State of [State], without regard to conflict of law principles.',
            ),
            _buildSection(
              title: '13. Changes to Terms',
              content:
                  'SpiceKart LLC reserves the right to update or modify these Terms at any time. Continued use of the Platform after updates constitutes acceptance of the revised Terms.',
            ),
            _buildSection(
              title: '14. Contact Information',
              content:
                  'SpiceKart LLC\n[Business Address]\n[City, State ZIP]\nEmail: [Support Email]\nPhone: [Phone Number]',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4D555C),
            fontFamily: 'ITC Avant Garde Gothic Pro',
          ),
        ),
        const SizedBox(height: 10),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF4D555C),
            fontFamily: 'ITC Avant Garde Gothic Pro',
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
