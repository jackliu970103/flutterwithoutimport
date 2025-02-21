import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutterwithoutimport/WeeklySummary.dart';

class Timerscreen extends StatefulWidget {
  const Timerscreen({super.key});

  @override
  State<Timerscreen> createState() => _TimerscreenState();
}

class _TimerscreenState extends State<Timerscreen> {
  final List<Task> _taskList = [];
  final List<Task> _WorkList=[];
  final List<Task> _RestList=[];
  final TextEditingController taskNameCTR = TextEditingController();
  final TextEditingController taskMinCTR = TextEditingController();
  final TextEditingController taskSecCTR = TextEditingController();
  late bool isitwork=false;
  Task? _activeTask;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(title: Text("Task Timer"),actions: [
        PopupMenuButton(itemBuilder: (BuildContext context)=>[
          PopupMenuItem(child: Text("Weekly Summary"),onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>WeeklySummary( workList: _WorkList, restList: _RestList,)));
          },)
        ],)
      ],),
      body:Align(
        child: Column(
          children: [
            Text(
              _activeTask != null
                  ? _activeTask!.getFormattedTime()
                  : "No active timer",
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            if (_activeTask != null)
              Text(
                "Current Task: ${_activeTask!.taskName}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
          ],
        ),
        alignment: Alignment.center,
      ),

      bottomSheet: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        minChildSize: 0.2,
        maxChildSize: 0.9,
        builder: (BuildContext context, ScrollController scrollController) {
          return Container(
            color: Colors.white,
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      int totalSeconds = (int.tryParse(taskMinCTR.text) ?? 0) * 60 +
                          (int.tryParse(taskSecCTR.text) ?? 0);
                      _taskList.add(Task(
                        taskNameCTR.text.trim(),
                        totalSeconds,
                        isitwork
                      ));
                      if(isitwork){
                        _WorkList.add(Task(
                            taskNameCTR.text.trim(),
                            totalSeconds,
                            isitwork
                        ));
                      }else{
                        _RestList.add(Task(
                            taskNameCTR.text.trim(),
                            totalSeconds,
                            isitwork
                        ));
                      }
                    });
                  },
                  child: Text("Add Task"),
                ),
                TextField(
                  controller: taskNameCTR,
                  decoration: InputDecoration(labelText: "Task Name"),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: taskMinCTR,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: "Min"),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: taskSecCTR,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: "Sec"),
                      ),
                    ),
                    Switch(value: isitwork, onChanged:(bool value){
                      setState(() {
                        isitwork =value;
                      });
                    })
                  ],
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _taskList.length,
                        itemBuilder: (context, index) {
                          final task = _taskList[index];
                          return ListTile(
                            key: ValueKey(task),
                            title: Text(task.taskName),
                            subtitle: Text("${task.getFormattedTime()}   ${task.isitwork}"),
                            trailing: IconButton(
                              icon: Icon(Icons.play_arrow),
                              onPressed: () {
                                setState(() {
                                  if (_activeTask != null) {
                                    _activeTask!.stopTimer();
                                  }
                                  _activeTask = task;
                                  task.startTimer(() {
                                    setState(() {});
                                  }, () {
                                    setState(() {
                                      _activeTask = null;
                                    });
                                  });
                                });
                              },
                            ),
                          );
                        },
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) newIndex -= 1;
                            final item = _taskList.removeAt(oldIndex);
                            _taskList.insert(newIndex, item);
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class Task {
  final String taskName;
  int remainingSeconds;
  Timer? _timer;
  bool isitwork;

  Task(this.taskName, this.remainingSeconds,this.isitwork);

  String getFormattedTime() {
    int hours = remainingSeconds ~/ 3600;
    int minutes = (remainingSeconds % 3600) ~/ 60;
    int seconds = remainingSeconds % 60;
    return "${hours.toString().padLeft(2, '0')}:"
        "${minutes.toString().padLeft(2, '0')}:"
        "${seconds.toString().padLeft(2, '0')}";
  }

  void startTimer(VoidCallback onTick, VoidCallback onComplete) {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        remainingSeconds--;
        onTick();
      } else {
        timer.cancel();
        onComplete();
      }
    });
  }
  void stopTimer() {
    _timer?.cancel();
  }
}
