import 'dart:async';
import 'dart:ffi' as fii;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutterwithoutimport/WeeklySummary.dart';

class Task{
  final String TaskName;
  int totalremain;
  int initTime;
  Timer? timer;
  Task({required this.TaskName,required this.initTime ,required this.totalremain});
  String getFormatted(){
    int hour =totalremain ~/ 3600;
    int min =totalremain  ~/3600 % 60;
    int sec =totalremain % 60;
    return "${hour.toString().padLeft(2,'0')}:${min.toString().padLeft(2,'0')}:${sec.toString().padLeft(2,'0')}";
  }
  void StartTimer(VoidCallback onTick,VoidCallback onComplete){
    timer?.cancel();
    if(totalremain >0){
      totalremain -=1;
      onTick();
    }else{
      timer?.cancel();
      onComplete();
    }
  }
  void StopTimer(VoidCallback update){
    timer?.cancel();
    update();
  }
}

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final TaskNameController =TextEditingController();
  final TaskHurController=TextEditingController();
  final TaskMinController=TextEditingController();
  final TaskSecController=TextEditingController();
  List<Task> TaskList =[];
  Task? nowTask;
  void StartTask(Task? task){
    nowTask =task;
    setState(() {
      nowTask?.StartTimer((){
        setState(() {

        });
      }, (){
        setState(() {
          nowTask =null;
        });
      });
    });
  }
  void StopTask(){
    nowTask?.StopTimer((){
      setState(() {
        nowTask =null;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(padding: EdgeInsets.all(16),child: Column(
        children: [
            SizedBox(
              height: 200,
            ),
          if(nowTask !=null)...[
            Stack(
              children: [
                SizedBox(width: 100,height: 100,child: CircularProgressIndicator(
                  value: nowTask!.totalremain / nowTask !.initTime ,
                ),),
                Text(nowTask!.getFormatted())
              ],
            )
          ] else ...[
            Text("no Task is Active Now")
          ]
        ],
      ),),
      bottomSheet: DraggableScrollableSheet(builder: (BuildContext context,ScrollController scrollController){
        return Container(
          padding: EdgeInsets.all(16),
          color: Colors.white,
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                ElevatedButton(onPressed: (){
                  setState(() {
                    final int totalremain =int.tryParse(TaskHurController.text)! * 3600 + int.tryParse(TaskMinController.text)! * 60 +int.tryParse(TaskSecController.text)!;
                    TaskList.add(Task(TaskName: TaskNameController.text.trim(), initTime: totalremain, totalremain: totalremain));
                  });
                }, child: Text("data")),
                TextField(
                  controller: TaskNameController,
                  decoration: InputDecoration(label: Text("Task name")),
                ),
                Row(
                  children: [
                    TextField(
                      controller: TaskHurController,
                      decoration: InputDecoration(label: Text("Task Hour")),
                    ),
                    TextField(
                      controller: TaskMinController,
                      decoration: InputDecoration(label: Text("Task Min")),
                    ),
                    TextField(
                      controller: TaskSecController,
                      decoration: InputDecoration(label: Text("Task Sec")),
                    ),
                  ],
                ),
                ReorderableListView.builder(itemBuilder: (context,index){
                  final task=TaskList[index];
                  return Dismissible(key: ValueKey(task), child: Card(
                    child: ListTile(
                      title: Text(task.TaskName),
                      subtitle: Text(task.initTime.toString()),
                      trailing: IconButton(onPressed: (){
                        setState(() {

                        });
                      }, icon: Icon(Icons.play_arrow)),
                      leading: IconButton(onPressed: (){
                        setState(() {

                        });
                      }, icon:Icon(Icons.stop) ),
                    ),
                  ),background: Container(
                    child: Align(alignment: Alignment.center,child: Icon(Icons.delete),),
                    color: Colors.red,
                  ),
                    onDismissed: (dis){
                      setState(() {
                        TaskList.removeAt(index);
                      });
                  },);
                }, itemCount: TaskList.length, onReorder: (oldIndex,newIndex){
                  setState(() {
                     if(newIndex>oldIndex){
                       newIndex -=1;
                     }
                     final item =TaskList.removeAt(oldIndex);
                     TaskList.insert(newIndex, item);
                  });
                })
              ],
            ),
          ),
        );
      }),
    );
  }
}

