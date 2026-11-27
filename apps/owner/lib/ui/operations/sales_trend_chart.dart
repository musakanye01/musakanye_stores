import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_core/theme/app_colors.dart';

class SalesTrendPoint {
  const SalesTrendPoint({required this.label, required this.valueCents});

  final String label;
  final int valueCents;
}

class SalesTrendChart extends StatelessWidget {
  const SalesTrendChart({super.key, required this.points});

  final List<SalesTrendPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox(height: 170);
    }

    return SizedBox(
      height: 170,
      width: double.infinity,
      child: CustomPaint(painter: _SalesTrendPainter(points: points)),
    );
  }
}

class _SalesTrendPainter extends CustomPainter {
  _SalesTrendPainter({required this.points});

  final List<SalesTrendPoint> points;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 8.0;
    const right = 8.0;
    const top = 12.0;
    const bottom = 28.0;

    final chartWidth = size.width - left - right;
    final chartHeight = size.height - top - bottom;

    if (chartWidth <= 0 || chartHeight <= 0) return;

    final maxValue = points.fold<int>(
      0,
      (current, point) => math.max(current, point.valueCents),
    );

    final scaleMax = maxValue == 0 ? 100 : maxValue * 1.15;

    final gridPaint = Paint()
      ..color = AppColors.outline
      ..strokeWidth = 1;

    for (var i = 0; i < 4; i++) {
      final y = top + chartHeight * i / 3;

      canvas.drawLine(
        Offset(left, y),
        Offset(size.width - right, y),
        gridPaint,
      );
    }

    final linePath = Path();
    final fillPath = Path();

    final offsets = <Offset>[];

    for (var i = 0; i < points.length; i++) {
      final x = points.length == 1
          ? left + chartWidth / 2
          : left + chartWidth * i / (points.length - 1);

      final normalized = points[i].valueCents / scaleMax;
      final y = top + chartHeight * (1 - normalized);

      offsets.add(Offset(x, y));

      if (i == 0) {
        linePath.moveTo(x, y);
        fillPath.moveTo(x, top + chartHeight);
        fillPath.lineTo(x, y);
      } else {
        linePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(offsets.last.dx, top + chartHeight);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary.withValues(alpha: 0.18),
          AppColors.primary.withValues(alpha: 0.01),
        ],
      ).createShader(Rect.fromLTWH(left, top, chartWidth, chartHeight));

    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(linePath, linePaint);

    final pointPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    for (final offset in offsets) {
      canvas.drawCircle(offset, 3, pointPaint);
    }

    final labelStyle = const TextStyle(
      color: AppColors.muted,
      fontSize: 10,
      fontWeight: FontWeight.w500,
    );

    for (var i = 0; i < points.length; i++) {
      final label = points[i].label;
      if (label.isEmpty) continue;

      final textPainter = TextPainter(
        text: TextSpan(text: label, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      final x = offsets[i].dx - textPainter.width / 2;

      textPainter.paint(
        canvas,
        Offset(x.clamp(0, size.width - textPainter.width), size.height - 17),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SalesTrendPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
