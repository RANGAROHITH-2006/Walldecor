import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:walldecor/models/categorydetailes_model.dart';
import 'package:walldecor/screens/static/diolog.dart';

class Resultpage extends StatefulWidget {
  final Urls urls;
  final User user;

  const Resultpage({super.key, required this.urls, required this.user});

  @override
  State<Resultpage> createState() => _ResultpageState();
}

class _ResultpageState extends State<Resultpage> {
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
      builder: (context) => Positioned(
        width: 180,
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: const Offset(-80, -120),
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
                    children: const [
                      Icon(Icons.favorite_border, color: Colors.white),
                      SizedBox(width: 8),
                      Text("Add to Favorites",
                          style: TextStyle(color: Colors.white, fontSize: 15)),
                    ],
                  ),
                  Divider(color: Colors.white54, thickness: 1),
                  Row(
                    children: const [
                      Icon(Icons.share, color: Colors.white),
                      SizedBox(width: 8),
                      Text("Share",
                          style: TextStyle(color: Colors.white, fontSize: 15)),
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

    final image = widget.urls.regular;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF25272F),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
        ),
        backgroundColor: const Color(0xFF25272F),
        title: const Text('Show Result', style: TextStyle(color: Colors.white)),
        actions: const [
          Icon(Icons.favorite_border, color: Colors.white),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Image.network(
                image,
                fit: BoxFit.cover,
                height: 544,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[800],
                  child: const Icon(Icons.image_not_supported, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Unsplash In Collaboration with Danial Miralev',
              style: TextStyle(color: Color(0xFF4A4D57), fontSize: 12),
            ),
            const SizedBox(height: 16),

            // Bottom Action Container
            Container(
              width: 311,
              height: 61,
              decoration: BoxDecoration(
                color: const Color(0xFFEE5776),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () {
                        AddLibraryDialog(
                          context: context,
                          urls: widget.urls,
                          user: widget.user,
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
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(20)),
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
