library shady;

import 'dart:async';
import 'dart:ui';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:vector_math/vector_math.dart';

part 'widgets.dart';
part 'uniforms.dart';

class ShadyPainter extends CustomPainter {
  final Paint _paint;

  ShadyPainter(Shader shader) : _paint = Paint()..shader = shader;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, _paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class ShaderDetails {
  final String assetKey;
  final _uniforms = <Uniform>[];
  List<Uniform> get uniforms => [..._uniforms];

  ShaderDetails(this.assetKey);

  void addUniform(Uniform uniform) {
    _uniforms.add(uniform);
  }
}

class ShadyShader {
  final ShaderDetails details;
  final FragmentProgram program;
  late final FragmentShader shader;
  late final Paint paint;
  late final CustomPainter painter;

  final Map<String, Uniform> _uniformKeyMap = {};

  ShadyShader(this.details, this.program) {
    shader = program.fragmentShader();
    paint = Paint()..shader = shader;
    painter = ShadyPainter(shader);

    var index = 0;
    for (final uniform in details.uniforms) {
      _uniformKeyMap[uniform.key] = uniform;

      var startIndex = index;
      index = uniform.apply(shader, index);
      uniform.notifier.addListener(() {
        index = uniform.apply(shader, startIndex);
      });
    }
  }

  void setValue<T>(String uniformKey, T value) {
    try {
      final uniform = _uniformKeyMap[uniformKey] as Uniform<T>;
      uniform.notifier.value = value;
    } catch (e) {
      throw Exception('Uniform with key "$uniformKey" and type "$T" not found.');
    }
  }

  T getValue<T>(String uniformKey) {
    try {
      final uniform = _uniformKeyMap[uniformKey] as Uniform<T>;
      return uniform.notifier.value;
    } catch (e) {
      throw Exception('Uniform with key "$uniformKey" and type "$T" not found.');
    }
  }
}

class Shady {
  final List<ShaderDetails> details;
  final _shaders = <String, ShadyShader>{};
  final _uniforms = <Uniform>[];

  var _ready = false;
  bool get ready => _ready;

  Shady(this.details);

  Future<void> load() async {
    if (_ready == true) {
      return;
    }

    for (final detail in details) {
      final program = await FragmentProgram.fromAsset(detail.assetKey);
      final shader = ShadyShader(detail, program);
      _uniforms.addAll(detail.uniforms);
      _shaders[detail.assetKey] = shader;
    }

    _ready = true;
    SchedulerBinding.instance.addPostFrameCallback(_update);
  }

  ShadyShader get(String shaderAssetKey) {
    try {
      return _shaders[shaderAssetKey]!;
    } catch (e) {
      throw Exception('Shader with asset key "$shaderAssetKey" not found.');
    }
  }

  void _update(Duration ts) {
    if (!_ready) return;

    for (final uniform in _uniforms) {
      uniform.update(ts);
    }

    SchedulerBinding.instance.addPostFrameCallback(_update);
  }
}
