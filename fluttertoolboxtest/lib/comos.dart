import 'package:cosmos/cosmos.dart';
import 'package:flutter/material.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController.unbounded(
        vsync: this, value: 0, duration: Duration(days: 9000))
      ..addListener(() => setState(() {}));
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: CosmosWidget(
            velocity: 0.002,
            child: Container(
              width: 100,
              height: 100,
            ),
          ),
        ),
      ),
    );
  }
}

void main() => runApp(MyApp());
