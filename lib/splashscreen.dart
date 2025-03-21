import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutterwithoutimport/Timer.dart';

class Splashscreen extends StatefulWidget {
  final Function(ThemeData) updateTheme;

  Splashscreen({required this.updateTheme});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen>
    with TickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );
    animation = Tween(begin: 50.0, end: 150.0).animate(animationController);
    animationController.forward();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TimerScreen(updateTheme: widget.updateTheme)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          children: [
            SizedBox(height: 100,),
            Align(
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: animation,
                    builder:
                        (context, child) => Container(
                      width: animation.value,
                      height: animation.value,
                      child: child,
                    ),
                    child: Icon(Icons.lock_clock, size: 100),
                  ),
                ],
              ),
              alignment: Alignment.center,
            ),
          ],
        ),
      ),
    );
  }
}
