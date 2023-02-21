import 'package:flutter/rendering.dart';
import 'package:shady/internal/shader.dart';
import 'package:vector_math/vector_math.dart';

class ShadyPainter extends CustomPainter {
  final ShaderInstance _shader;
  final Paint _paint;
  final bool shaderToyed;

  ShadyPainter(ShaderInstance shader, this.shaderToyed)
      : _shader = shader,
        _paint = Paint()..shader = shader.shader;

  @override
  void paint(Canvas canvas, Size size) {
    if (shaderToyed) {
      _shader.setUniform<Vector3>(
        'iResolution',
        Vector3(size.width, size.height, 0),
      );
    }

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, _paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}