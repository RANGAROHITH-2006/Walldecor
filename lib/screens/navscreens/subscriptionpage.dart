import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:walldecor/bloc/auth/auth_bloc.dart';
import 'package:walldecor/repositories/in_app_purchase_repository.dart';
import 'package:walldecor/screens/startscreens/loginscreen.dart';
import 'package:walldecor/screens/startscreens/mainscreen.dart';
import 'package:walldecor/screens/widgets/success_popup.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  int selectedPlan = 0;
  bool isLoading = false;
  final InAppPurchaseService _purchaseService = InAppPurchaseService();
  List<Map<String, dynamic>> subscriptionPlans = [
    {
      'id': InAppPurchaseService.weeklyPlanId,
      'title': '1 Week',
      'price': 'Loading...',
    },
    {
      'id': InAppPurchaseService.yearlyPlanId,
      'title': '1 Year',
      'price': 'Loading...',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializePurchases();
  }

  Future<void> _initializePurchases() async {
    await _purchaseService.initialize();
    if (mounted) {
      _loadPrices();
    }
  }

  void _loadPrices() {
    setState(() {
      for (int i = 0; i < subscriptionPlans.length; i++) {
        final product = _purchaseService.getProductById(
          subscriptionPlans[i]['id'],
        );
        if (product != null) {
          subscriptionPlans[i]['price'] = product.price;
        }
      }
    });
  }

  Future<void> _handleConfirm() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Check user authentication status
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userType = prefs.getString('user_type');

      if (userType == null || userType == 'guest') {
        // User is guest, redirect to login
        setState(() {
          isLoading = false;
        });

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
        return;
      }

      // User is logged in (Google/Apple), proceed with purchase
      final selectedProduct = subscriptionPlans[selectedPlan];
      await _purchaseService.purchaseProduct(
        selectedProduct['id'],
        _onPurchaseResult,
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Something went wrong. Please try again.');
    }
  }

  void _onPurchaseResult(bool success, String? message) {
    if (!mounted) return; // Check if widget is still mounted

    setState(() {
      isLoading = false;
    });

    if (success) {
      // Update the user's subscription status in the auth bloc
      context.read<AuthBloc>().add(
        const UpdateUserSubscription(isProUser: true),
      );

      SuccessPopup.show(
        context,
        title: 'Purchase Successful!',
        message: 'You have successfully subscribed to Premium!',
        onConfirm: () {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const MainScreen()),
            );
          }
        },
      );
    } else {
      _showErrorDialog(message ?? 'Purchase failed');
    }
  }

  void openPrivacyPolicy() async {
    final url = Uri.parse("https://google.com");

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw ('Could not launch privacy policy URL');
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return; // Check if widget is still mounted

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _purchaseService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/Subscription.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MainScreen(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'Subscription',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Column(
                  children: [
                    Container(
                      height: 68,
                      width: 68,
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                        shape: BoxShape.rectangle,
                        color: Color(0xFFEE5776),
                      ),
                      child: Image.asset(
                        'assets/images/premium.png',
                        width: 32,
                        height: 32,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Subscribe to Premium',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Divider(
                      color: Colors.white,
                      thickness: 1,
                      indent: 160,
                      endIndent: 160,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      buildPlanCard(
                        0,
                        subscriptionPlans[0]['title'],
                        subscriptionPlans[0]['price'],
                      ),
                      const SizedBox(height: 16),
                      buildPlanCard(
                        1,
                        subscriptionPlans[1]['title'],
                        subscriptionPlans[1]['price'],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${subscriptionPlans[selectedPlan]['price']} / ${subscriptionPlans[selectedPlan]['title']}, Cancel Anytime',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 25),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEE5776),
                      minimumSize: const Size(118, 42),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child:
                        isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : const Text(
                              'Confirm',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                  ),
                ),

                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          children: [
                            const TextSpan(
                              text:
                                  'Subscription automatically renews until cancelled. By unlocking premium you agree to the ',
                            ),
                            TextSpan(
                              text: 'Terms of Services',
                              style: const TextStyle(
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white,
                                decorationThickness: 1,
                              ),
                              recognizer:
                                  TapGestureRecognizer()
                                    ..onTap = () {
                                      openPrivacyPolicy();
                                    },
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: const TextStyle(
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white,
                                decorationThickness: 1,
                              ),
                              recognizer:
                                  TapGestureRecognizer()
                                    ..onTap = () {
                                      openPrivacyPolicy();
                                    },
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPlanCard(int index, String title, String price) {
    final bool isSelected = selectedPlan == index;
    return GestureDetector(
      onTap: () => setState(() => selectedPlan = index),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? const Color(0xFFED6383).withOpacity(0.8)
                  : const Color.fromARGB(121, 199, 204, 224),
          borderRadius: BorderRadius.circular(25),
          border:
              isSelected
                  ? Border.all(color: const Color(0xFFED6383), width: 2)
                  : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isSelected ? Colors.white : const Color(0xFFED6383),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white,
                    fontSize: 16,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
            Text(
              price,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
