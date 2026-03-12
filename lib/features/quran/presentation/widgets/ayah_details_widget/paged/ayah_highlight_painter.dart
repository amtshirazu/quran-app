import 'package:flutter/material.dart';

class AyahHighlightPainter extends CustomPainter {
  final List<Offset> points;
  final double scaleX;
  final double scaleY;

  AyahHighlightPainter(
      this.points,
      this.scaleX,
      this.scaleY,
      );

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();

    if (points.isEmpty) return;

    path.moveTo(points.first.dx * scaleX, points.first.dy * scaleY);

    for (var p in points) {
      path.lineTo(p.dx * scaleX, p.dy * scaleY);
    }

    path.close();

    final paint = Paint()
      ..color = Colors.yellow.withOpacity(0.35)
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}