import 'package:shady/shady.dart';
import 'package:vector_math/vector_math.dart';


class ShadyShader {
  final String asset;
  final String key;
  final List<ShadyUniform> uniforms;
  final List<ShadyTexture> textures;
  final bool shaderToy;

  ShadyShader({
    required this.asset,
    required this.key,
    List<ShadyUniform>? uniforms,
    List<ShadyTexture>? textures,
    this.shaderToy = false,
  }) : uniforms = uniforms ?? [], textures = textures ?? [];
}

class ShadyTexture {
  final String key;
  final String? asset;

  ShadyTexture({
    required this.key,
    this.asset,
  });
}

class ShadyUniform<T> {
  final String key;
  final T initialValue;
  final ShadyValueTransformer<T> transformer;

  ShadyUniform({
    required this.key,
    required this.initialValue,
    ShadyValueTransformer<T>? transformer,
  }) : transformer = transformer ?? ((a,b) => a);
}

class ShadyUniformFloat extends ShadyUniform<double> {
  ShadyUniformFloat({
    required super.key,
    super.transformer,
    super.initialValue = 0,
  });

  static double secondsPassed(double prev, Duration delta) {
    return prev += (delta.inMilliseconds / 1000);
  }

  static double frameDelta(double prev, Duration delta) {
    return (delta.inMilliseconds / 1000);
  }

  static double frameRate(double prev, Duration delta) {
    return (delta.inMilliseconds / 1000) / 1;
  }
}

class ShadyUniformVec2 extends ShadyUniform<Vector2> {
  ShadyUniformVec2({
    required super.key,
    super.transformer,
    Vector2? initialValue,
  }) : super(initialValue: initialValue ?? Vector2.zero());
}

class ShadyUniformVec3 extends ShadyUniform<Vector3> {
  ShadyUniformVec3({
    required super.key,
    super.transformer,
    Vector3? initialValue,
  }) : super(initialValue: initialValue ?? Vector3.zero());
}

class ShadyUniformVec4 extends ShadyUniform<Vector4> {
  ShadyUniformVec4({
    required super.key,
    super.transformer,
    Vector4? initialValue,
  }) : super(initialValue: initialValue ?? Vector4.zero());
}
