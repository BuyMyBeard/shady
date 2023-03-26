import 'package:flutter/material.dart';
import 'package:shady/shady.dart';
import 'package:shady_example/gallery/gallery_shaders.dart';

import '../button.dart';

class ShadyGallery extends StatefulWidget {
  const ShadyGallery({super.key});

  @override
  State<ShadyGallery> createState() => _ShadyGalleryState();
}

class _ShadyGalleryState extends State<ShadyGallery> {
  final List<Shady> _shadies = [];
  Shady? _shady;
  var _zoomOut = 0;

  @override
  initState() {
    super.initState();

    for (var shady in galleryShaders) {
      _shadies.add(shady);
    }

    _shady = _shadies.first;
  }

  void _nextShader() {
    final currentIdx = _shadies.indexOf(_shady!);
    final nextIdx = (currentIdx + 1) % _shadies.length;
    setState(() => _shady = _shadies[nextIdx]);
  }

  @override
  Widget build(BuildContext context) {
    if (_shady == null) {
      return ColoredBox(
        color: Colors.black,
        child: Center(
          child: SizedBox(
            width: 80,
            height: 10,
            child: LinearProgressIndicator(
              backgroundColor: Colors.grey.shade600,
              color: Colors.purple.shade400,
            ),
          ),
        ),
      );
    }

    Widget canvas = ShadyCanvas(_shady!, key: Key(_shady!.assetName));
    if (_zoomOut == 1) {
      canvas = Center(child: SizedBox(height: 460, width: 340, child: canvas));
    } else if (_zoomOut == 2) {
      canvas = Center(child: SizedBox(height: 160, width: 240, child: canvas));
    }

    return ColoredBox(
      color: Colors.black,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              child: canvas,
              onTap: () => setState(() => _zoomOut = ((_zoomOut < 2) ? _zoomOut + 1 : 0)),
            ),
          ),
          Positioned(
            bottom: 40,
            right: 40,
            child: ShadyButton(
              onTap: _nextShader,
              text: 'NEXT',
            ),
          ),
        ],
      ),
    );
  }
}
