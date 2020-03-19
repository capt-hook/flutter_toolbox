library single_bounce_widget;

import 'package:flutter/material.dart';

class _SingleBounceWidgetState extends State<SingleBounceWidget>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      }
      if (status == AnimationStatus.dismissed) {
        widget.onDone();
      }
    });
    _controller.addListener(() {
      setState(() {});
    });

    _animation = Tween(begin: widget.scaleMin, end: widget.scaleMax).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
        reverseCurve: widget.reverseCurve,
      ),
    );

    if (widget.reset) {
      _controller.reset();
      _controller.forward();
      Future.delayed(Duration.zero, () => widget.onResetDone());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SingleBounceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reset && !oldWidget.reset) {
      _controller.reset();
      _controller.forward();
      Future.delayed(Duration.zero, () => widget.onResetDone());
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = _animation.value;
    return Container(
      child: Transform.scale(
        scale: scale,
        child: widget.child,
      ),
    );
  }
}

class SingleBounceWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Curve reverseCurve;
  final double scaleMin;
  final double scaleMax;
  final bool reset;
  final VoidCallback onResetDone;
  final VoidCallback onDone;

  SingleBounceWidget({
    this.child,
    this.duration = const Duration(milliseconds: 1000),
    this.curve = Curves.easeOut,
    this.reverseCurve = Curves.easeIn,
    this.scaleMin = 1.0,
    this.scaleMax = 0.9,
    this.reset,
    this.onResetDone,
    this.onDone,
  })  : assert(reset != null),
        assert(onResetDone != null),
        assert(onDone != null);

  @override
  _SingleBounceWidgetState createState() => _SingleBounceWidgetState();
}

class SingleBounceTapWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Curve reverseCurve;
  final double scaleMin;
  final double scaleMax;
  final VoidCallback onTap;
  final VoidCallback onDone;

  SingleBounceTapWidget({
    this.child,
    this.duration = const Duration(milliseconds: 1000),
    this.curve = Curves.easeOut,
    this.reverseCurve = Curves.easeIn,
    this.scaleMin = 1.0,
    this.scaleMax = 0.9,
    this.onTap,
    this.onDone,
  })  : assert(onTap != null),
        assert(onDone != null);

  @override
  _SingleBounceTapWidgetState createState() => _SingleBounceTapWidgetState();
}

class _SingleBounceTapWidgetState extends State<SingleBounceTapWidget> {
  bool _resetBounce = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _resetBounce = true;
        });
        widget.onTap();
      },
      child: SingleBounceWidget(
        duration: widget.duration,
        curve: widget.curve,
        reverseCurve: widget.reverseCurve,
        scaleMax: widget.scaleMax,
        scaleMin: widget.scaleMin,
        reset: _resetBounce,
        onResetDone: () {
          setState(() {
            _resetBounce = false;
          });
        },
        onDone: widget.onDone,
        child: widget.child,
      ),
    );
  }
}
