import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageGalleryScreen extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const ImageGalleryScreen({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  @override
  State<ImageGalleryScreen> createState() => _ImageGalleryScreenState();
}

class _ImageGalleryScreenState extends State<ImageGalleryScreen> {
  late PageController _pageController;
  late int _currentIndex;
  final TransformationController _transformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  String _getFullImageUrl(String imagePath) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    return 'https://applist.sgp1.digitaloceanspaces.com/$imagePath';
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Reset zoom when changing pages
    _transformationController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main gallery view
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, index) {
              return Center(
                child: SizedBox(
    height: MediaQuery.of(context).size.height * 0.6, // 60% of screen
    // width: MediaQuery.of(context).size.width * 1,  // 85% width
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 1.0,
        maxScale: 4.0,
        child: CachedNetworkImage(
          imageUrl: _getFullImageUrl(widget.imageUrls[index]),
          fit: BoxFit.contain,
                    errorWidget: (context, url, error) => Container(
                      color: Colors.black,
                      child: const Center(
                        child: Icon(
                          Icons.error_outline,
                          color: Colors.white54,
                          size: 50,
                        ),
                      ),
                    ),
                  ),
                ),
                )));
            },
          ),

          // Top navigation bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Close button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),

                  // Image counter
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentIndex + 1} of ${widget.imageUrls.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  // Placeholder for symmetry
                  const SizedBox(width: 40),
                ],
              ),
            ),
          ),

          // Bottom navigation indicators (optional)
          if (widget.imageUrls.length > 1)
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      widget.imageUrls.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: _currentIndex == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentIndex == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // // Gesture hints (appear briefly on first view)
          // if (widget.imageUrls.length > 1)
          //   Positioned(
          //     left: 20,
          //     top: MediaQuery.of(context).size.height * 0.4,
          //     child: AnimatedOpacity(
          //       opacity: 0.6,
          //       duration: const Duration(milliseconds: 500),
          //       child: Container(
          //         padding: const EdgeInsets.all(8),
          //         decoration: BoxDecoration(
          //           color: Colors.black.withOpacity(0.3),
          //           borderRadius: BorderRadius.circular(8),
          //         ),
          //         child: const Icon(
          //           Icons.arrow_back_ios,
          //           color: Colors.white70,
          //           size: 20,
          //         ),
          //       ),
          //     ),
          //   ),

          // if (widget.imageUrls.length > 1)
          //   Positioned(
          //     right: 20,
          //     top: MediaQuery.of(context).size.height * 0.4,
          //     child: AnimatedOpacity(
          //       opacity: 0.6,
          //       duration: const Duration(milliseconds: 500),
          //       child: Container(
          //         padding: const EdgeInsets.all(8),
          //         decoration: BoxDecoration(
          //           color: Colors.black.withOpacity(0.3),
          //           borderRadius: BorderRadius.circular(8),
          //         ),
          //         child: const Icon(
          //           Icons.arrow_forward_ios,
          //           color: Colors.white70,
          //           size: 20,
          //         ),
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }
}