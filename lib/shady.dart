library shady;

import 'dart:async';
import 'dart:ui';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart' hide Image;
import 'package:shady/controllers.dart';
import 'package:shady/descriptors.dart';
import 'package:shady/internal/default_image.dart';
import 'package:shady/internal/shader.dart';
import 'package:shady/internal/uniforms.dart';

export 'controllers.dart';
export 'descriptors.dart';
export 'widgets.dart';

typedef ShadyValueTransformer<T> = T Function(T previousValue, Duration delta);

class Shady {
  final List<ShadyShader> descriptions;
  final List<WeakReference<ShaderController>> _controllerRefs = [];
  final _shaders = <String, ShaderInstance>{};
  final _uniforms = <UniformInstance>[];
  final _traversed = <String>{};

  var _tick = 0;
  var _ready = false;
  var _updating = false;
  bool get ready => _ready;

  Shady(this.descriptions);

  Future<void> load(BuildContext context) async {
    if (_ready == true) {
      return;
    }

    final assetBundle = DefaultAssetBundle.of(context);
    final defaultImage = await getDefaultImage();

    for (final shaderDescription in descriptions) {
      final program = await FragmentProgram.fromAsset(shaderDescription.asset);
      final shader = ShaderInstance(shaderDescription, program, defaultImage, assetBundle);
      _uniforms.addAll(shader.uniformKeyMap.values);
      _shaders[shaderDescription.key] = shader;
    }

    _ready = true;
  }

  ShaderController get(String shaderAssetKey) {
    try {
      final controller = ShaderController(_shaders[shaderAssetKey]!);
      _controllerRefs.add(WeakReference(controller));
      _ensureUpdating();

      return controller;
    } catch (e) {
      throw Exception('Shader with asset key "$shaderAssetKey" not found.');
    }
  }

  void dispose() {
    _ready = false;
    _controllerRefs.clear();
    _shaders.clear();
    _uniforms.clear();
  }

  void _ensureUpdating() {
    if (!_updating) {
      _tick = 60;
      SchedulerBinding.instance.addPostFrameCallback(_update);
    }
  }

  void _update(Duration ts) {
    if (!_ready) return;

    _updating = true;

    for (var ref in _controllerRefs) {
      if (ref.target != null && _traversed.contains(ref.target!.key)) {
        _traversed.add(ref.target!.key);
        ref.target?.update(ts);
      }
    }

    if (_tick-- < 30) {
      _controllerRefs.removeWhere((x) => x.target == null);
    }

    SchedulerBinding.instance.addPostFrameCallback(_update);
  }
}
