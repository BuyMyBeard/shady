import 'dart:ui';
import 'package:flutter/widgets.dart' hide Image;
import 'package:shady/shady.dart';
import 'package:vector_math/vector_math.dart';

class TextureInstance {
  late final String key;
  late final ValueNotifier<Image?> _notifier;
  late final AssetBundle _bundle;
  ValueNotifier<Image?> get notifier => _notifier;

  TextureInstance(AssetBundle bundle, ShadyTexture description, Image defaultImage)
      : _bundle = bundle {
    key = description.key;
    _notifier = ValueNotifier(defaultImage);
    if (description.asset != null) {
      load(description.asset!);
    }
  }

  int apply(FragmentShader shader, int index) {
    if (_notifier.value != null) shader.setImageSampler(index, _notifier.value!);
    return index + 1;
  }

  Future<void> load(String assetKey) async {
    final buffer = await _bundle.loadBuffer(assetKey);
    final codec = await instantiateImageCodecFromBuffer(buffer);
    final frame = await codec.getNextFrame();
    _notifier.value = frame.image;
  }
}

abstract class UniformInstance<T> {
  late final String key;
  late final ValueNotifier<T> notifier;
  ShadyValueTransformer<T> transformer = (a, b) => a;

  Duration? _lastTs;

  UniformInstance(ShadyUniform<T> description)
      : key = description.key,
        notifier = ValueNotifier<T>(description.initialValue),
        transformer = description.transformer;

  void update(Duration ts) {
    T newValue = transformer(notifier.value, ts - (_lastTs ?? ts));
    _lastTs = ts;
    notifier.value = newValue;
  }

  void set(T value) {
    notifier.value = value;
  }

  void setTransformer(ShadyValueTransformer<T> transformer) {
    transformer = transformer;
  }

  int apply(FragmentShader shader, int index);
}

class UniformFloatInstance extends UniformInstance<double> {
  UniformFloatInstance(ShadyUniform<double> description) : super(description);

  @override
  int apply(FragmentShader shader, int index) {
    shader.setFloat(index, notifier.value);
    return index + 1;
  }
}

class UniformVec2Instance extends UniformInstance<Vector2> {
  UniformVec2Instance(ShadyUniform<Vector2> description) : super(description);

  @override
  int apply(FragmentShader shader, int index) {
    shader.setFloat(index, notifier.value.x);
    shader.setFloat(index + 1, notifier.value.y);
    return index + 2;
  }
}

class UniformVec3Instance extends UniformInstance<Vector3> {
  final bool isResolution;
  UniformVec3Instance(ShadyUniform<Vector3> description)
      : isResolution = description.transformer == ShadyUniformVec3.resolution,
        super(description);

  @override
  int apply(FragmentShader shader, int index) {
    shader.setFloat(index, notifier.value.x);
    shader.setFloat(index + 1, notifier.value.y);
    shader.setFloat(index + 2, notifier.value.z);
    return index + 3;
  }
}

class UniformVec4Instance extends UniformInstance<Vector4> {
  UniformVec4Instance(ShadyUniform<Vector4> description) : super(description);

  @override
  int apply(FragmentShader shader, int index) {
    shader.setFloat(index, notifier.value.x);
    shader.setFloat(index + 1, notifier.value.y);
    shader.setFloat(index + 2, notifier.value.z);
    shader.setFloat(index + 3, notifier.value.w);
    return index + 4;
  }
}
