import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_core/domain/model/dashboard_summary.dart';

class SalesTrendChart extends StatelessWidget {
  const SalesTrendChart({super.key, required this.points});

  final List<SalesTrendPoint> points;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sales Trend',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Daily sales over the last 7 days',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 170,
              width: double.infinity,
              child: points.isEmpty
                  ? Center(
                      child: Text(
                        'No sales data available',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : CustomPaint(
                      painter: _SalesTrendPainter(
                        points: points,
                        lineColor: theme.colorScheme.primary,
                        gridColor: theme.colorScheme.outlineVariant,
                        labelColor: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SalesTrendPainter extends CustomPainter {
  _SalesTrendPainter({
    required this.points,
    required this.lineColor,
    required this.gridColor,
    required this.labelColor,
  });

  final List<SalesTrendPoint> points;
  final Color lineColor;
  final Color gridColor;
  final Color labelColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    const left = 48.0;
    const right = 8.0;
    const top = 12.0;
    const bottom = 28.0;

    final chartWidth = size.width - left - right;
    final chartHeight = size.height - top - bottom;
    final maxValue = points.fold<int>(
      0,
      (max, point) => math.max(max, point.amountCents),
    );
    final scaleMax = maxValue == 0 ? 1.0 : maxValue.toDouble();

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (var i = 0; i < 4; i++) {
      final y = top + chartHeight * i / 3;
      canvas.drawLine(
        Offset(left, y),
        Offset(size.width - right, y),
        gridPaint,
      );
    }

    for (var i = 0; i < 4; i++) {
      final value = scaleMax * (3 - i) / 3;
      final y = top + chartHeight * i / 3;

      final label = TextPainter(
        text: TextSpan(
          text: '\$${(value / 100).toStringAsFixed(0)}',
          style: TextStyle(color: labelColor, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();

      label.paint(canvas, Offset(0, y - label.height / 2));
    }

    final pointsOnChart = <Offset>[];

    for (var i = 0; i < points.length; i++) {
      final x = points.length == 1
          ? left + chartWidth / 2
          : left + chartWidth * i / (points.length - 1);
      final normalized = points[i].amountCents / scaleMax;
      final y = top + chartHeight - (normalized * chartHeight);

      pointsOnChart.add(Offset(x, y));

      final label = TextPainter(
        text: TextSpan(
          text: points[i].day,
          style: TextStyle(color: labelColor, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();

      label.paint(
        canvas,
        Offset(x - label.width / 2, size.height - label.height - 2),
      );
    }

    if (pointsOnChart.length > 1) {
      final path = Path()
        ..moveTo(pointsOnChart.first.dx, pointsOnChart.first.dy);

      for (var i = 1; i < pointsOnChart.length; i++) {
        final previous = pointsOnChart[i - 1];
        final current = pointsOnChart[i];
        final controlX = (previous.dx + current.dx) / 2;

        path.cubicTo(
          controlX,
          previous.dy,
          controlX,
          current.dy,
          current.dx,
          current.dy,
        );
      }

      final linePaint = Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(path, linePaint);
    }

    final dotPaint = Paint()..color = lineColor;
    final dotBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final point in pointsOnChart) {
      canvas.drawCircle(point, 4.5, dotPaint);
      canvas.drawCircle(point, 4.5, dotBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SalesTrendPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.labelColor != labelColor;
  }
}
