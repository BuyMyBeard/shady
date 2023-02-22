import 'package:flutter/rendering.dart';
import 'package:shady/internal/shader.dart';
import 'package:shady/internal/uniforms.dart';
import 'package:vector_math/vector_math.dart';

/// A painter that draws a Shady shader.
class ShadyPainter extends CustomPainter {
  Size? _lastSize;
  final ShaderInstance _shader;
  final Paint _paint;
  final bool shaderToyed;

  ShadyPainter(ShaderInstance shader, this.shaderToyed)
      : _shader = shader,
        _paint = Paint()..shader = shader.shader;

  @override
  void paint(Canvas canvas, Size size) {
    if (size != _lastSize) {
      _lastSize = size;
      for (final uniform in _shader.uniformKeyMap.values) {
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