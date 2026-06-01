import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          'Privacy Policy',
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
              'Privacy Policy',
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
              'SpiceKart LLC ("SpiceKart," "Company," "we," "our," or "us") values your privacy and is committed to protecting your personal information. This Privacy Policy explains how we collect, use, disclose, store, and protect information when you access or use our website, mobile application, and grocery delivery services (collectively, the "Platform").',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF4D555C),
                fontFamily: 'ITC Avant Garde Gothic Pro',
                height: 1.5,
              ),
            ),
            _buildSection(
              title: '1. Information We Collect',
              content:
                  'We may collect personal information including your name, email address, phone number, billing address, delivery address, payment information, subscription information, account credentials, and customer support communications.\n\nWe also collect order history, transaction details, delivery instructions, and grocery preferences associated with your account.\n\nDevice and usage information such as IP address, browser type, device type, operating system, access times, and Platform usage patterns may also be collected automatically.\n\nWith your permission, we may collect location information to facilitate deliveries and improve delivery accuracy.',
            ),
            _buildSection(
              title: '2. How We Use Your Information',
              content:
                  'We use information to process orders, coordinate deliveries, manage subscriptions, process recurring billing, provide customer support, improve Platform functionality, prevent fraud, communicate updates, and comply with legal obligations.',
            ),
            _buildSection(
              title: '3. Third-Party Retail Stores and Service Providers',
              content:
                  'SpiceKart LLC operates solely as a grocery ordering and delivery service provider. Products may be sourced from independent retail stores, supermarkets, wholesalers, specialty stores, and third-party merchants.\n\nTo facilitate shopping and delivery services, we may share limited information with participating retail stores and service providers, including customer names, delivery addresses, order details, and delivery instructions necessary for order fulfillment.\n\nWe may also work with third-party companies that assist with payment processing, cloud storage, analytics, logistics, customer support, marketing, and security services.',
            ),
            _buildSection(
              title: '4. Payment Information',
              content:
                  'Payments are processed by third-party payment processors. SpiceKart LLC does not store complete credit or debit card numbers on its servers.',
            ),
            _buildSection(
              title: '5. Subscription and Recurring Billing',
              content:
                  'By subscribing to our services, you authorize SpiceKart LLC and its payment processors to charge recurring subscription fees, delivery fees, taxes, tote replacement fees, and other authorized charges to your payment method on file.',
            ),
            _buildSection(
              title: '6. Thermal Tote Bag Recovery Charges',
              content:
                  'Reusable insulated thermal tote bags may be provided with customer orders. Customers agree to return tote bags during the next scheduled delivery.\n\nIf tote bags are not returned after several reasonable collection attempts, SpiceKart LLC reserves the right to charge a replacement fee of \$4.00 per bag to the customer\'s payment method on file.',
            ),
            _buildSection(
              title: '7. Cookies and Tracking Technologies',
              content:
                  'We may use cookies, analytics tools, pixels, and similar technologies to remember preferences, authenticate users, improve Platform performance, and deliver promotional content.',
            ),
            _buildSection(
              title: '8. Marketing Communications',
              content:
                  'We may send promotional emails, text messages, or notifications regarding subscriptions, discounts, products, and services. Users may opt out of marketing communications at any time.',
            ),
            _buildSection(
              title: '9. Data Retention',
              content:
                  'We retain personal information as reasonably necessary to provide services, maintain operations, comply with legal obligations, resolve disputes, enforce agreements, and prevent fraud.',
            ),
            _buildSection(
              title: '10. Data Security',
              content:
                  'We implement reasonable technical, administrative, and physical safeguards to protect personal information.\n\nHowever, no method of transmission or storage is completely secure.',
            ),
            _buildSection(
              title: '11. Your Privacy Rights',
              content:
                  'Depending on applicable laws, users may have rights to access, correct, delete, or request portability of their personal information and opt out of certain communications.',
            ),
            _buildSection(
              title: '12. Children\'s Privacy',
              content:
                  'The Platform is not intended for individuals under 18 years of age. We do not knowingly collect personal information from children.',
            ),
            _buildSection(
              title: '13. Third-Party Links and Services',
              content:
                  'The Platform may contain links to third-party websites or services. SpiceKart LLC is not responsible for third-party privacy practices or content.',
            ),
            _buildSection(
              title: '14. Legal Compliance and Disclosure',
              content:
                  'We may disclose information when necessary to comply with laws, respond to legal requests, enforce agreements, protect rights and safety, or prevent fraud and abuse.',
            ),
            _buildSection(
              title: '15. Business Transfers',
              content:
                  'In connection with mergers, acquisitions, financing, or asset sales, customer information may be transferred as part of the business transaction.',
            ),
            _buildSection(
              title: '16. Texas Privacy Notice',
              content:
                  'SpiceKart LLC does not sell personal information for monetary compensation. Limited information may be shared with service providers and retail partners solely for operational purposes.',
            ),
            _buildSection(
              title: '17. Changes to This Privacy Policy',
              content:
                  'SpiceKart LLC reserves the right to modify this Privacy Policy at any time. Updated versions become effective upon posting to the Platform.',
            ),
            _buildSection(
              title: '18. Contact Information',
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
