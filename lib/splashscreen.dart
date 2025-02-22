import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutterwithoutimport/Timer.dart';
class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen>with TickerProviderStateMixin{
  late AnimationController animationController;
  late Animation<double> animation;
  @override
  void dispose(){
    super.dispose();
    animationController.reverse();
  }
  @override
  void initState() {
    super.initState();
    animationController =AnimationController(vsync: this,duration: Duration(seconds: 3));
    animation =Tween(begin: 50.0,end: 150.0).animate(animationController);
    animationController.forward();
    Future.delayed(Duration(seconds: 3),(){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>Timerscreen()));
    });
  }
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(padding: EdgeInsets.all(30),child: Column(
        children: [
          Align(
            child: Column(
          children: [
            SizedBox(height: 300,),
            Text("Forest",style: TextStyle(fontSize: 30),),
            AnimatedBuilder(animation: animation, builder: (context,child) =>Container(
              width: animation.value,
              height: animation.value,
              child: child,
            ),child: Icon(Icons.access_time_rounded,size: 100,),),
        ],
      ) ,
            alignment: Alignment.center,
          )
        ],
      ),),
    );
  }
}
