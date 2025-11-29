import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walldecor/bloc/auth/auth_bloc.dart';
import 'package:walldecor/screens/navscreens/subscriptionpage.dart';

class ProIndicator extends StatelessWidget {
  const ProIndicator({super.key});

  void _showProUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF40424E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Center(
            child: Text(
              'UPGRADE !',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          content: Text(
            'You currently have an active Pro subscription. Would you like to upgrade or manage your subscription?',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Colors.white54),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10,),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SubscriptionPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEE5776),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Upgrade',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) {
        // Rebuild when user changes or subscription status changes
        final prevHasSubscription = previous.user?.hasActiveSubscription ?? false;
        final currentHasSubscription = current.user?.hasActiveSubscription ?? false;
        final prevIsProUser = previous.user?.isProUser ?? false;
        final currentIsProUser = current.user?.isProUser ?? false;
        
        bool shouldRebuild = prevHasSubscription != currentHasSubscription ||
                            prevIsProUser != currentIsProUser ||
                            previous.status != current.status;
                            
        if (shouldRebuild) {
          print('🔄 ProIndicator rebuilding: hasActiveSubscription $prevHasSubscription -> $currentHasSubscription, isProUser $prevIsProUser -> $currentIsProUser');
        }
        
        return shouldRebuild;
      },
      builder: (context, state) {
        bool isProUser = state.user?.hasActiveSubscription ?? false;
        print('   ProIndicator render - isProUser: $isProUser (Auth Status: ${state.status})');
        return GestureDetector(
          onTap: () {
            if (isProUser) {
              // Show popup for pro users
              _showProUserDialog(context);
            } else {
              // Navigate directly to subscription page for non-pro users
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SubscriptionPage(),
                ),
              );
            }
          },
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isProUser ? Colors.green : const Color(0xFF3A3D47),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isProUser ? Colors.green : const Color(0xFFEE5776),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/navbaricons/crown.png',
                  width: 16,
                  height: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  isProUser ? 'Pro' : 'Go Pro',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
