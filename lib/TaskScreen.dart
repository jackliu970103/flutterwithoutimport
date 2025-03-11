import 'package:flutter/material.dart';
import 'package:flutterwithoutimport/Timer.dart';
class Taskscreen extends StatefulWidget {
  final List<Task> TaskList;
  Taskscreen({required this.TaskList});

  @override
  State<Taskscreen> createState() => _TaskscreenState();
}

class _TaskscreenState extends State<Taskscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(padding: EdgeInsets.all(16),child: Column(
        children: [
          ListView.builder(itemCount: widget.TaskList.length,itemBuilder: (context,index){
              return Column(
                children: [

                ],
              );
          })
        ],
      ),),
    );
  }
}
