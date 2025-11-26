import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:walldecor/bloc/applist/applist_bloc.dart';
import 'package:walldecor/bloc/applist/applist_event.dart';
import 'package:walldecor/bloc/applist/applist_state.dart';
import 'package:walldecor/repositories/applist_repository.dart';
import 'package:walldecor/models/applist_model.dart';
import 'package:walldecor/screens/widgets/image_gallery_screen.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ApplistBloc(ApplistRepository())..add(FetchApplistEvent()),
      child: const _PremiumView(),
    );
  }
}

class _PremiumView extends StatelessWidget {
  const _PremiumView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF25272F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF25272F),
        automaticallyImplyLeading: false,
        title: const Text(
          "Our Premium Apps",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: BlocBuilder<ApplistBloc, ApplistState>(
        builder: (context, state) {
          if (state is ApplistLoading) {
            return const Center(
              child: CupertinoActivityIndicator(
                color: Colors.white,
                radius: 15,
              ),
            );
          }

          if (state is ApplistError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off, color: Colors.white54, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'Failed to load apps',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ApplistBloc>().add(FetchApplistEvent());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                      ),
                      child: const Text(
                        'Retry',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is ApplistLoaded) {
            final allApps = [...state.data.zooq, ...state.data.toolsBrain];

            if (allApps.isEmpty) {
              return const Center(
                child: Text(
                  'No apps available',
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ApplistBloc>().add(FetchApplistEvent());
              },
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                itemCount: allApps.length,
                separatorBuilder:
                    (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final app = allApps[index];
                  return PremiumCard(app: app);
                },
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}

class PremiumCard extends StatelessWidget {
  final ToolsBrain app;

  const PremiumCard({super.key, required this.app});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2F37),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // App Logo
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.lightBlueAccent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    _getFullImageUrl(app.logo.imageUrl),
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.lightBlueAccent,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 1,
                          ),
                        ),
                      );
                    },
                    errorBuilder:
                        (context, error, stackTrace) =>
                            const Icon(Icons.widgets, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.appName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      app.logo.description.isNotEmpty
                          ? app.logo.description
                          : "Premium app with amazing features.",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Rating (only show if rating exists)
              if (app.rating.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        app.rating,
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 20),

          // Screenshots Row
          if (app.screenshot.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    app.screenshot.asMap().entries.map((entry) {
                      final index = entry.key;
                      final screenshot = entry.value;
                      return featureImage(
                        screenshot.imageUrl,
                        onTap:
                            () => _openImageGallery(
                              context,
                              app.screenshot,
                              index,
                            ),
                      );
                    }).toList(),
              ),
            ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _shareApp(context);
                  },
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white30, width: 1),
                    ),
                    child: const Center(
                      child: Text(
                        "Share",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _openAppStore(context);
                  },
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.pinkAccent,
                    ),
                    child: const Center(
                      child: Text(
                        "Install",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getFullImageUrl(String imagePath) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    return 'https://applist.sgp1.digitaloceanspaces.com/$imagePath';
  }

  Widget featureImage(String imageUrl, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        height: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              Image.network(
                _getFullImageUrl(imageUrl),
                fit: BoxFit.fill,
                width: double.infinity,
                height: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey.withValues(alpha: 0.3),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.pinkAccent,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      color: Colors.grey.withOpacity(0.3),
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.white54,
                      ),
                    ),
              ),

              // Subtle overlay to indicate it's tappable
            ],
          ),
        ),
      ),
    );
  }

  void _openImageGallery(
    BuildContext context,
    List<Logo> screenshots,
    int initialIndex,
  ) {
    final imageUrls =
        screenshots.map((screenshot) => screenshot.imageUrl).toList();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => ImageGalleryScreen(
              imageUrls: imageUrls,
              initialIndex: initialIndex,
            ),
      ),
    );
  }

  void _shareApp(BuildContext context) {
    final shareText = 'Check out ${app.appName} - ${app.logo.description}';
    final shareUrl = app.androidUrl.isNotEmpty ? app.androidUrl : app.iosUrl;

    if (shareUrl.isNotEmpty) {
      Share.share('$shareText\n$shareUrl');
    } else {
      Share.share(shareText);
    }
  }

  void _openAppStore(BuildContext context) async {
    // Platform check and open appropriate store
    // For now, we'll use the Android URL as default, then fallback to iOS
    String url = '';

    if (app.androidUrl.isNotEmpty) {
      url = app.androidUrl;
    } else if (app.iosUrl.isNotEmpty) {
      url = app.iosUrl;
    }

    if (url.isNotEmpty) {
      try {
        final Uri uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not launch app store'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No app store link available'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }
}
