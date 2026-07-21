import 'package:flutter/material.dart';

class IncomeComboChart extends StatelessWidget {
  final List<double> values;
  final List<double>? lineValues;
  final List<String> labels;
  final Color barColor;
  final double maxValue;
  final double? maxLineValue;
  final String suffix;
  final VoidCallback? onEditClick;

  const IncomeComboChart({
    Key? key,
    required this.values,
    this.lineValues,
    required this.labels,
    this.barColor = const Color(0xFFC8E6C9),
    this.maxValue = 100.0,
    this.maxLineValue,
    this.suffix = 'k',
    this.onEditClick,
  }) : super(key: key);

  String formatValue(double value) {
    if (value >= 1000) {
      double kValue = value / 1000;
      return '${kValue.toStringAsFixed(kValue.truncateToDouble() == kValue ? 0 : 1)}k';
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
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, 6),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (onEditClick != null)
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                onPressed: onEditClick,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          AspectRatio(
            aspectRatio: 2.0,
            child: CustomPaint(
              painter: _ComboChartPainter(
                values: values,
                lineValues: lineValues ?? values,
                labels: labels,
                barColor: barColor,
                maxValue: maxValue > 0 ? maxValue : 1.0,
                maxLineValue: maxLineValue != null && maxLineValue! > 0
                    ? maxLineValue!
                    : (maxValue > 0 ? maxValue : 1.0),
                formatter: formatValue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComboChartPainter extends CustomPainter {
  final List<double> values;
  final List<double> lineValues;
  final List<String> labels;
  final Color barColor;
  final double maxValue;
  final double maxLineValue;
  final String Function(double) formatter;

  _ComboChartPainter({
    required this.values,
    required this.lineValues,
    required this.labels,
    required this.barColor,
    required this.maxValue,
    required this.maxLineValue,
    required this.formatter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final barPaint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;

    final barBorderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final linePaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeJoin = StrokeJoin.round;

    final dotPaintFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final dotPaintStroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final double barWidth = size.width / (values.length * 1.5);
    final double maxBarHeight =
        size.height * 0.65; // Leave room for labels below

    // Calculate points for the line graph
    List<Offset> points = [];

    for (int i = 0; i < values.length; i++) {
      final xCenter =
          (size.width / values.length) * i + (size.width / (values.length * 2));
      final double normalizedValue = values[i] / maxValue;
      final double barHeight = normalizedValue * maxBarHeight;

      final yTop = size.height * 0.8 - barHeight;
      final yBottom = size.height * 0.8;

      // 1. Draw Bar
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTRB(
          xCenter - barWidth / 2,
          yTop,
          xCenter + barWidth / 2,
          yBottom,
        ),
        const Radius.circular(6),
      );
      final barGradient = LinearGradient(
        colors: [barColor, barColor.withOpacity(0.5)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect.outerRect);
      canvas.drawRRect(rect, Paint()..shader = barGradient);

      // Calculate Line Point
      final lineVal = i < lineValues.length ? lineValues[i] : 0.0;
      final double normalizedLine = lineVal / maxLineValue;
      final double lineY = size.height * 0.8 - (normalizedLine * maxBarHeight);
      points.add(Offset(xCenter, lineY));

      // 2. Draw Label below bar (Month)
      textPainter.text = TextSpan(
        text: labels[i],
        style: const TextStyle(
          color: Colors.black54,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(xCenter - textPainter.width / 2, yBottom + 8),
      );

      // 3. Draw Inflow Value below Month
      textPainter.text = TextSpan(
        text: formatter(values[i]),
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(xCenter - textPainter.width / 2, yBottom + 24),
      );

      // Draw line value text
      if (lineVal > 0) {
        textPainter.text = TextSpan(
          text: lineVal.toStringAsFixed(0),
          style: const TextStyle(
            color: Colors.orange,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            xCenter - textPainter.width / 2,
            lineY - textPainter.height - 8,
          ),
        );
      }
    }

    // 4. Draw Smooth Line overlay
    if (points.length > 1) {
      final path = Path();
      path.moveTo(points[0].dx, points[0].dy);
      for (int i = 0; i < points.length - 1; i++) {
        final p1 = points[i + 1];
        path.lineTo(p1.dx, p1.dy);
      }
      canvas.drawShadow(path, Colors.orange.withOpacity(0.4), 4, true);
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.orange
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeJoin = StrokeJoin.round,
      );
    }

    // 5. Draw Dots on line
    final dotFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final dotStroke = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    for (var point in points) {
      canvas.drawCircle(point, 5, dotFill);
      canvas.drawCircle(point, 5, dotStroke);
    }
  }

  @override
  bool shouldRepaint(covariant _ComboChartPainter oldDelegate) {
    return true;
  }
}
