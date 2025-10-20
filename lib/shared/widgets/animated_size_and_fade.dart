import 'package:flutter/material.dart';

/// A widget that combines size and fade animations
class AnimatedSizeAndFade extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration? reverseDuration;
  final Curve curve;
  final Curve? reverseCurve;
  final Alignment alignment;
  final TickerProvider vsync;

  const AnimatedSizeAndFade({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.reverseDuration,
    this.curve = Curves.easeOut,
    this.reverseCurve,
    this.alignment = Alignment.center,
    required this.vsync,
  });

  @override
  State<AnimatedSizeAndFade> createState() => _AnimatedSizeAndFadeState();
}

class _AnimatedSizeAndFadeState extends State<AnimatedSizeAndFade>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  late Widget _oldChild;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: widget.vsync,
      duration: widget.duration,
      reverseDuration: widget.reverseDuration,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
      reverseCurve: widget.reverseCurve,
    );
    _oldChild = widget.child;
    _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(AnimatedSizeAndFade oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.child.key != oldWidget.child.key) {
      _oldChild = oldWidget.child;
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: _animation.value,
            child: Opacity(
              opacity: _animation.value,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}
