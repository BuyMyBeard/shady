import 'package:flutter/material.dart';
import 'package:shady/shady.dart';
import 'package:vector_math/vector_math.dart' hide Colors;

class ShadyPlayground extends StatefulWidget {
  const ShadyPlayground({super.key});

  @override
  State<ShadyPlayground> createState() => _ShadyPlaygroundState();
}

class _ShadyPlaygroundState extends State<ShadyPlayground> {
  final List<ShadyShader> _shaders = [];
  ShadyShader? _shader;

  @override
  initState() {
    super.initState();
    loadShaders();
  }

  Future<void> loadShaders() async {
    final ratio = WidgetsBinding.instance.window.devicePixelRatio;
    final size = WidgetsBinding.instance.window.physicalSize / ratio;
    final vec2Size = Vector2(size.width, size.height);

    final shaderDetails = [
      ShaderDetails('assets/shaders/test1.frag')
        ..addUniform(UniformFloat('time')..setTransform(UniformFloat.secondsPassed))
        ..addUniform(UniformVec2('size', vec2Size)),
      ShaderDetails('assets/shaders/test2.frag')
        ..addUniform(UniformFloat('time')..setTransform(UniformFloat.secondsPassed))
        ..addUniform(UniformVec2('size', vec2Size)),
      ShaderDetails('assets/shaders/test3.frag')
        ..addUniform(UniformFloat('time')..setTransform(UniformFloat.secondsPassed))
        ..addUniform(UniformVec2('size', vec2Size)),
    ];

    final shady = Shady(shaderDetails);

    await shady.load();

    _shaders.addAll([
      shady.get('assets/shaders/test1.frag'),
      shady.get('assets/shaders/test2.frag'),
      shady.get('assets/shaders/test3.frag'),
    ]);

    setState(() => _shader = _shaders[0]);
  }

  void _nextShader() {
    final currentIdx = _shaders.indexOf(_shader!);
    final nextIdx = (currentIdx < (_shaders.length - 1)) ? (currentIdx + 1) : 0;
    setState(() => _shader = _shaders[nextIdx]);
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Builder(
        builder: (context) {
          if (_shader == null) {
            return const LinearProgressIndicator();
          }

          return Stack(
            children: [
              Positioned.fill(
                child: ShadyCanvas(shader: _shader!),
              ),
              Positioned(
                bottom: 40,
                right: 40,
                child: FilledButton.icon(
                    label: const Text(
                      'N E X T',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                    onPressed: _nextShader,
                    style: const ButtonStyle(
                      side: MaterialStatePropertyAll(BorderSide(color: Colors.white54)),
                      padding: MaterialStatePropertyAll(EdgeInsets.all(20)),
                      backgroundColor: MaterialStatePropertyAll(Colors.black45),
                      foregroundColor: MaterialStatePropertyAll(Colors.black45),
                    ),
                    icon: const Icon(
                      Icons.arrow_right_alt_sharp,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
