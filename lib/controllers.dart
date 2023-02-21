import 'package:flutter/widgets.dart' hide Image;
import 'package:shady/internal/shader.dart';
import 'package:shady/internal/uniforms.dart';
import 'package:shady/shady.dart';

class ShaderController {
  ShaderInstance _instance;

  ShaderController(ShaderInstance instance) : _instance = instance;

  String get key => _instance.key;
  CustomPainter get painter => _instance.painter;

  void setTexture(String textureKey, String asset) {
    _instance.setTexture(textureKey, asset);
  }

  void setTransformer<T>(String uniformKey, ShadyValueTransformer<T> transformer) {
    _instance.setTransformer<T>(uniformKey, transformer);
  }

  void setValue<T>(String uniformKey, T value) {
    _instance.setUniform<T>(uniformKey, value);
  }

  void getValue<T>(String uniformKey) {
    _instance.getUniform<T>(uniformKey);
  }
}