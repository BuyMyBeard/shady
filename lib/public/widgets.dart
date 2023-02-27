part of '../shady.dart';

/// A widget that continuously draws a Shady shader.
///
/// The [shader] argument is typically a [ShaderController] retrieved by calling [Shady.get].
class ShadyCanvas extends StatefulWidget {
  final Shady _shady;

  const ShadyCanvas({
    required Shady shady,
    Key? key,
  })  : _shady = shady,
        super(key: key);

  @override
  State<ShadyCanvas> createState() => _ShadyCanvasState();
}

class _ShadyCanvasState extends State<ShadyCanvas> with SingleTickerProviderStateMixin {
  late final AnimationController _ac;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController.unbounded(
      vsync: this,
      duration: const Duration(days: 1),
    )..forward();

    widget._shady.setRefs(1);
    widget._shady.update();
  }

  @override
  void dispose() {
    widget._shady.setRefs(-1);
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _ac,
        child: CustomPaint(
          willChange: true,
          painter: widget._shady.painter,
          child: const ColoredBox(color: Color(0x10203000), child: const SizedBox(width: 100, height: 100)),
        ),
        builder: (context, child) {
          return child!;
        });
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
          child: ShadyCanvas(shady: shady),
        ),
        if (child != null) child!,
      ],
    );
  }
}
