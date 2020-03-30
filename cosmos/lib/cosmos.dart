library cosmos;

import 'dart:math';

import 'package:flutter/material.dart';

class CosmosWidget extends StatefulWidget {
  final Widget child;
  final double velocity;

  CosmosWidget({Key key, this.velocity, this.child}) : super(key: key);

  @override
  _CosmosWidgetState createState() => _CosmosWidgetState();
}

class _CosmosWidgetState extends State<CosmosWidget> {
  List<Offset> _stars = [];
  int _spawnAccumulator = 0;
  int _nextSpawnThreshold = 0;
  var _random = Random();

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < 10 + _random.nextInt(20); i++) {
      var position = Offset(_random.nextDouble(), _random.nextDouble());
      _stars.add(position);
    }

    _nextSpawnThreshold = _random.nextInt(500);
  }

  _step() {
    _moveStars();

    _spawnAccumulator += (1000 * widget.velocity).floor();
    if (_spawnAccumulator >= _nextSpawnThreshold) {
      _spawnAccumulator = 0;
      _nextSpawnThreshold = _random.nextInt(100);
      _spawnStars();
    }

    _deleteOldStars();
  }

  _moveStars() {
    for (int i = 0; i < _stars.length; ++i) {
      var star = _stars[i];
      _stars[i] = Offset(star.dx - widget.velocity, star.dy);
    }
  }

  _spawnStars() {
    var amount = _random.nextInt(2);
    for (int i = 0; i < amount; ++i) {
      var position = Offset(1, _random.nextDouble());
      _stars.add(position);
    }
  }

  _deleteOldStars() {
    var removalThreshold;
    for (int i = 0; i < _stars.length; ++i) {
      if (_stars[i].dx < 0) {
        removalThreshold = i;
      } else {
        break;
      }
    }
    if (removalThreshold != null) {
      _stars.removeRange(0, removalThreshold + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    _step();
    return CustomPaint(
      painter: CosmosPainter(stars: _stars),
      child: widget.child,
    );
  }
}

class CosmosPainter extends CustomPainter {
  final _backgroundColor = Color(0xff2D3758);
  final _starColor = Color(0xffffffff);

  List<Offset> stars;

  CosmosPainter({this.stars});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = _backgroundColor,
    );
    for (var star in stars) {
      canvas.drawRect(
          Rect.fromCenter(
              center: Offset(size.width * star.dx, size.height * star.dy),
              width: 2,
              height: 2),
          Paint()..color = _starColor);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
