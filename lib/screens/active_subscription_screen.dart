import 'package:flutter/material.dart';
import '../model/subscription_plans.dart';
import '../utils/app_theme.dart';

class ActiveSubscriptionScreen extends StatelessWidget {
  final Map<String, dynamic> subscriptionData;

  const ActiveSubscriptionScreen({super.key, required this.subscriptionData});

  @override
  Widget build(BuildContext context) {
    final plan = Datum.fromJson(subscriptionData);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'My Subscription',
          style: TextStyle(
            color: Color(0xFF4D555C),
            fontSize: 18,
            fontFamily: 'ITC Avant Garde Gothic Pro',
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4D555C)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildActivePlanCard(plan),
            const SizedBox(height: 20),
            _buildBenefitsCard(plan),
            const SizedBox(height: 30),
            // _buildManageButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildActivePlanCard(Datum plan) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF63A6D1), Color(0xFF4A90BB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF63A6D1).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'ACTIVE PLAN',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            plan.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontFamily: 'ITC Avant Garde Gothic Pro',
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${plan.currency}${plan.price}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text(
                  'Auto-renewing',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsCard(Datum plan) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Benefits',
            style: TextStyle(
              color: Color(0xFF4D555C),
              fontSize: 18,
              fontFamily: 'ITC Avant Garde Gothic Pro',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          _buildBenefitItem(
            Icons.local_shipping_outlined,
            'Free Delivery',
            'On orders above ${plan.currency}${plan.minOrderForFreeDelivery}',
          ),
          const Divider(height: 32),
          _buildBenefitItem(
            Icons.monetization_on_outlined,
            'Cashback',
            '${plan.cashbackPer100}% cashback on every \$100 spent',
          ),
          const Divider(height: 32),
          _buildBenefitItem(
            Icons.stars_outlined,
            'Priority Support',
            '24/7 dedicated customer service',
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF63A6D1), size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF4D555C),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildManageButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF63A6D1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Manage Subscription'),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {},
          child: const Text(
            'Cancel Subscription',
            style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
