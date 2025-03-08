import 'dart:async';
import 'package:flutter/material.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final taskNameController = TextEditingController();
  final taskHourController = TextEditingController(text: "0");
  final taskMinController = TextEditingController(text: "0");
  final taskSecController = TextEditingController(text: "0");
  List<Task> taskList = [];
  Task? nowTask;

  void startTask(Task? task) {
    // Stop any currently running task
    if (nowTask != null) {
      nowTask?.stopTimer();
    }

    setState(() {
      nowTask = task;
    });

    nowTask?.startTimer(
      onTick: () {
        setState(() {});
      },
      onComplete: () {
        setState(() {
          nowTask = null;
        });
      },
    );
  }

  void stopTask() {
    nowTask?.stopTimer();
    setState(() {
      nowTask = null;
    });
  }

  @override
  void dispose() {
    // Clean up controllers
    taskNameController.dispose();
    taskHourController.dispose();
    taskMinController.dispose();
    taskSecController.dispose();
    // Stop any timer
    nowTask?.stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Timer')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (nowTask != null) ...[
              const Text(
                "Current Task",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(nowTask!.taskName, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 20),
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 180,
                      width: 180,
                      child: CircularProgressIndicator(
                        value: nowTask!.totalRemain / nowTask!.initTime,
                        strokeWidth: 10,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.blue,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          nowTask!.getFormatted(),
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: stopTask,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Stop Timer"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
              const Center(
                child: Text(
                  "No Timer Active",
                  style: TextStyle(fontSize: 24, color: Colors.grey),
                ),
              ),
            ],
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: ListView(
              controller: scrollController,
              children: [
                // Drag handle indicator
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                  ),
                ),
                const Text(
                  "Task List",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TextField(
                    controller: taskNameController,
                    decoration: const InputDecoration(
                      labelText: "Task Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: taskHourController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Hours",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: taskMinController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Minutes",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: taskSecController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Seconds",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Parse input values with error handling
                    final hours = int.tryParse(taskHourController.text) ?? 0;
                    final minutes = int.tryParse(taskMinController.text) ?? 0;
                    final seconds = int.tryParse(taskSecController.text) ?? 0;

                    final totalSeconds = hours * 3600 + minutes * 60 + seconds;

                    if (totalSeconds <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please enter a valid time"),
                        ),
                      );
                      return;
                    }

                    if (taskNameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please enter a task name"),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      taskList.add(
                        Task(
                          taskName: taskNameController.text.trim(),
                          totalRemain: totalSeconds,
                          initTime: totalSeconds,
                        ),
                      );

                      // Clear input fields
                      taskNameController.clear();
                      taskHourController.text = "0";
                      taskMinController.text = "0";
                      taskSecController.text = "0";
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text("Add Task"),
                ),
                const SizedBox(height: 16),

                // Task list section
                Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.5,
                    minHeight: 100,
                  ),
                  child:
                      taskList.isEmpty
                          ? const Center(
                            child: Text(
                              "No tasks yet. Add a task to get started!",
                            ),
                          )
                          : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: taskList.length,
                            itemBuilder: (context, index) {
                              final task = taskList[index];
                              return Dismissible(
                                key: ValueKey("${task.taskName}_$index"),
                                background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                direction: DismissDirection.endToStart,
                                onDismissed: (direction) {
                                  setState(() {
                                    taskList.removeAt(index);
                                  });
                                },
                                child: Card(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      task.taskName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(task.getFormatted()),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.arrow_upward),
                                          onPressed:
                                              index > 0
                                                  ? () {
                                                    setState(() {
                                                      final task = taskList
                                                          .removeAt(index);
                                                      taskList.insert(
                                                        index - 1,
                                                        task,
                                                      );
                                                    });
                                                  }
                                                  : null,
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.arrow_downward,
                                          ),
                                          onPressed:
                                              index < taskList.length - 1
                                                  ? () {
                                                    setState(() {
                                                      final task = taskList
                                                          .removeAt(index);
                                                      taskList.insert(
                                                        index + 1,
                                                        task,
                                                      );
                                                    });
                                                  }
                                                  : null,
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            startTask(task);
                                          },
                                          icon: const Icon(
                                            Icons.play_arrow,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
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
  int totalRemain;
  final int initTime;
  Timer? timer;

  Task({
    required this.taskName,
    required this.totalRemain,
    required this.initTime,
  });

  void startTimer({
    required VoidCallback onTick,
    required VoidCallback onComplete,
  }) {
    // Cancel any existing timer
    timer?.cancel();

    // Create a new periodic timer that fires every second
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (totalRemain > 0) {
        totalRemain -= 1;
        onTick();
      } else {
        timer.cancel();
        onComplete();
      }
    });
  }

  String getFormatted() {
    int hours = totalRemain ~/ 3600;
    int minutes = (totalRemain % 3600) ~/ 60;
    int seconds = totalRemain % 60;

    return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  void stopTimer() {
    timer?.cancel();
    timer = null;
  }
}
