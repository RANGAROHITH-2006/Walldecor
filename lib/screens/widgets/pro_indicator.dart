import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walldecor/bloc/auth/auth_bloc.dart';
import 'package:walldecor/screens/navscreens/subscriptionpage.dart';

class ProIndicator extends StatelessWidget {
  const ProIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        bool isProUser = state.user?.hasActiveSubscription ?? false;
        print('🔍 DEBUG Pro Status:');
        print('   User: ${state.user != null ? 'exists' : 'null'}');
        print('   isProUser (raw): ${state.user?.isProUser}');
        print('   expireTime: ${state.user?.expireTime}');
        print('   isSubscriptionExpired: ${state.user?.isSubscriptionExpired}');
        print('   hasActiveSubscription: ${state.user?.hasActiveSubscription}');
        print('   Final isProUser: $isProUser');
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SubscriptionPage()),
            );
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