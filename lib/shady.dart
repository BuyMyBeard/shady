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

/// A mapping of user-created shaders and ways to manipulate them.
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

  /// Creates a [Shady] instance that facilitates interaction with
  /// shader assets according to the provided [descriptions].
  Shady(this.descriptions);

  /// Parses the previously provided shader descriptions and initializes their [FragmentProgram]s.
  ///
  /// [context] is used for [AssetBundle] look-ups, so this can be called high up in an app's widget tree.
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

  /// Creates a [ShaderController] that allows manipulation of the shader with key [shaderKey].
  ShaderController get(String shaderKey) {
    try {
      final controller = ShaderController(_shaders[shaderKey]!);
      _controllerRefs.add(WeakReference(controller));
      _ensureUpdating();

      return controller;
    } catch (e) {
      throw Exception('Shader with key "$shaderKey" not found.');
    }
  }

  /// Clears this [Shady] instance.
  ///
  /// It is unusable and empty after this.
  void dispose() {
    _controllerRefs.clear();
    _shaders.clear();
    _uniforms.clear();
    _ready = false;
  }

  void _ensureUpdating() {
    if (!_updating) {
      _updating = true;
      _tick = 30;
      SchedulerBinding.instance.addPostFrameCallback(_update);
    }
  }

  void _update(Duration ts) {
    if (!_ready) return;

    _traversed.clear();
    for (var ref in _controllerRefs) {
      if (ref.target != null && !_traversed.contains(ref.target!.key)) {
        ref.target?.update(ts);
        _traversed.add(ref.target!.key);
      }
    }

    if (_tick-- < 0) {
      _controllerRefs.removeWhere((x) => x.target == null);
      _tick = 30;

      if (_controllerRefs.isEmpty) {
        _updating = false;
        return;
      }
    }

    SchedulerBinding.instance.addPostFrameCallback(_update);
  }
}
