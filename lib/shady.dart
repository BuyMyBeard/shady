library shady;

import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart' hide Image;
import 'package:vector_math/vector_math.dart';

part 'public/descriptors.dart';
part 'public/widgets.dart';
part 'internal/default_image.dart';
part 'internal/uniforms.dart';
part 'internal/painter.dart';

/// Transformer function that generates a new value
/// based on the [previousValue] one and a [delta] duration.
typedef UniformTransformer<T> = T Function(T previousValue, Duration delta);

/// A mapping of user-created shaders and ways to manipulate them.
class Shady {
  final String _assetName;
  String get assetName => _assetName;

  final bool _shaderToy;
  final _uniformDescriptions = <UniformValue>[];
  final _samplerDescriptions = <TextureSampler>[];
  final _uniforms = <String, UniformInstance>{};
  final _samplers = <String, TextureInstance>{};
  final _notifier = ValueNotifier(false);

  FragmentShader? _shader;

  Paint _paint = Paint();
  Paint? get paint => _paint;

  CustomPainter? _painter;
  CustomPainter? get painter => _painter;

  var _updateQueued = false;
  var _ready = false;
  var _refs = 0;

  /// Creates a new [Shady] instance.
  ///
  /// [Shady] facilitates interaction with the provided shader
  /// program at [assetName], according to the provided
  /// [samplers] and [uniforms]. [Shady.load] must be called before
  /// the [Shady] instance is used by any widget.
  ///
  /// Once loaded, a [Shady] instance can be reused (though the uniform
  /// values will be the same for all references).
  Shady({
    required String assetName,
    List<TextureSampler>? samplers,
    List<UniformValue>? uniforms,
    bool? shaderToy,
  })  : _assetName = assetName,
        _shaderToy = shaderToy ?? false {
    if (_shaderToy) {
      _uniformDescriptions.addAll([
        UniformVec3(key: 'iResolution', transformer: UniformVec3.resolution),
        UniformFloat(key: 'iTime', transformer: UniformFloat.secondsPassed),
        UniformFloat(key: 'iTimeDelta', transformer: UniformFloat.frameDelta),
        UniformFloat(key: 'iFrameRate', transformer: UniformFloat.frameRate),
        UniformVec4(key: 'iMouse'),
      ]);

      _samplerDescriptions.addAll([
        TextureSampler(key: 'iChannel0'),
        TextureSampler(key: 'iChannel1'),
        TextureSampler(key: 'iChannel2')
      ]);
    }

    _samplerDescriptions.addAll(samplers ?? <TextureSampler>[]);
    _uniformDescriptions.addAll(uniforms ?? <UniformValue>[]);
  }

  /// Parses the previously provided descriptions and
  /// initializes the [FragmentProgram].
  ///
  /// [context] is used for [AssetBundle] look-ups, so
  /// this can be called high up in an app's widget tree.
  Future<void> load(BuildContext context) async {
    if (_ready == true) return;

    final assetBundle = DefaultAssetBundle.of(context);
    final defaultImage = await getDefaultImage();
    final program = await FragmentProgram.fromAsset(_assetName);
    _shader = program.fragmentShader();

    var index = 0;
    for (final uniformDescription in (_uniformDescriptions)) {
      if (uniformDescription is UniformValue<double>) {
        _uniforms[uniformDescription.key] = UniformFloatInstance(uniformDescription);
      } else if (uniformDescription is UniformValue<Vector2>) {
        _uniforms[uniformDescription.key] = UniformVec2Instance(uniformDescription);
      } else if (uniformDescription is UniformValue<Vector3>) {
        _uniforms[uniformDescription.key] = UniformVec3Instance(uniformDescription);
      } else if (uniformDescription is UniformValue<Vector4>) {
        _uniforms[uniformDescription.key] = UniformVec4Instance(uniformDescription);
      } else {
        throw Exception(
          'Unable to load: unsupported uniform type: '
          '${uniformDescription.runtimeType}',
        );
      }

      var instance = _uniforms[uniformDescription.key]!;
      var startIndex = index;
      index = instance.apply(_shader!, index);
      instance.notifier.addListener(() => instance.apply(_shader!, startIndex));
    }

    index = 0;
    for (final textureDescription in _samplerDescriptions) {
      var scopeIndex = index;

      final instance = TextureInstance(assetBundle, textureDescription, defaultImage);
      _samplers[instance.key] = instance;

      index = instance.apply(_shader!, scopeIndex);
      instance.notifier.addListener(() => instance.apply(_shader!, scopeIndex));
    }

    _paint = Paint()..shader = _shader!;
    _painter = ShadyPainter(this);
    _ready = true;
  }

