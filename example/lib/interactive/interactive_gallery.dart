import 'package:flutter/material.dart';
import 'package:shady/shady.dart';
import 'package:shady_example/gallery/gallery_shaders.dart';

import 'interactive_shaders.dart';

class ShadyInteractives extends StatefulWidget {
  const ShadyInteractives({super.key});

  @override
  State<ShadyInteractives> createState() => _ShadyInteractivesState();
}

class _ShadyInteractivesState extends State<ShadyInteractives> {
  final List<Shady> _shadies = [];
  Shady? _shady;

  @override
  initState() {
    super.initState();
    loadShaders();
  }

  Future<void> loadShaders() async {
    for (var shady in interactiveShaders) {
      await shady.load(context);
      _shadies.add(shady);
    }

    setState(() => _shady = _shadies.first);
  }

  void _nextShader() {
    final currentIdx = _shadies.indexOf(_shady!);
    final nextIdx = (currentIdx + 1) % _shadies.length;
    setState(() => _shady = _shadies[nextIdx]);
  }

  @override
  Widget build(BuildContext context) {
    if (_shady == null) {
      return ColoredBox(
        color: Colors.black,
        child: Center(
          child: SizedBox(
            width: 80,
            height: 10,
            child: LinearProgressIndicator(
              backgroundColor: Colors.grey.shade600,
              color: Colors.purple.shade400,
            ),
          ),
        ),
      );
    }

    return ColoredBox(
      color: Colors.black,
      child: Stack(
        children: [
          Positioned.fill(
            child: ShadyInteractive(
              _shady!,
              key: Key(_shady!.assetName),
              uniformVec2Key: 'inputCoord',
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
