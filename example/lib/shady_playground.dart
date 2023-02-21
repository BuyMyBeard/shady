import 'package:flutter/material.dart';
import 'package:shady/shady.dart';

class ShadyPlayground extends StatefulWidget {
  const ShadyPlayground({super.key});

  @override
  State<ShadyPlayground> createState() => _ShadyPlaygroundState();
}

class _ShadyPlaygroundState extends State<ShadyPlayground> {
  final List<String> _shaders = [];
  Shady? shady;
  ShaderController? _shader;
  var _zoomOut = 0;

  @override
  initState() {
    super.initState();
    loadShaders();
  }

  Future<void> loadShaders() async {
    shady = Shady([
      // ShaderToy shaders
      ShadyShader(asset: 'assets/shaders/st0.frag', key: 'st0', shaderToy: true),
      ShadyShader(asset: 'assets/shaders/st1.frag', key: 'st1', shaderToy: true),
      ShadyShader(asset: 'assets/shaders/st2.frag', key: 'st2', shaderToy: true),
      ShadyShader(asset: 'assets/shaders/st3.frag', key: 'st3', shaderToy: true),
      ShadyShader(asset: 'assets/shaders/st4.frag', key: 'st4', shaderToy: true),
      ShadyShader(asset: 'assets/shaders/st5.frag', key: 'st5', shaderToy: true),
      ShadyShader(asset: 'assets/shaders/st6.frag', key: 'st6', shaderToy: true),
      ShadyShader(asset: 'assets/shaders/st7.frag', key: 'st7', shaderToy: true),
      ShadyShader(asset: 'assets/shaders/st8.frag', key: 'st8', shaderToy: true),
      ShadyShader(asset: 'assets/shaders/st9.frag', key: 'st9', shaderToy: true),

      // Image shaders
      ShadyShader(
        key: 'img0',
        asset: 'assets/shaders/img0.frag',
        uniforms: [
          ShadyUniformFloat(
            key: 'time',
            transformer: ShadyUniformFloat.secondsPassed,
          ),
          ShadyUniformVec3(
            key: 'resolution',
            transformer: ShadyUniformVec3.resolution,
          ),
        ],
        textures: [
          ShadyTexture(
            key: 'cat',
            asset: 'assets/textures/cat.png',
          ),
        ],
      ),
    ]);

    await shady!.load(context);
    _shaders.addAll(['st2', 'st4', 'st3', 'st5', 'st6', 'st1', 'st7', 'st8', 'st9', 'img0']);
    setState(() => _shader = shady!.get(_shaders[0]));
  }

  void _nextShader() {
    final currentIdx = _shaders.indexOf(_shader!.key);
    final nextIdx = (currentIdx < (_shaders.length - 1)) ? (currentIdx + 1) : 0;
    setState(() => _shader = shady!.get(_shaders[nextIdx]));
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