  /// Sets the [asset] image to be used by the texture sampler with key [samplerKey].
  void setTexture(String samplerKey, String assetKey) {
    assert(_ready, 'setTexture was called before Shady instance was .load()\'ed');

    try {
      final sampler = _samplers[samplerKey];
      sampler!.load(assetKey);
    } catch (e) {
      throw Exception('Texture sampler with key "$samplerKey" not found.');
    }
  }

  /// Retrieve the image used by the texture with key [samplerKey].
  Image? getImage(String samplerKey) {
    assert(_ready, 'getImage was called before Shady instance was .load()\'ed');

    try {
      final texture = _samplers[samplerKey];
      return texture!.notifier.value;
    } catch (e) {
      throw Exception('Texture with key "$samplerKey" not found.');
    }
  }

  /// Immediately set the uniform value of the uniform with key [uniformKey].
  void setUniform<T>(String uniformKey, T value) {
    assert(_ready, 'setUniform was called before Shady instance was .load()\'ed');

    try {
      final uniform = _uniforms[uniformKey] as UniformInstance<T>;
      uniform.notifier.value = value;
    } catch (e) {
      throw Exception('Uniform with key "$uniformKey" and type "$T" not found.');
    }
  }

  /// Sets the [transformer] to be used by the uniform with key [uniformKey].
  void setTransformer<T>(String uniformKey, UniformTransformer<T> transformer) {
    assert(_ready, 'setTransformer was called before Shady instance was .load()\'ed');

    try {
      final uniform = _uniforms[uniformKey] as UniformInstance<T>;
      uniform.setTransformer(transformer);
    } catch (e) {
      throw Exception('Uniform with key "$uniformKey" and type "$T" not found.');
    }
  }

  /// Clears the [transformer] for [uniformKey].
  void clearTransformer(String uniformKey) {
    assert(_ready, 'clearTransformer was called before Shady instance was .load()\'ed');

    try {
      final uniform = _uniforms[uniformKey];
      uniform!.setTransformer((x, y) => x);
    } catch (e) {
      throw Exception('Uniform with key "$uniformKey" not found.');
    }
  }

  /// Retrieve the uniform value of the uniform with key [uniformKey].
  T getUniform<T>(String uniformKey) {
    assert(_ready, 'getUniform was called before Shady instance was .load()\'ed');
    try {
      final uniform = _uniforms[uniformKey] as UniformInstance<T>;
      return uniform.notifier.value;
    } catch (e) {
      throw Exception('Uniform with key "$uniformKey" and type "$T" not found.');
    }
  }

  /// Schedules an update of the uniform values and a repaint.
  ///
  /// While the internal [_refs] are over 0, this
  /// starts a loop that will repeat indefinitely once every frame.
  ///
  /// This call is idempotent, and will not trigger extraneous
  /// updates, loop triggers or repaints.
  void update() {
    assert(_ready, 'update was called before Shady instance was .load()\'ed');

    if (_updateQueued) return;
    SchedulerBinding.instance.addPostFrameCallback(_internalUpdate);
    _updateQueued = true;
  }

  /// Adds [refModifier] to the internal ref counter.
  ///
  /// Do not use unless you know what you are doing.
  void setRefs(int refModifier) {
    assert(_ready, 'setRefs was called before Shady instance was .load()\'ed');
    _refs += refModifier;
  }

  void _internalUpdate(Duration ts) {
    assert(_ready, '_internalUpdate was called before Shady instance was .load()\'ed');

    for (var x in _uniforms.values) {
      x.update(ts);
      _notifier.value = !_notifier.value;
    }

    if (_refs > 0) {
      SchedulerBinding.instance.addPostFrameCallback(_internalUpdate);
    } else {
      _updateQueued = false;
    }
  }
}
