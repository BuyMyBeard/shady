import 'package:flutter/material.dart';
import 'package:shady/shady.dart';

class ShadyPlayground extends StatefulWidget {
  const ShadyPlayground({super.key});

  @override
  State<ShadyPlayground> createState() => _ShadyPlaygroundState();
}

class _ShadyPlaygroundState extends State<ShadyPlayground> {
  final List<ShadyShader> _shaders = [];
  ShadyShader? _shader;
  var _zoomOut = 0;

  @override
  initState() {
    super.initState();
    loadShaders();
  }

  Future<void> loadShaders() async {
    final shady = Shady([
      ShaderDetails('assets/shaders/st0.frag')..usesShaderToyUniforms(),
      ShaderDetails('assets/shaders/st1.frag')..usesShaderToyUniforms(),
      ShaderDetails('assets/shaders/st2.frag')..usesShaderToyUniforms(),
      ShaderDetails('assets/shaders/st3.frag')..usesShaderToyUniforms(),
      ShaderDetails('assets/shaders/st4.frag')..usesShaderToyUniforms(),
      ShaderDetails('assets/shaders/st5.frag')..usesShaderToyUniforms(),
      ShaderDetails('assets/shaders/st6.frag')..usesShaderToyUniforms(),
      ShaderDetails('assets/shaders/st7.frag')..usesShaderToyUniforms(),
      ShaderDetails('assets/shaders/st8.frag')..usesShaderToyUniforms(),
      ShaderDetails('assets/shaders/st9.frag')..usesShaderToyUniforms(),
    ]);

    await shady.load();

    _shaders.addAll([
      shady.get('assets/shaders/st0.frag'),
      shady.get('assets/shaders/st1.frag'),
      shady.get('assets/shaders/st2.frag'),
      shady.get('assets/shaders/st3.frag'),
      shady.get('assets/shaders/st4.frag'),
      shady.get('assets/shaders/st5.frag'),
      shady.get('assets/shaders/st6.frag'),
      shady.get('assets/shaders/st7.frag'),
      shady.get('assets/shaders/st8.frag'),
      shady.get('assets/shaders/st9.frag'),
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
    if (_shader == null) {
      return const Center(child: LinearProgressIndicator());
    }

    Widget canvas = ShadyCanvas(shader: _shader!);
    if (_zoomOut == 1) {
      canvas = Center(child: SizedBox(height: 460, width: 340, child: canvas));
    } else if (_zoomOut == 2) {
      canvas = Center(child: SizedBox(height: 160, width: 240, child: canvas));
    }

    return ColoredBox(
      color: Colors.black,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              child: canvas,
              onTap: () => setState(() => _zoomOut = ((_zoomOut < 2) ? _zoomOut + 1 : 0)),
            ),
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
                padding: MaterialStatePropertyAll(EdgeInsets.all(10)),
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
      ),
    );
  }
}
