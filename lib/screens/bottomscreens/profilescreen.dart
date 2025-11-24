import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walldecor/bloc/auth/auth_bloc.dart';
import 'package:walldecor/bloc/download/download_bloc.dart';
import 'package:walldecor/bloc/download/download_event.dart';
import 'package:walldecor/bloc/download/download_state.dart';
import 'package:walldecor/repositories/download_repository.dart';
import 'package:walldecor/repositories/auth_repository.dart';
import 'package:walldecor/screens/navscreens/settingspage.dart';
import 'package:walldecor/screens/widgets/custom_button.dart';

class ProfileScreen extends StatefulWidget {
  final Function(int)? onTabChange;
  const ProfileScreen({super.key, this.onTabChange});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late DownloadBloc _downloadBloc;
  final AuthRepository _authRepository = AuthRepository();
  int _currentDownloadCount = 0;
  bool _isProUser = false;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _downloadBloc = DownloadBloc(downloadRepository: DownloadRepository());
    _downloadBloc.add(CheckDownloadLimitEvent());
    _loadProfileImage();
  }

  /// Load profile image URL from stored data
  Future<void> _loadProfileImage() async {
    // Only load profile image for Google/Apple users
    final userType = await _authRepository.getCurrentUserType();
    if (userType == 'google' || userType == 'apple') {
      final profileUrl = await _authRepository.getProfileImageUrl();
      if (mounted) {
        setState(() {
          _profileImageUrl = profileUrl;
        });
      }
    }
  }

  @override
  void dispose() {
    _downloadBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DownloadBloc>.value(
      value: _downloadBloc,
      child: BlocListener<DownloadBloc, DownloadState>(
        listener: (context, state) {
          if (state is DownloadLimitChecked) {
            setState(() {
              _currentDownloadCount = state.currentCount;
              _isProUser = state.isProUser;
            });
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFF25272F),
          appBar: AppBar(
            backgroundColor: const Color(0xFF25272F),
            title: const Text('Profile', style: TextStyle(color: Colors.white)),
            actions: [
              IconButton(
                icon: Image.asset(
                  'assets/navbaricons/settings.png',
                  width: 24,
                  height: 24,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Settingspage()),
                  );
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    String userName = 'User';

                    if (state.status == AuthStatus.success &&
                        state.user != null) {
                      // For authenticated users (Google/Apple)
                      if (state.user!.isGoogleLogin ||
                          state.user!.isAppleLogin) {
                        userName =
                            '${state.user!.firstName} ${state.user!.lastName}'
                                .trim();
                        if (userName.isEmpty) {
                          userName =
                              state.user!.email.split(
                                '@',
                              )[0]; // Use email prefix if name is empty
                        }
                      } else {
                        // For guest users, use first and last name from API data
                        String guestName =
                            '${state.user!.firstName} ${state.user!.lastName}'
                                .trim();
                        if (guestName.isNotEmpty) {
                          userName = guestName;
                        } else {
                          userName = 'Guest User';
                        }
                      }
                    }

                    return Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child:
                                _profileImageUrl != null &&
                                        _profileImageUrl!.isNotEmpty
                                    ? Image.network(
                                      _profileImageUrl!,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        // Show default image if network image fails
                                        return Icon(
                                          Icons.person,
                                          size: 60,
                                          color: Colors.white.withOpacity(0.7),
                                        );
                                      },
                                      loadingBuilder: (
                                        context,
                                        child,
                                        loadingProgress,
                                      ) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return Container(
                                          width: 80,
                                          height: 80,
                                          color: Colors.grey[800],
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              value:
                                                  loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                      : null,
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white.withOpacity(
                                                      0.7,
                                                    ),
                                                  ),
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                    : Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                          ),
                        ),
                        SizedBox(height: 10,),
                        Text(
                          userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Only show download limit for non-pro users
                if (!_isProUser)
                  Column(
                    children: [
                      ProfileCustomButton1(
                        image: 'assets/navbaricons/downloadlimit.png',
                        text: 'Download Limit : $_currentDownloadCount/10 Img',
                        color: '0xFF2C2E36',
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ProfileCustomButton(
                  image: 'assets/navbaricons/images.png',
                  text: 'Image Library',
                  color: '0xFF2C2E36',
                  screen: '',
                  onTap: () {
                    if (widget.onTabChange != null) {
                      widget.onTabChange!(
                        1,
                      ); // Navigate to library tab (index 1)
                    }
                  },
                ),
                const SizedBox(height: 12),
                ProfileCustomButton(
                  image: 'assets/navbaricons/downloadimage.png',
                  text: 'Download Image',
                  color: '0xFFEE5776',
                  screen: '/downloadscreen',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
