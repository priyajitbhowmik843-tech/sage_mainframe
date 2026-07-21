import 'package:flutter/material.dart';

class ForecastChart extends StatelessWidget {
  final List<double> expectedValues;
  final List<double> actualValues;
  final List<String> labels;
  final Color expectedColor;
  final Color actualColor;
  final double maxValue;
  final String suffix;

  const ForecastChart({
    Key? key,
    required this.expectedValues,
    required this.actualValues,
    required this.labels,
    this.expectedColor = const Color(0xFFE0E0E0),
    this.actualColor = const Color(0xFF81C784),
    this.maxValue = 100.0,
    this.suffix = 'k',
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
      child: AspectRatio(
        aspectRatio: 2.0,
        child: CustomPaint(
          painter: _ForecastChartPainter(
            expectedValues: expectedValues,
            actualValues: actualValues,
            labels: labels,
            expectedColor: expectedColor,
            actualColor: actualColor,
            maxValue: maxValue > 0 ? maxValue : 1.0,
            formatter: formatValue,
          ),
        ),
      ),
    );
  }
}

class _ForecastChartPainter extends CustomPainter {
  final List<double> expectedValues;
  final List<double> actualValues;
  final List<String> labels;
  final Color expectedColor;
  final Color actualColor;
  final double maxValue;
  final String Function(double) formatter;

  _ForecastChartPainter({
    required this.expectedValues,
    required this.actualValues,
    required this.labels,
    required this.expectedColor,
    required this.actualColor,
    required this.maxValue,
    required this.formatter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (expectedValues.isEmpty) return;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final double barWidth = size.width / (expectedValues.length * 1.5);
    final double maxBarHeight = size.height * 0.65;

    for (int i = 0; i < expectedValues.length; i++) {
      final xCenter =
          (size.width / expectedValues.length) * i +
          (size.width / (expectedValues.length * 2));

      // Expected Bar (Background)
      final double normalizedExpected = expectedValues[i] / maxValue;
      final double expectedBarHeight = normalizedExpected * maxBarHeight;
      final yTopExpected = size.height * 0.8 - expectedBarHeight;
      final yBottom = size.height * 0.8;

      final rectExpected = RRect.fromRectAndRadius(
        Rect.fromLTRB(
          xCenter - barWidth / 2,
          yTopExpected,
          xCenter + barWidth / 2,
          yBottom,
        ),
        const Radius.circular(6),
      );
      canvas.drawRRect(rectExpected, Paint()..color = expectedColor);

      // Actual Bar (Foreground)
      final double actualVal = i < actualValues.length ? actualValues[i] : 0.0;
      final double normalizedActual = actualVal / maxValue;
      final double actualBarHeight = normalizedActual * maxBarHeight;
      final yTopActual = size.height * 0.8 - actualBarHeight;

      if (actualBarHeight > 0) {
        final rectActual = RRect.fromRectAndRadius(
          Rect.fromLTRB(
            xCenter - barWidth / 2,
            yTopActual,
            xCenter + barWidth / 2,
            yBottom,
          ),
          const Radius.circular(6),
        );
        final barGradient = LinearGradient(
          colors: [actualColor, actualColor.withOpacity(0.7)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(rectActual.outerRect);
        canvas.drawRRect(rectActual, Paint()..shader = barGradient);
      }

      // Draw Label below bar (Month)
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

      final deficit = expectedValues[i] - actualVal;

      if (deficit > 0) {
        textPainter.text = TextSpan(
          text: '-' + formatter(deficit),
          style: const TextStyle(
            color: Colors.redAccent,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            xCenter - textPainter.width / 2,
            yTopExpected - textPainter.height - 4,
          ),
        );
      } else if (actualVal > 0) {
        textPainter.text = TextSpan(
          text: formatter(actualVal),
          style: const TextStyle(
            color: Colors.green,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            xCenter - textPainter.width / 2,
            yTopActual - textPainter.height - 4,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ForecastChartPainter oldDelegate) {
    return true;
  }
}
