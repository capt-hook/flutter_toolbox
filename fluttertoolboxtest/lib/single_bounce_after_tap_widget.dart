import 'dart:math';

import 'package:flutter/material.dart';
import 'package:single_bounce_widget/single_bounce_widget.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Color _color = Colors.red;
  static const _colors = [Colors.red, Colors.blue, Colors.yellow, Colors.green];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SingleBounceAfterTapWidget(
            duration: const Duration(milliseconds: 250),
            onBounceDone: () {
              setState(() {
                _color = _colors[Random().nextInt(_colors.length)];
              });
            },
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: _color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void main() => runApp(MyApp());
