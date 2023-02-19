part of 'shady.dart';

typedef ShadyValueTransformer<T> = T Function(T previousValue, Duration delta);

class Texture {
  late final String key;
  late final ValueNotifier<Image?> _notifier;
  late final AssetBundle _bundle;
  ValueNotifier<Image?> get notifier => _notifier;

  Texture(BuildContext context, this.key, [String? assetKey]) {
    _bundle = DefaultAssetBundle.of(context);
    _notifier = ValueNotifier(null);
    if (assetKey != null) {
      load(assetKey);
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

class Uniform<T> {
  final String key;
  ShadyValueTransformer<T> _transformer = (a, b) => a;

  late final ValueNotifier<T> _notifier;
  ValueNotifier<T> get notifier => _notifier;

  Duration? _lastTs;

  Uniform(this.key, T value) {
    _notifier = ValueNotifier(value);
  }

  void withTransform(ShadyValueTransformer<T> transformer) {
    _transformer = transformer;
  }

  void update(Duration ts) {
    T newValue = _transformer(notifier.value, ts - (_lastTs ?? ts));
    _lastTs = ts;

    _notifier.value = newValue;
  }

  void set(T value) {
    _notifier.value = value;
  }

  int apply(FragmentShader shader, int index) {
    shader.setFloat(index, 0);
    return index + 1;
  }
}

class UniformFloat extends Uniform<double> {
  UniformFloat(String key, [double value = 0]) : super(key, value);

  @override
  int apply(FragmentShader shader, int index) {
    shader.setFloat(index, notifier.value);
    return index + 1;
  }

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

class UniformVec2 extends Uniform<Vector2> {
  UniformVec2(String key, [Vector2? value]) : super(key, value ?? Vector2.zero());

  @override
  int apply(FragmentShader shader, int index) {
    shader.setFloat(index, notifier.value.x);
    shader.setFloat(index + 1, notifier.value.y);
    return index + 2;
  }
}

class UniformVec3 extends Uniform<Vector3> {
  UniformVec3(String key, [Vector3? value]) : super(key, value ?? Vector3.zero());

  @override
  int apply(FragmentShader shader, int index) {
    shader.setFloat(index, notifier.value.x);
    shader.setFloat(index + 1, notifier.value.y);
    shader.setFloat(index + 2, notifier.value.z);
    return index + 3;
  }
}

class UniformVec4 extends Uniform<Vector4> {
  UniformVec4(String key, [Vector4? value]) : super(key, value ?? Vector4.zero());

  @override
  int apply(FragmentShader shader, int index) {
    shader.setFloat(index, notifier.value.x);
    shader.setFloat(index + 1, notifier.value.y);
    shader.setFloat(index + 2, notifier.value.z);
    shader.setFloat(index + 3, notifier.value.w);
    return index + 4;
  }
}
