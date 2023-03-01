part of '../shady.dart';

/// A widget that continuously draws a Shady shader.
///
/// The [shader] argument is typically a [ShaderController] retrieved by calling [Shady.get].
class ShadyCanvas extends StatefulWidget {
  final Shady _shady;

  const ShadyCanvas(
    shady, {
    Key? key,
  })  : _shady = shady,
        super(key: key);

  @override
  State<ShadyCanvas> createState() => _ShadyCanvasState();
}

class _ShadyCanvasState extends State<ShadyCanvas> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    widget._shady.setRefs(1);
    widget._shady.update();
  }

  @override
  void dispose() {
    widget._shady.setRefs(-1);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Animation.fromValueListenable(widget._shady._notifier),
      child: CustomPaint(
        willChange: true,
        painter: widget._shady.painter,
      ),
      builder: (context, child) {
        return child!;
      },
    );
  }
}

/// An interactive version of [ShadyCanvas]. The [UniformVec2] with key
/// [uniformVec2Key] will be updated with the normalized coordinate of
/// user interactions.
///
/// If the [Shady] instance has been flagged as `shaderToy`, the `iMouse`
/// uniform will be populated instead.
///
/// The optional [onInteraction] is called when an interaction happens,
/// with the same normalized coordinates.
class ShadyInteractive extends StatelessWidget {
  final Shady shady;
  final String? uniformVec2Key;
  final void Function(Vector2 offset)? onInteraction;

  ShadyInteractive(
    this.shady, {
    Key? key,
    this.uniformVec2Key,
    this.onInteraction,
  }) : super(key: key) {
    if (uniformVec2Key != null) {
      shady.getUniform<Vector2>(uniformVec2Key!);
    }
  }

  void _handleInteraction(
    BoxConstraints constraints,
    Offset position,
  ) {
    Vector2 vec2 = Vector2(
      position.dx / constraints.maxWidth,
      position.dy / constraints.maxHeight,
    );

    if (shady._shaderToy) {
      shady.setUniform<Vector4>('iMouse', Vector4(vec2.x, vec2.y, 0, 0));
    } else if (uniformVec2Key != null) {
      shady.setUniform<Vector2>(uniformVec2Key!, vec2);
    }

    if (onInteraction != null) {
      onInteraction!(vec2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return GestureDetector(
        onTertiaryTapDown: (event) => _handleInteraction(constraints, event.localPosition),
        onSecondaryTapDown: (event) => _handleInteraction(constraints, event.localPosition),
        onTapDown: (event) => _handleInteraction(constraints, event.localPosition),
        onPanStart: (event) => _handleInteraction(constraints, event.localPosition),
        onPanUpdate: (event) => _handleInteraction(constraints, event.localPosition),
        child: ShadyCanvas(shady),
      );
    });
  }
}

/// A convenience widget wrapping a [ShadyCanvas] in a [Stack].
///
/// The [child] is drawn on top, and can be wrapped in a [Positioned] to control layout.
/// The [shader] is typically a [ShaderController] retrieved by calling [Shady.get].
/// If supplied, the [topShady] is drawn on top.
class ShadyStack extends StatelessWidget {
  final Widget? child;
  final Shady shady;
  final Shady? topShady;

  const ShadyStack({
    Key? key,
    required this.shady,
    this.topShady,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ShadyCanvas(shady),
        ),
        if (child != null) child!,
        if (topShady != null)
          Positioned.fill(
            child: ShadyCanvas(topShady),
          ),
      ],
    );
  }
}
