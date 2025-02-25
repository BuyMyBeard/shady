import 'package:shady/shady.dart';

final galleryShaders = [
  // ShaderToy shaders
  Shady(assetName: 'assets/shaders/st0.frag', shaderToyInputs: const ShaderToyInputs(iResolution: true, iTime: true)),
  Shady(assetName: 'assets/shaders/st1.frag', shaderToyInputs: const ShaderToyInputs(iResolution: true, iTime: true)),
  Shady(assetName: 'assets/shaders/st2.frag'),
  Shady(assetName: 'assets/shaders/st3.frag', shaderToyInputs: const ShaderToyInputs(iResolution: true, iTime: true)),
  Shady(assetName: 'assets/shaders/st4.frag', shaderToyInputs: const ShaderToyInputs(iResolution: true, iTime: true)),
  Shady(assetName: 'assets/shaders/st5.frag', shaderToyInputs: const ShaderToyInputs(iResolution: true, iTime: true)),
  Shady(assetName: 'assets/shaders/st6.frag', shaderToyInputs: const ShaderToyInputs(iResolution: true, iTime: true)),
  Shady(assetName: 'assets/shaders/st7.frag'),
  Shady(assetName: 'assets/shaders/st8.frag', shaderToyInputs: const ShaderToyInputs(iResolution: true, iTime: true)),
  Shady(assetName: 'assets/shaders/st9.frag', shaderToyInputs: const ShaderToyInputs(iResolution: true, iTime: true)),

  // Image shaders
  Shady(
    assetName: 'assets/shaders/img0.frag',
    uniforms: [
      UniformFloat(
        key: 'time',
        transformer: UniformFloat.secondsPassed,
      ),
      UniformVec3(
        key: 'resolution',
        transformer: UniformVec3.resolution,
      ),
    ],
    samplers: [
      TextureSampler(
        key: 'cat',
        asset: 'assets/textures/cat.png',
      ),
    ],
  ),
];