import 'dart:math';
import 'package:flutter/material.dart';

class RainDropManager {
  static void showRain(
    BuildContext context, {
    required Widget dropWidget,
    int dropCount = 15,
    Duration duration = const Duration(seconds: 2),
  }) {
    final overlay = Overlay.of(context);

    for (int i = 0; i < dropCount; i++) {
      final entry = OverlayEntry(
        builder:
            (ctx) => _RainDrop(
              widget: dropWidget,
              delay: Duration(milliseconds: i * 100), // staggered
              duration: duration,
            ),
      );
      overlay.insert(entry);
    }
  }
}

class _RainDrop extends StatefulWidget {
  final Widget widget;
  final Duration delay;
  final Duration duration;

  const _RainDrop({
    Key? key,
    required this.widget,
    required this.delay,
    required this.duration,
  }) : super(key: key);

  @override
  State<_RainDrop> createState() => _RainDropState();
}

class _RainDropState extends State<_RainDrop>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late double startX;
  late double screenHeight;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    startX = Random().nextDouble() * screenWidth;

    _animation = Tween<double>(
      begin: -30,
      end: screenHeight + 30,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.dispose();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, child) {
        return Positioned(
          top: _animation.value,
          left: startX,
          child: widget.widget,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
