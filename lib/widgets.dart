import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:shady/controllers.dart';

/// A widget that continuously draws a Shady shader.
///
/// The [shader] argument is typically a [ShaderController] retrieved by calling [Shady.get].
class ShadyCanvas extends StatefulWidget {
  final ShaderController shader;

  const ShadyCanvas({
    required this.shader,
    Key? key,
  }) : super(key: key);

  @override
  State<ShadyCanvas> createState() => _ShadyCanvasState();
}

class _ShadyCanvasState extends State<ShadyCanvas> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final ValueNotifier _notifier = ValueNotifier(0);

  @override
  void initState() {
    _ticker = createTicker((_) => _notifier.value += 1);
    _ticker.start();
    super.initState();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _notifier,
      builder: (context, child) {
        return CustomPaint(
          key: Key(_notifier.value.toString()),
          willChange: true,
          painter: widget.shader.painter,
        );
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
  final ShaderController shader;

  const ShadyStack({
    required this.shader,
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ShadyCanvas(shader: shader),
        ),
        if (child != null) child!,
      ],
    );
  }
}
