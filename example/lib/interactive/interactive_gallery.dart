import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shady/shady.dart';
import 'package:shady_example/button.dart';
import 'package:vector_math/vector_math.dart' hide Colors;

import 'interactive_shaders.dart';

class InteractiveWrapper extends StatefulWidget {
  final Shady shady;

  const InteractiveWrapper(this.shady, {super.key});

  @override
  State<InteractiveWrapper> createState() => _InteractiveWrapperState();
}

class _InteractiveWrapperState extends State<InteractiveWrapper>
    with SingleTickerProviderStateMixin {
  late DateTime lastInteraction;
  bool flipper = false;

  bool isActivated() {
    return DateTime.now().difference(lastInteraction) < const Duration(seconds: 2);
  }

  @override
  void initState() {
    super.initState();
    lastInteraction = DateTime.now();

    widget.shady.setTransformer<double>('intensity', (previousValue, delta) {
      return isActivated()
          ? min(previousValue + 0.02 + (previousValue * 0.05), 1)
          : max(previousValue - (previousValue * 0.05), 0);
    });
  }

  void onInteraction(Vector2 _) {
    lastInteraction = DateTime.now();
  }

  @override
  void dispose() {
    widget.shady.clearTransformer<double>('intensity');
    widget.shady.setUniform<double>('intensity', 0);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShadyInteractive(
      widget.shady,
      key: Key(widget.shady.assetName),
      uniformVec2Key: 'inputCoord',
      onInteraction: onInteraction,
    );
  }
}

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
            child: InteractiveWrapper(_shady!, key: Key(_shady!.assetName)),
          ),
          Positioned(
            bottom: 40,
            right: 40,
            child: ShadyButton(
              onTap: _nextShader,
              text: 'NEXT',
            ),
          ),
        ],
      ),
    );
  }
}
