library shady;

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart' hide Image;
import 'package:vector_math/vector_math.dart';

part 'widgets.dart';
part 'uniforms.dart';

Image? _miniImage;
final miniImageBytes = Uint8List.fromList([
  137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,1,0,0,0,1,8,4,0,
  0,0,181,28,12,2,0,0,0,11,73,68,65,84,120,218,99,100,248,15,0,1,5,1,1,
  39,24,227,102,0,0,0,0,73,69,78,68,174,66,96,130
]);
Future<void> _initializeMiniImage() async {
    final decoder = await instantiateImageCodec(miniImageBytes);
    final frame = await decoder.getNextFrame();
    _miniImage = frame.image;
}

class ShadyPainter extends CustomPainter {
  final ShadyShader _shader;
  final Paint _paint;

  ShadyPainter(ShadyShader shader)
      : _shader = shader,
        _paint = Paint()..shader = shader.shader;

  @override
  void paint(Canvas canvas, Size size) {
    if (_shader.details.shaderToyed) {
      _shader.setUniform<Vector3>('iResolution', Vector3(size.width, size.height, 0));
    }

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

  final _textures = <Texture>[];
  List<Texture> get textures => [..._textures];

  bool _shaderToyed = false;
  bool get shaderToyed => _shaderToyed;

  ShaderDetails(this.assetKey);

  void usesTexture(Texture texture) {
    _textures.add(texture);
  }

  void usesUniform(Uniform uniform) {
    _uniforms.add(uniform);
  }

  void usesShaderToyUniforms() {
    assert(_uniforms.isEmpty, "Shader toy uniforms must be set before other uniforms.");

    _uniforms.clear();
    usesUniform(UniformVec3('iResolution'));
    usesUniform(UniformFloat('iTime')..withTransform(UniformFloat.secondsPassed));
    usesUniform(UniformFloat('iTimeDelta')..withTransform(UniformFloat.frameDelta));
    usesUniform(UniformFloat('iFrameRate')..withTransform(UniformFloat.frameRate));
    usesUniform(UniformVec4('iMouse'));
    usesTexture(ImageTexture('iChannel0'));
    usesTexture(ImageTexture('iChannel1'));
    usesTexture(ImageTexture('iChannel2'));
    _shaderToyed = true;
  }
}

class ShadyShader {
  final ShaderDetails details;
  final FragmentProgram program;
  late final FragmentShader shader;
  late final Paint paint;
  late final CustomPainter painter;

  final Map<String, Uniform> _uniformKeyMap = {};
  final Map<String, Texture> _textureKeyMap = {};

  ShadyShader(this.details, this.program) {
    shader = program.fragmentShader();

    var index = 0;
    for (final uniform in details.uniforms) {
      _uniformKeyMap[uniform.key] = uniform;

      var startIndex = index;
      index = uniform.apply(shader, index);
      uniform.notifier.addListener(() {
        index = uniform.apply(shader, startIndex);
      });
    }

    index = 0;
    for (final texture in details.textures) {
      _textureKeyMap[texture.key] = texture;

      var startIndex = index;
      texture.notifier.value ??= _miniImage!;

      index = texture.apply(shader, index);
      texture.notifier.addListener(() {
        index = texture.apply(shader, startIndex);
      });
    }

    paint = Paint()..shader = shader;
    painter = ShadyPainter(this);
  }

  void setImage(String textureKey, Image image) {
    try {
      final texture = _textureKeyMap[textureKey];
      texture!.notifier.value = image;
    } catch (e) {
      throw Exception('Texture with key "$textureKey" not found.');
    }
  }

  Image? getImage(String textureKey) {
    try {
      final texture = _textureKeyMap[textureKey];
      return texture!.notifier.value;
    } catch (e) {
      throw Exception('Texture with key "$textureKey" not found.');
    }
  }

  void setUniform<T>(String uniformKey, T value) {
    try {
      final uniform = _uniformKeyMap[uniformKey] as Uniform<T>;
      uniform.notifier.value = value;
    } catch (e) {
      throw Exception('Uniform with key "$uniformKey" and type "$T" not found.');
    }
  }

  T getUniform<T>(String uniformKey) {
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
  Image? miniImage;

  var _ready = false;
  bool get ready => _ready;

  Shady(this.details);

  Future<void> load() async {
    if (_ready == true) {
      return;
    }

    await _initializeMiniImage();

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

  void dispose() {
    _ready = false;
    _shaders.clear();
    _uniforms.clear();
  }

  void _update(Duration ts) {
    if (!_ready) return;

    for (final uniform in _uniforms) {
      uniform.update(ts);
    }

    SchedulerBinding.instance.addPostFrameCallback(_update);
  }
}
