library breathing_widget;

import 'package:flutter/material.dart';

class _BreathingWidgetState extends State<BreathingWidget>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  double _value = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      lowerBound: widget.scaleMin,
      upperBound: widget.scaleMax,
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      }
      if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });
    _controller.addListener(() {
      setState(() {
        _value = _controller.value;
      });
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Transform.scale(
        scale: _value,
        child: widget.child,
      ),
    );
  }
}

class BreathingWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double scaleMin;
  final double scaleMax;

  BreathingWidget({
    this.child,
    this.duration = const Duration(milliseconds: 1000),
    this.scaleMin = 0.9,
    this.scaleMax = 1.1,
  });

  @override
  _BreathingWidgetState createState() => _BreathingWidgetState();
}
