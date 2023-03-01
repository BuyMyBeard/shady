import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shady/shady.dart';
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
  late final AnimationController ac;
  late final Stream<DateTime> updateStream;
  late final StreamSubscription subscription;
  late DateTime lastInteraction;
  bool flipper = false;

  @override
  void initState() {
    super.initState();
    ac = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    lastInteraction = DateTime.now();
    updateStream = Stream.periodic(const Duration(milliseconds: 500), (_) => DateTime.now());

    ac.addListener(() {
      widget.shady.setUniform('intensity', ac.value);
    });

    subscription = updateStream.listen((dt) {
      if (dt.difference(lastInteraction) > const Duration(seconds: 4) && ac.value > .5) {
        ac.reverse();
      }
    });
  }

  void onInteraction(Vector2 _) {
    ac.forward();
    lastInteraction = DateTime.now();
  }

  @override
  void dispose() {
    ac.dispose();
    subscription.cancel();
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
