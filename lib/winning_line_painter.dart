import 'package:flutter/material.dart';

class LinePainter extends CustomPainter {
  final Offset start;
  final Offset end;

  LinePainter(this.start, this.end);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 4.0;

    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
