import 'dart:math' as math;

import 'package:flutter/material.dart';

class MusicLoadingIndicator extends StatefulWidget {
  const MusicLoadingIndicator({
    super.key,
    this.color = Colors.white,
    this.barCount = 5,
    this.size = 56,
  });

  final Color color;
  final int barCount;
  final double size;

  @override
  State<MusicLoadingIndicator> createState() => _MusicLoadingIndicatorState();
}

class _MusicLoadingIndicatorState extends State<MusicLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final barWidth = widget.size / (widget.barCount * 2 - 1);
    return SizedBox(
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(widget.barCount, (index) {
              final phase = index / widget.barCount;
              final value = math.sin((_controller.value + phase) * math.pi * 2);
              final normalized = (value + 1) / 2;
              final height = widget.size * (0.25 + normalized * 0.75);
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: barWidth / 2),
                child: Container(
                  width: barWidth,
                  height: height,
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(barWidth),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
