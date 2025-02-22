import 'package:flutter/material.dart';
import 'dart:ui';

import 'Timer.dart';


class WeeklySummary extends StatelessWidget {
  final List<Task> workList;
  final List<Task> restList;

  const WeeklySummary({super.key, required this.workList, required this.restList});
  @override
  Widget build(BuildContext context) {
    int totalWorkSeconds = workList.fold(0, (sum, task) => sum + task.remainingSeconds);
    int totalRestSeconds = restList.fold(0, (sum, task) => sum + task.remainingSeconds);
    return Scaffold(
      appBar: AppBar(title: Text("Weekly Summary")),
      body: Center(
        child: CustomPaint(
          size: Size(300, 200),
          painter: BarChartPainter(totalWorkSeconds, totalRestSeconds),
        ),
      ),
    );
  }
}

class BarChartPainter extends CustomPainter {
  final int workSeconds;
  final int restSeconds;

  BarChartPainter(this.workSeconds, this.restSeconds);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint workPaint = Paint()..color = Colors.blue;
    final Paint restPaint = Paint()..color = Colors.red;
    final Paint borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    double maxTime = (workSeconds > restSeconds ? workSeconds : restSeconds).toDouble();
    maxTime = maxTime == 0 ? 1 : maxTime; // 避免除以零

    double barWidth = size.width * 0.4;
    double workBarHeight = (workSeconds / maxTime) * size.height;
    double restBarHeight = (restSeconds / maxTime) * size.height;

    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.1, size.height - workBarHeight, barWidth, workBarHeight),
      workPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.1, size.height - workBarHeight, barWidth, workBarHeight),
      borderPaint,
    );

    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.5, size.height - restBarHeight, barWidth, restBarHeight),
      restPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.5, size.height - restBarHeight, barWidth, restBarHeight),
      borderPaint,
    );

    final textStyle = TextStyle(color: Colors.black, fontSize: 16);
    final textPainterWork = TextPainter(
      text: TextSpan(text: "Work", style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainterWork.paint(canvas, Offset(size.width * 0.1 + barWidth / 4, size.height + 5));

    final textPainterRest = TextPainter(
      text: TextSpan(text: "Rest", style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainterRest.paint(canvas, Offset(size.width * 0.5 + barWidth / 4, size.height + 5));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // 讓畫布重新繪製
  }
}
