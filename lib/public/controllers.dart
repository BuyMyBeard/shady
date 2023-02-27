// part of '../shady.dart';

// /// A controller interface for an internal [ShaderInstance].
// ///
// /// These are typically created by calling the [Shady.get] method, and should not be stored.
// /// This is because they are reference counted by Shady to limit uniform calculations.
// class ShaderController {
//   final ShaderInstance _instance;

//   ShaderController(ShaderInstance instance) : _instance = instance;

//   /// The key of the underlying [ShaderInstance].
//   String get key => _instance.key;

//   /// The painter of the underlying [ShaderInstance].
//   CustomPainter get painter => _instance.painter;

//   /// Used by Shady internally to update the [ShaderInstance].
//   ///
//   /// You should probably not use this directly.
//   void update(Duration ts) {
//     _instance.update(ts);
//   }

//   /// Sets the [asset] to be used by the texture with key [textureKey].
//   void setTexture(String textureKey, String asset) {
//     _instance.setTexture(textureKey, asset);
//   }

//   /// Sets the [transformer] to be used by the uniform with key [uniformKey].
//   void setTransformer<T>(String uniformKey, ShadyValueTransformer<T> transformer) {
//     _instance.setTransformer<T>(uniformKey, transformer);
//   }

//   /// Immediately set the uniform value of the uniform with key [uniformKey].
//   void setValue<T>(String uniformKey, T value) {
//     _instance.setUniform<T>(uniformKey, value);
//   }

//   /// Retrieve the uniform value of the uniform with key [uniformKey].
//   void getValue<T>(String uniformKey) {
//     _instance.getUniform<T>(uniformKey);
//   }
// }