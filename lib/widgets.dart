part of 'shady.dart';

class ShadyCanvas extends StatefulWidget {
  final Widget? _child;
  final ShadyShader _shader;

  const ShadyCanvas({
    Key? key,
    Widget? child,
    required ShadyShader shader,
  })  : _shader = shader,
        _child = child,
        super(key: key);

  @override
  State<ShadyCanvas> createState() => _ShadyCanvasState();
}

class _ShadyCanvasState extends State<ShadyCanvas> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final ValueNotifier _notifier = ValueNotifier(false);

  @override
  void initState() {
    _ticker = createTicker((_) => _notifier.value = !_notifier.value);
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
      child: widget._child,
      builder: (context, child) {
        return CustomPaint(
          key: Key(_notifier.value.toString()),
          willChange: true,
          painter: widget._shader.painter,
          child: child,
        );
      },
    );
  }
}
