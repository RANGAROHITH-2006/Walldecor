import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:walldecor/screens/static/diolog.dart';

class Showresultpage extends StatefulWidget {
  final String imagePath;
  const Showresultpage({super.key, required this.imagePath});

  @override
  State<Showresultpage> createState() => _ShowresultpageState();
}

class _ShowresultpageState extends State<Showresultpage> {
  OverlayEntry? _popup;
  final LayerLink _layerLink = LayerLink();

  void _togglePopup() {
    if (_popup != null) {
      _removePopup();
    } else {
      _showPopup();
    }
  }

  void _showPopup() {
    final overlay = Overlay.of(context);
    _popup = OverlayEntry(
      builder:
          (context) => Positioned(
            width: 180,
            child: CompositedTransformFollower(
              link: _layerLink,
              offset: const Offset(-80, -120), // move popup above button
              showWhenUnlinked: false,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF25272F).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.favorite_border, color: Colors.white),
                          SizedBox(width: 8),
                          const Text(
                            "Add to Favorites",
                            style: TextStyle(color: Colors.white,fontSize: 15),
                          ),
                        ],
                      ),
                      Divider(color: Colors.white54, thickness: 1),
                      Row(
                        children: [
                          const Icon(Icons.share, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            "Share",
                            style: TextStyle(color: Colors.white,fontSize: 15),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
    overlay.insert(_popup!);
  }

  void _removePopup() {
    _popup?.remove();
    _popup = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF25272F),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
        ),
        backgroundColor: const Color(0xFF25272F),
        title: Text('Show Result', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.favorite_border, color: Colors.white),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Image.asset(
                widget.imagePath,
                fit: BoxFit.fill,
                height: 544,
                width: double.infinity,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Unsplash In Collaboration with Danial Miralev',
              style: TextStyle(color: Color(0xFF4A4D57), fontSize: 12),
            ),
            SizedBox(height: 16),
            Container(
              width: 311,
              height: 61,
              decoration: BoxDecoration(
                color: Color(0xFFEE5776),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () {
                        showAddFloorDialog(
                          context: context,
                          onCreate: (libraryName) {},
                        );
                      },
                      child: SvgPicture.asset(
                        'assets/svg/library.svg',
                        width: 28,
                        height: 28,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: const Color(0xFF25272F).withOpacity(0.8),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) => const SaveLibrarySheet(),
            );
                      },
                      child: SvgPicture.asset(
                        'assets/svg/download.svg',
                        width: 36,
                        height: 36,
                      ),
                    ),
                    CompositedTransformTarget(
                      link: _layerLink,
                      child: GestureDetector(
                        onTap: _togglePopup,
                        child: SvgPicture.asset(
                          'assets/svg/share.svg',
                          width: 28,
                          height: 28,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
