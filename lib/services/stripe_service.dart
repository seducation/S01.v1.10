import 'package:flutter/material.dart';

class SubscriptionPlan {
  final String id;
  final String name;
  final String price;
  final List<String> features;
  final Color color;
  final bool isPopular;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.features,
    required this.color,
    this.isPopular = false,
  });
}

class StripeService {
  // TODO: Replace with actual Stripe Product/Price IDs later
  static const String basicPlanId = 'price_basic_placeholder';
  static const String plusPlanId = 'price_plus_placeholder';
  static const String proPlanId = 'price_pro_placeholder';
  static const String enterprisePlanId = 'price_enterprise_placeholder';

  static List<SubscriptionPlan> get plans => [
        const SubscriptionPlan(
          id: basicPlanId,
          name: 'Basic',
          price: 'Free',
          features: [
            '1 TV Profile',
            'Standard Reach',
            'Community Support',
          ],
          color: Colors.grey,
        ),
        const SubscriptionPlan(
          id: plusPlanId,
          name: 'Plus',
          price: '\$4.99/mo',
          features: [
            '3 TV Profiles',
            'Ad-free Experience',
            'Priority Feed Injection',
            'Email Support',
          ],
          color: Colors.blue,
          isPopular: true,
        ),
        const SubscriptionPlan(
          id: proPlanId,
          name: 'Pro',
          price: '\$19.99/mo',
          features: [
            '10 TV Profiles',
            'Advanced Analytics',
            'Custom Branding',
            'Priority Support',
          ],
          color: Colors.purple,
        ),
        const SubscriptionPlan(
          id: enterprisePlanId,
          name: 'Enterprise',
          price: 'Contact Us',
          features: [
            'Unlimited TV Profiles',
            'API Access',
            'Dedicated Account Manager',
            'SLA Guarantee',
          ],
          color: Colors.black,
        ),
      ];

  Future<void> purchaseSubscription(BuildContext context, String planId) async {
    // TODO: Implement actual Stripe payment flow
    // 1. Create PaymentIntent on backend
    // 2. Initialize PaymentSheet
    // 3. Present PaymentSheet

    // Mock success for now
    await Future.delayed(const Duration(seconds: 2));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Subscription successful! (Mock)'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
