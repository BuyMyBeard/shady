part of '../shady.dart';

/// A widget that continuously draws a Shady shader.
///
/// The [shader] argument is typically a [ShaderController] retrieved by calling [Shady.get].
class ShadyCanvas extends StatefulWidget {
  final Shady _shady;

  const ShadyCanvas(shady, {
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

/// A convenience widget wrapping a [ShadyCanvas] in a [Stack].
///
/// The [child] is drawn on top, and can be wrapped in a [Positioned] to control layout.
/// The [shader] is typically a [ShaderController] retrieved by calling [Shady.get].
class ShadyStack extends StatelessWidget {
  final Widget? child;
  final Shady shady;

  const ShadyStack({
    Key? key,
    required this.shady,
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
      ],
    );
  }
}
