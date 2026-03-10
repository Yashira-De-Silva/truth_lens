import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_snackbar.dart';
import 'payment_screen.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  String _currentPlan = 'basic';

  @override
  void initState() {
    super.initState();
    _loadCurrentPlan();
  }

  Future<void> _loadCurrentPlan() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentPlan = prefs.getString('subscription_plan') ?? 'basic';
    });
  }

  Future<void> _upgradeToPremium() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          amount: '\$9.99',
          planName: 'Premium',
          onPaymentSuccess: _handlePaymentSuccess,
        ),
      ),
    );
  }

  Future<void> _handlePaymentSuccess() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('subscription_plan', 'premium');
    setState(() {
      _currentPlan = 'premium';
    });
    if (mounted) {
      AppSnackbar.showSuccess(context, 'Successfully upgraded to Premium!');
      Navigator.pop(context); // Pop PaymentScreen
      Navigator.pop(context); // Pop SubscriptionScreen
    }
  }


  Future<void> _cancelPremium() async {
    final confirmed = await _showCancelDialog();
    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('subscription_plan', 'basic');
      setState(() {
        _currentPlan = 'basic';
      });
      if (mounted) {
        AppSnackbar.showSuccess(context, 'Downgraded to Basic plan');
      }
    }
  }

  Future<bool?> _showCancelDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: const Color(0xFF1A1F3A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Cancel Premium?',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'You will lose access to premium features and be downgraded to the Basic plan.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Keep Premium',
                style: TextStyle(color: AppColors.secondary),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0E27), Color(0xFF1A1F3A), Color(0xFF0A0E27)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildPlanCard(
                        title: 'Basic',
                        price: 'Free',
                        features: [
                          'Access to verified news articles',
                          'Basic fact-checking',
                          'Save up to 10 articles',
                          'Standard news feed',
                          'Community access',
                        ],
                        isCurrentPlan: _currentPlan == 'basic',
                        isPremium: false,
                      ),
                      const SizedBox(height: 20),
                      _buildPlanCard(
                        title: 'Premium',
                        price: '\$9.99/month',
                        features: [
                          'All Basic features',
                          'Advanced AI fact-checking',
                          'Unlimited saved articles',
                          'Ad-free experience',
                          'Priority news updates',
                          'Exclusive analysis reports',
                          'Custom news categories',
                          'Export articles to PDF',
                          'Premium badge on profile',
                        ],
                        isCurrentPlan: _currentPlan == 'premium',
                        isPremium: true,
                      ),
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Subscription Plans',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required List<String> features,
    required bool isCurrentPlan,
    required bool isPremium,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isPremium
                  ? [
                      const Color(0xFF2D3651).withOpacity(0.8),
                      const Color(0xFF1A1F3A).withOpacity(0.6),
                    ]
                  : [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isCurrentPlan
                  ? AppColors.secondary
                  : Colors.white.withOpacity(0.1),
              width: isCurrentPlan ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (isPremium) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFFD700),
                                      Color(0xFFFFA500),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'POPULAR',
                                  style: TextStyle(
                                    color: Color(0xFF1A1F3A),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          price,
                          style: TextStyle(
                            color: isPremium
                                ? const Color(0xFFFFD700)
                                : Colors.white70,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    if (isCurrentPlan)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Current Plan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                ...features.map(
                  (feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: isPremium
                              ? const Color(0xFFFFD700)
                              : AppColors.secondary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            feature,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (!isCurrentPlan && isPremium)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _upgradeToPremium,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: const Color(0xFF1A1F3A),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Upgrade to Premium',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if (isCurrentPlan && isPremium)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _cancelPremium,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel Subscription',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
