library single_bounce_widget;

import 'package:flutter/material.dart';

class SingleBounceWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Curve reverseCurve;
  final double scaleMin;
  final double scaleMax;
  final bool reset;
  final VoidCallback onResetDone;
  final VoidCallback onBounceDone;

  SingleBounceWidget({
    Key key,
    this.child,
    this.duration = const Duration(milliseconds: 1000),
    this.curve = Curves.easeOut,
    this.reverseCurve = Curves.easeIn,
    this.scaleMin = 1.0,
    this.scaleMax = 0.9,
    @required this.reset,
    @required this.onResetDone,
    this.onBounceDone,
  })  : assert(reset != null),
        assert(onResetDone != null),
        super(key: key);

  @override
  _SingleBounceWidgetState createState() => _SingleBounceWidgetState();
}

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
    )
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        }
        if (status == AnimationStatus.dismissed) {
          if (widget.onBounceDone != null) {
            widget.onBounceDone();
          }
        }
      })
      ..addListener(() {
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

class SingleBounceAfterTapWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Curve reverseCurve;
  final double scaleMin;
  final double scaleMax;
  final VoidCallback onTap;
  final VoidCallback onBounceDone;

  SingleBounceAfterTapWidget({
    Key key,
    this.child,
    this.duration = const Duration(milliseconds: 1000),
    this.curve = Curves.easeOut,
    this.reverseCurve = Curves.easeIn,
    this.scaleMin = 1.0,
    this.scaleMax = 0.9,
    this.onTap,
    this.onBounceDone,
  }) : super(key: key);

  @override
  _SingleBounceAfterTapWidgetState createState() =>
      _SingleBounceAfterTapWidgetState();
}

class _SingleBounceAfterTapWidgetState
    extends State<SingleBounceAfterTapWidget> {
  bool _resetBounce = false;
  bool _isBouncing = false;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: _isBouncing,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            _resetBounce = true;
            _isBouncing = true;
          });
          if (widget.onTap != null) {
            widget.onTap();
          }
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
          onBounceDone: () {
            setState(() {
              _isBouncing = false;
            });
            if (widget.onBounceDone != null) {
              widget.onBounceDone();
            }
          },
          child: widget.child,
        ),
      ),
    );
  }
}

class SingleBounceLedByTapWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Curve reverseCurve;
  final double scaleMin;
  final double scaleMax;
  final VoidCallback onTap;

  SingleBounceLedByTapWidget({
    Key key,
    this.child,
    this.duration = const Duration(milliseconds: 1000),
    this.curve = Curves.easeOut,
    this.reverseCurve = Curves.easeIn,
    this.scaleMin = 1.0,
    this.scaleMax = 0.9,
    this.onTap,
  }) : super(key: key);

  @override
  _SingleBounceLedByTapWidgetState createState() =>
      _SingleBounceLedByTapWidgetState();
}

class _SingleBounceLedByTapWidgetState extends State<SingleBounceLedByTapWidget>
    with SingleTickerProviderStateMixin {
  /// Animation controller
  AnimationController _controller;
  Animation _animation;

  /// View scale used in order to make the bouncing animation
  double _scale;

  /// Key of the given child used to get its size and position whenever we need
  GlobalKey _childKey = GlobalKey();

  /// If the touch position is outside or not of the given child
  bool _isOutside = false;

  /// Simple getter on widget's child
  Widget get child => widget.child;

  /// Simple getter on widget's onPressed callback
  VoidCallback get onTap => widget.onTap;

  /// Simple getter on widget's animation duration
  Duration get duration => widget.duration;

  /// If track dragging all the time it can interfere with scroll views this
  /// widget is contained in
  bool _shouldTrackDragging = false;

  /// We instantiate the animation controller
  /// The idea is to call setState() each time the controller's
  /// value changes
  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..addListener(() {
        setState(() {});
      });

    _animation = Tween(begin: widget.scaleMin, end: widget.scaleMax).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
        reverseCurve: widget.reverseCurve,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Each time the [_controller]'s value changes, build() will be called
  /// We just have to calculate the appropriate scale from the controller value
  /// and pass it to our Transform.scale widget
  @override
  Widget build(BuildContext context) {
    _scale = _animation.value;
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onLongPressEnd: (details) => _onLongPressEnd(details, context),
      onHorizontalDragEnd: _shouldTrackDragging ? _onDragEnd : null,
      onVerticalDragEnd: _shouldTrackDragging ? _onDragEnd : null,
      onHorizontalDragUpdate: _shouldTrackDragging
          ? (details) => _onDragUpdate(details, context)
          : null,
      onVerticalDragUpdate: _shouldTrackDragging
          ? (details) => _onDragUpdate(details, context)
          : null,
      child: Transform.scale(
        key: _childKey,
        scale: _scale,
        child: child,
      ),
    );
  }

  /// Simple method called when we need to notify the user of a press event
  _triggerOnPressed() {
    if (onTap != null) {
      onTap();
    }
  }

  /// We start the animation
  _onTapDown(TapDownDetails details) {
    _controller.forward();
    setState(() {
      _shouldTrackDragging = true;
    });
  }

  /// We reverse the animation and notify the user of a press event
  _onTapUp(TapUpDetails details) {
    setState(() {
      _shouldTrackDragging = false;
    });
    Future.delayed(duration, () {
      _controller.reverse();
    });
    _triggerOnPressed();
  }

  /// We reverse the animation
  _onTapCancel() {
    setState(() {
      _shouldTrackDragging = false;
    });
    Future.delayed(duration, () {
      _controller.reverse();
    });
  }

  /// Here we are listening on each change when drag event is triggered
  /// We must keep the [_isOutside] value updated in order to use it later
  _onDragUpdate(DragUpdateDetails details, BuildContext context) {
    final Offset touchPosition = details.globalPosition;
    _isOutside = _isOutsideChildBox(touchPosition);
  }

  /// When this callback is triggered, we reverse the animation
  /// If the touch position is inside the children renderBox, we notify the user of a press event
  _onLongPressEnd(LongPressEndDetails details, BuildContext context) {
    setState(() {
      _shouldTrackDragging = false;
    });

    final Offset touchPosition = details.globalPosition;

    if (!_isOutsideChildBox(touchPosition)) {
      _triggerOnPressed();
    }

    _controller.reverse();
  }

  /// When this callback is triggered, we reverse the animation
  /// As we do not have position details, we use the [_isOutside] field to know
  /// if we need to notify the user of a press event
  _onDragEnd(DragEndDetails details) {
    setState(() {
      _shouldTrackDragging = false;
    });
    if (!_isOutside) {
      _triggerOnPressed();
    }
    _controller.reverse();
  }

  /// Method called when we need to now if a specific touch position is inside the given
  /// child render box
  bool _isOutsideChildBox(Offset touchPosition) {
    final RenderBox childRenderBox =
        _childKey.currentContext.findRenderObject();
    final Size childSize = childRenderBox.size;
    final Offset childPosition = childRenderBox.localToGlobal(Offset.zero);

    return (touchPosition.dx < childPosition.dx ||
        touchPosition.dx > childPosition.dx + childSize.width ||
        touchPosition.dy < childPosition.dy ||
        touchPosition.dy > childPosition.dy + childSize.height);
  }
}
