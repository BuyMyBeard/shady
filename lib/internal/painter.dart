part of '../shady.dart';

/// A painter that draws a Shady shader.
@protected
class ShadyPainter extends CustomPainter {
  Size? _lastSize;
  final Shady _shady;
  final Paint _paint;

  ShadyPainter(Shady shady)
      : _shady = shady,
        _paint = shady._paint,
        super(repaint: shady._notifier);

  @override
  void paint(Canvas canvas, Size size) {
    if (size != _lastSize) {
      _lastSize = size;
      for (final uniform in _shady._uniforms.values) {
        if (uniform is UniformVec3Instance && uniform.isResolution) {
          uniform.notifier.value = Vector3(size.width, size.height, 0);
        }
      }
    }

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, _paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
