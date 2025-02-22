import 'dart:async';
import 'dart:ffi' as fii;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutterwithoutimport/WeeklySummary.dart';

class Timerscreen extends StatefulWidget {
  const Timerscreen({super.key});

  @override
  State<Timerscreen> createState() => _TimerscreenState();
}

class _TimerscreenState extends State<Timerscreen> {
  final List<Task> _taskList = [];
  final List<Task> _WorkList = [];
  final List<Task> _RestList = [];
  final TextEditingController taskNameCTR = TextEditingController();
  final TextEditingController taskMinCTR = TextEditingController();
  final TextEditingController taskSecCTR = TextEditingController();
  bool isitwork = false;
  Task? _activeTask;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Task Timer"),
        actions: [
          PopupMenuButton(
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                child: const Text("Weekly Summary"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          WeeklySummary(workList: _WorkList, restList: _RestList),
                    ),
                  );
                },
              )
            ],
          )
        ],
      ),
      body: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _activeTask != null ? _activeTask!.getFormattedTime() : "No active timer",
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (_activeTask != null)
              Text(
                "Current Task: ${_activeTask!.taskName}",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            const SizedBox(height: 20),
            if (_activeTask != null)
              SizedBox(
                width: 200,
                height: 200,
                child: CustomPaint(
                  painter: ClockPainter(
                    _activeTask!.remainingSeconds % 60.toDouble(),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomSheet: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.4,
        minChildSize: 0.2,
        maxChildSize: 0.9,
        builder: (BuildContext context, ScrollController scrollController) {
          return Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              controller: scrollController, // 讓 BottomSheet 可以滾動
              child: Column(
                mainAxisSize: MainAxisSize.min, // 讓 Column 只佔用需要的空間
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (int.tryParse(taskSecCTR.text)! < 60) {
                          int totalSeconds =
                              (int.tryParse(taskMinCTR.text) ?? 0) * 60 + (int.tryParse(taskSecCTR.text) ?? 0);
                          final newTask = Task(taskNameCTR.text.trim(), totalSeconds, isitwork);
                          _taskList.add(newTask);
                          if (isitwork) {
                            _WorkList.add(newTask);
                          } else {
                            _RestList.add(newTask);
                          }
                        } else {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text("秒數不可大於60")));
                        }
                      });
                    },
                    child: const Text("Add Task"),
                  ),
                  TextField(
                    controller: taskNameCTR,
                    decoration: const InputDecoration(labelText: "Task Name"),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: taskMinCTR,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: "Min"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: taskSecCTR,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: "Sec"),
                        ),
                      ),
                      Switch(
                        value: isitwork,
                        onChanged: (bool value) {
                          setState(() {
                            isitwork = value;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 500,
                    child: ReorderableListView.builder(
                      shrinkWrap: false,
                      itemCount: _taskList.length,
                      itemBuilder: (context, index) {
                        final task = _taskList[index];
                        return Dismissible(
                          key: ValueKey(task),
                          onDismissed: (direction) {
                            setState(() {
                              _taskList.removeAt(index);
                            });
                          },
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          child: Card(
                            child: ListTile(
                              title: Text(task.taskName),
                              subtitle: Text("${task.getFormattedTime()}  是否為工作  ${task.isitwork}"),
                              trailing: IconButton(
                                icon: const Icon(Icons.play_arrow),
                                onPressed: () {
                                  setState(() {
                                    _activeTask?.stopTimer();
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
                            ),
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
                  ),
                ],
              ),
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

  Task(this.taskName, this.remainingSeconds, this.isitwork);

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
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
class ClockPainter extends CustomPainter {
  final double remainingTime; // 剩餘時間，單位：秒

  ClockPainter(this.remainingTime);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()..color = Colors.blueAccent;
    canvas.drawCircle(center, radius, paint);

    for (int i = 0; i < 60; i++) {
      final angle = 2 * pi * i / 60;
      final startOffset = Offset(
        center.dx + radius * 0.9 * cos(angle),
        center.dy + radius * 0.9 * sin(angle),
      );
      final endOffset = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      paint.color = i % 5 == 0 ? Colors.white : Colors.white.withOpacity(0.5);
      paint.strokeWidth = 2.0;
      canvas.drawLine(startOffset, endOffset, paint);
    }

    final remainingAngle = 2 * pi * (1 - remainingTime / 60);
    final handLength = radius * 0.7;
    final handOffset = Offset(
      center.dx + handLength * cos(remainingAngle),
      center.dy + handLength * sin(remainingAngle),
    );
    paint.color = Colors.red;
    paint.strokeWidth = 4.0;
    canvas.drawLine(center, handOffset, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}


