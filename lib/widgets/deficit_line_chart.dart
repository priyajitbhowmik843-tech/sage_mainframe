import 'package:flutter/material.dart';

class DeficitLineChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final double maxValue;
  final Color lineColor;
  final String suffix;

  const DeficitLineChart({
    Key? key,
    required this.values,
    required this.labels,
    this.maxValue = 100.0,
    this.lineColor = Colors.redAccent,
    this.suffix = 'k',
  }) : super(key: key);

  String formatValue(double value) {
    if (value >= 1000) {
      double kValue = value / 1000;
      return '${kValue.toStringAsFixed(kValue.truncateToDouble() == kValue ? 0 : 1)}$suffix';
    }
    return value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.15), width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), offset: const Offset(0, 6), blurRadius: 16),
        ],
      ),
      child: AspectRatio(
        aspectRatio: 2.0,
        child: CustomPaint(
          painter: _DeficitLineChartPainter(
            values: values,
            labels: labels,
            maxValue: maxValue > 0 ? maxValue : 1.0,
            lineColor: lineColor,
            formatter: formatValue,
          ),
        ),
      ),
    );
  }
}

class _DeficitLineChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final double maxValue;
  final Color lineColor;
  final String Function(double) formatter;

  _DeficitLineChartPainter({
    required this.values,
    required this.labels,
    required this.maxValue,
    required this.lineColor,
    required this.formatter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final double maxChartHeight = size.height * 0.70;
    final double yBottom = size.height * 0.8;

    final points = <Offset>[];
    for (int i = 0; i < values.length; i++) {
      final xCenter = (size.width / values.length) * i + (size.width / (values.length * 2));
      final double normalized = values[i] / maxValue;
      final double pointY = yBottom - (normalized * maxChartHeight);
      points.add(Offset(xCenter, pointY));

      // Draw Label below point (Month)
      textPainter.text = TextSpan(
        text: labels[i],
        style: const TextStyle(color: Colors.black54, fontSize: 11, fontWeight: FontWeight.w600),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(xCenter - textPainter.width / 2, yBottom + 8));

      // Draw Value above point
      textPainter.text = TextSpan(
        text: '-' + formatter(values[i]),
        style: TextStyle(color: lineColor, fontSize: 11, fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(xCenter - textPainter.width / 2, pointY - textPainter.height - 8));
    }

    // Draw Line
    if (points.length > 1) {
      final linePaint = Paint()
        ..color = lineColor
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path();
      path.moveTo(points[0].dx, points[0].dy);
      
      // Use cubic bezier for a smoother curve
      for (int i = 0; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
        final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);
        path.cubicTo(
          controlPoint1.dx, controlPoint1.dy,
          controlPoint2.dx, controlPoint2.dy,
          p1.dx, p1.dy,
        );
      }
      canvas.drawPath(path, linePaint);
    }

    // Draw Points
    final pointPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (final point in points) {
      canvas.drawCircle(point, 5, pointPaint);
      canvas.drawCircle(point, 5, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DeficitLineChartPainter oldDelegate) {
    return true; 
  }
}
