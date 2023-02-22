import 'dart:ui';

import 'package:flutter/widgets.dart' hide Image;
import 'package:shady/internal/painter.dart';
import 'package:shady/internal/uniforms.dart';
import 'package:shady/shady.dart';
import 'package:vector_math/vector_math.dart';

@protected
class ShaderInstance {
  final FragmentProgram program;
  late final String key;
  late final FragmentShader shader;
  late final Paint paint;
  late final CustomPainter painter;
  late final bool shaderToyed;

  final Map<String, UniformInstance> uniformKeyMap = {};
  final Map<String, TextureInstance> textureKeyMap = {};

  ShaderInstance(ShadyShader description, this.program, Image defaultImage, AssetBundle assetBundle) {
    key = description.key;
    shader = program.fragmentShader();
    shaderToyed = description.shaderToy;

    if (shaderToyed) {
      description.uniforms.addAll([
        ShadyUniformVec3(key: 'iResolution', transformer: ShadyUniformVec3.resolution),
        ShadyUniformFloat(key: 'iTime', transformer: ShadyUniformFloat.secondsPassed),
        ShadyUniformFloat(key: 'iTimeDelta', transformer: ShadyUniformFloat.frameDelta),
        ShadyUniformFloat(key: 'iFrameRate', transformer: ShadyUniformFloat.frameRate),
        ShadyUniformVec4(key: 'iMouse'),
      ]);

      description.textures.addAll([
        ShadyTexture(key: 'iChannel0'),
        ShadyTexture(key: 'iChannel1'),
        ShadyTexture(key: 'iChannel2')
      ]);
    }

    var index = 0;
    for (final uniformDescription in description.uniforms) {
      if (uniformDescription is ShadyUniform<double>) {
        uniformKeyMap[uniformDescription.key] = UniformFloatInstance(uniformDescription);
      } else if (uniformDescription is ShadyUniform<Vector2>) {
        uniformKeyMap[uniformDescription.key] = UniformVec2Instance(uniformDescription);
      } else if (uniformDescription is ShadyUniform<Vector3>) {
        uniformKeyMap[uniformDescription.key] = UniformVec3Instance(uniformDescription);
      } else if (uniformDescription is ShadyUniform<Vector4>) {
        uniformKeyMap[uniformDescription.key] = UniformVec4Instance(uniformDescription);
      } else {
        throw Exception("Unsupported uniform type");
      }

      var instance = uniformKeyMap[uniformDescription.key]!;
      var startIndex = index;
      index = instance.apply(shader, index);
      instance.notifier.addListener(() => instance.apply(shader, startIndex));
    }

    index = 0;
    for (final textureDescription in description.textures) {
      var scopeIndex = index;

      final instance = TextureInstance(assetBundle, textureDescription, defaultImage);
      textureKeyMap[instance.key] = instance;

      index = instance.apply(shader, scopeIndex);
      instance.notifier.addListener(() => instance.apply(shader, scopeIndex));
    }

    paint = Paint()..shader = shader;
    painter = ShadyPainter(this, shaderToyed);
  }

  void setTexture(String textureKey, String assetKey) {
    try {
      final texture = textureKeyMap[textureKey];
      texture!.load(assetKey);
    } catch (e) {
      throw Exception('Texture with key "$textureKey" not found.');
    }
  }

  Image? getImage(String textureKey) {
    try {
      final texture = textureKeyMap[textureKey];
      return texture!.notifier.value;
    } catch (e) {
      throw Exception('Texture with key "$textureKey" not found.');
    }
  }

  void setUniform<T>(String uniformKey, T value) {
    try {
      final uniform = uniformKeyMap[uniformKey] as UniformInstance<T>;
      uniform.notifier.value = value;
    } catch (e) {
      throw Exception('Uniform with key "$uniformKey" and type "$T" not found.');
    }
  }

  void setTransformer<T>(String uniformKey, ShadyValueTransformer<T> transformer) {
    try {
      final uniform = uniformKeyMap[uniformKey] as UniformInstance<T>;
      uniform.setTransformer(transformer);
    } catch (e) {
      throw Exception('Uniform with key "$uniformKey" and type "$T" not found.');
    }
  }

  void update(Duration dt) {
    for (var uniform in uniformKeyMap.values) {
      uniform.update(dt);
    }
  }

  T getUniform<T>(String uniformKey) {
    try {
      final uniform = uniformKeyMap[uniformKey] as UniformInstance<T>;
      return uniform.notifier.value;
    } catch (e) {
      throw Exception('Uniform with key "$uniformKey" and type "$T" not found.');
    }
  }
}