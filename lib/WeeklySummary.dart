import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

class TaskType {
  final String taskname;
  final String time;

  TaskType({required this.taskname, required this.time});

  factory TaskType.fromJson(Map<String, dynamic> json) {
    return TaskType(
      taskname: json['Taskname'],
      time: json['time'],
    );
  }
}

class WeeklySchedule {
  final List<TaskType> monday;
  final List<TaskType> tuesday;
  final List<TaskType> wednesday;
  final List<TaskType> thursday;
  final List<TaskType> friday;
  final List<TaskType> saturday;
  final List<TaskType> sunday;

  WeeklySchedule({
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
    required this.sunday,
  });

  factory WeeklySchedule.fromJson(Map<String, dynamic> json) {
    return WeeklySchedule(
      monday: (json['Monday'] as List).map((taskJson) => TaskType.fromJson(taskJson)).toList(),
      tuesday: (json['Tuesday'] as List).map((taskJson) => TaskType.fromJson(taskJson)).toList(),
      wednesday: (json['Wednesday'] as List).map((taskJson) => TaskType.fromJson(taskJson)).toList(),
      thursday: (json['Thursday'] as List).map((taskJson) => TaskType.fromJson(taskJson)).toList(),
      friday: (json['Friday'] as List).map((taskJson) => TaskType.fromJson(taskJson)).toList(),
      saturday: (json['Saturday'] as List).map((taskJson) => TaskType.fromJson(taskJson)).toList(),
      sunday: (json['Sunday'] as List).map((taskJson) => TaskType.fromJson(taskJson)).toList(),
    );
  }
}

List<WeeklySchedule> parseSchedules(String jsonString) {
  final List<dynamic> jsonList = jsonDecode(jsonString);
  return jsonList.map((scheduleJson) => WeeklySchedule.fromJson(scheduleJson)).toList();
}

class WeeklysummaryScreen extends StatefulWidget {
  const WeeklysummaryScreen({super.key});

  @override
  State<WeeklysummaryScreen> createState() => _WeeklysummaryScreenState();
}

class _WeeklysummaryScreenState extends State<WeeklysummaryScreen> {
  late Future<List<WeeklySchedule>> futureList;

  @override
  void initState() {
    super.initState();
    futureList = fetchSchedule();
  }

  Future<List<WeeklySchedule>> fetchSchedule() async {
    final client = HttpClient();

    try {
      final request = await client.getUrl(Uri.parse('https://skills-todo-api.eliaschen.dev/Task'));
      final response = await request.close();

      if (response.statusCode == 200) {
        final stringData = await response.transform(utf8.decoder).join();
        return parseSchedules(stringData);
      } else {
        throw Exception('error http code: ${response.statusCode}');
      }
    } finally {
      client.close();
    }
  }

  Duration sumDayTime(List<TaskType> tasks) {
    int totalSeconds = 0;
    for (var task in tasks) {
      List<String> parts = task.time.split(':');
      if (parts.length == 3) {
        int hours = int.parse(parts[0]);
        int minutes = int.parse(parts[1]);
        int seconds = int.parse(parts[2]);
        totalSeconds += (hours * 3600) + (minutes * 60) + seconds;
      }
    }
    return Duration(seconds: totalSeconds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<List<WeeklySchedule>>(
          future: futureList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('没有数据'));
            }

            List<WeeklySchedule> schedules = snapshot.data!;
            List<int> weekDurations = [
              sumDayTime(schedules.expand((e) => e.monday).toList()).inMinutes,
              sumDayTime(schedules.expand((e) => e.tuesday).toList()).inMinutes,
              sumDayTime(schedules.expand((e) => e.wednesday).toList()).inMinutes,
              sumDayTime(schedules.expand((e) => e.thursday).toList()).inMinutes,
              sumDayTime(schedules.expand((e) => e.friday).toList()).inMinutes,
              sumDayTime(schedules.expand((e) => e.saturday).toList()).inMinutes,
              sumDayTime(schedules.expand((e) => e.sunday).toList()).inMinutes,
            ];

            return Column(
              children: [
                const SizedBox(height: 20),
                const Text('每周工作時長 (分鐘)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Expanded(
                  child: CustomPaint(
                    size: const Size(double.infinity, 300),
                    painter: BarChartPainter(weekDurations),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class BarChartPainter extends CustomPainter {
  final List<int> data;
  final List<String> labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

  BarChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint barPaint = Paint()..color = Colors.blue;
    final Paint axisPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    double maxBarHeight = size.height - 40;
    int maxValue = data.reduce((a, b) => a > b ? a : b);
    double barWidth = size.width / (data.length * 2);

    // 畫 Y 軸
    canvas.drawLine(Offset(30, 10), Offset(30, size.height - 10), axisPaint);

    // 畫 X 軸
    canvas.drawLine(Offset(30, size.height - 10), Offset(size.width, size.height - 10), axisPaint);

    for (int i = 0; i < data.length; i++) {
      double barHeight = (data[i] / maxValue) * maxBarHeight;
      double x = 30 + (i * barWidth * 2) + barWidth / 2;
      double y = size.height - 10 - barHeight;

      // 畫柱狀
      canvas.drawRect(Rect.fromLTWH(x, y, barWidth, size.height - 10), barPaint);

      // 畫標籤
      TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(color: Colors.black, fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x, barHeight));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
