import 'package:breathing_widget/breathing_widget.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: BreathingWidget(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.red,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void main() => runApp(MyApp());
