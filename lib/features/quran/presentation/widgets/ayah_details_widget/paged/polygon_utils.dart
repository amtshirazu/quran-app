import 'dart:ui';

Rect polygonToRect(String polygon) {

  final points = polygon.trim().split(' ').where((s) => s.isNotEmpty).toList();

  double minX = double.infinity;
  double minY = double.infinity;
  double maxX = -double.infinity;
  double maxY = -double.infinity;

  for (var p in points) {

    final coords = p.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    if (coords.length < 2) continue;

    final x = double.parse(coords[0]);
    final y = double.parse(coords[1]);

    if (x < minX) minX = x;
    if (y < minY) minY = y;
    if (x > maxX) maxX = x;
    if (y > maxY) maxY = y;
  }

  return Rect.fromLTRB(minX, minY, maxX, maxY);
}

List<Offset> polygonToOffsets(String polygon) {

  final points = polygon.trim().split(' ').where((s) => s.isNotEmpty).toList();

  return points.map((p) {
    final coords = p.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    final x = double.parse(coords[0]);
    final y = double.parse(coords[1]);

    return Offset(x, y);
  }).toList();
}