import 'package:shady/shady.dart';
import 'package:vector_math/vector_math.dart';

/// A specification of a shader program.
class ShadyShader {
  /// The asset path of your shader program
  ///
  /// Example: `assets/shader.frag`
  final String asset;

  /// An arbitrary key used to identify this shader.
  final String key;

  /// A list of [ShadyUniform] uniform descriptors.
  ///
  /// See [ShadyUniformFloat], [ShadyUniformVec2], [ShadyUniformVec3] and [ShadyUniformVec4].
  /// All uniforms must be listed in the same order as they appear in the shader program.
  final List<ShadyUniform> uniforms;

  /// A list of [ShadyTexture] texture descriptors, corresponding to the `sampler2D` declarations in the shader program.
  ///
  /// All textures must be listed in the same order as their corresponding `sampler2D` appear in the shader program.
  final List<ShadyTexture> textures;

  /// Flag to indicate that this shader is using the ShaderToy bridge snippets.
  ///
  /// This will cause automatic injection of corresponding uniform- and texture descriptors.
  /// If you are only using the fields defined in the ShaderToy snippet, this is the single flag you'll need.
  final bool shaderToy;

  /// A specification of a shader program.
  ///
  /// Use this to specify the [uniforms] and [textures] of a raw shader program located at [asset] path.
  /// If you have used the ShaderToy bridge snippets, set [shaderToy] to `true` to
  /// automatically inject the corresponding uniforms at parse time.
  ShadyShader({
    required this.asset,
    required this.key,
    List<ShadyUniform>? uniforms,
    List<ShadyTexture>? textures,
    this.shaderToy = false,
  })  : uniforms = uniforms ?? [],
        textures = textures ?? [];
}

/// A specification of a texture slot (`sampler2D`).
///
/// The [key] is an arbitrary key for retrieving or setting this value later.
/// If provided, Shady will load and use the image at [asset].
class ShadyTexture {
  final String key;
  final String? asset;

  ShadyTexture({
    required this.key,
    this.asset,
  });
}

abstract class ShadyUniform<T> {
  final String key;
  final T initialValue;
  final ShadyValueTransformer<T> transformer;

  ShadyUniform({
    required this.key,
    required this.initialValue,
    ShadyValueTransformer<T>? transformer,
  }) : transformer = transformer ?? ((a, b) => a);
}

/// A specification of a `uniform float` in the shader program.
///
/// The [key] is an arbitrary key for retrieving or setting this value later.
/// [transformer] is an optional function that takes the previous value and a delta time to return a new value.
class ShadyUniformFloat extends ShadyUniform<double> {
  ShadyUniformFloat({
    required super.key,
    super.transformer,
    super.initialValue = 0,
  });

  /// A [ShadyValueTransformer] that will inject the total lifetime of the shader program into a float uniform.
  static double secondsPassed(double prev, Duration delta) {
    return prev += (delta.inMilliseconds / 1000);
  }

  /// A [ShadyValueTransformer] that will inject the delta time since last frame into a float uniform.
  static double frameDelta(double prev, Duration delta) {
    return (delta.inMilliseconds / 1000);
  }

  /// A [ShadyValueTransformer] that will inject the current frame rate of the shader.
  static double frameRate(double prev, Duration delta) {
    return (delta.inMilliseconds / 1000) / 1;
  }
}

/// A specification of a `uniform vec2` in the shader program.
///
/// The [key] is an arbitrary key for retrieving or setting this value later.
/// [transformer] is an optional function that takes the previous value and a delta time to return a new value.
class ShadyUniformVec2 extends ShadyUniform<Vector2> {
  ShadyUniformVec2({
    required super.key,
    super.transformer,
    Vector2? initialValue,
  }) : super(initialValue: initialValue ?? Vector2.zero());
}

/// A specification of a `uniform vec3` in the shader program.
///
/// The [key] is an arbitrary key for retrieving or setting this value later.
/// [transformer] is an optional function that takes the previous value and a delta time to return a new value.
class ShadyUniformVec3 extends ShadyUniform<Vector3> {
  ShadyUniformVec3({
    required super.key,
    super.transformer,
    Vector3? initialValue,
  }) : super(initialValue: initialValue ?? Vector3.zero());

  /// A [ShadyValueTransformer] that will inject the resolution (size in pixels) of the area drawing the shader.
  ///
  /// Only X and Y of the vector will be set (width and height). Z is always 0.
  static Vector3 resolution(Vector3 prev, Duration delta) => prev;
}

/// A specification of a `uniform vec4` in the shader program.
///
/// The [key] is an arbitrary key for retrieving or setting this value later.
/// [transformer] is an optional function that takes the previous value and a delta time to return a new value.
class ShadyUniformVec4 extends ShadyUniform<Vector4> {
  ShadyUniformVec4({
    required super.key,
    super.transformer,
    Vector4? initialValue,
  }) : super(initialValue: initialValue ?? Vector4.zero());
}
