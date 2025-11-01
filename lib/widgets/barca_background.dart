import 'package:flutter/material.dart';

class BarcaBackground extends StatelessWidget {
  const BarcaBackground({
    super.key,
    this.child,
    this.showPattern = true,
  });

  final Widget? child;
  final bool showPattern;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0B1C3A),
            Color(0xFF004D98),
            Color(0xFFA50044),
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (showPattern)
            Positioned.fill(
              child: Opacity(
                opacity: 0.12,
                child: CustomPaint(
                  painter: _StripedPatternPainter(),
                ),
              ),
            ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class _StripedPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stripePaint = Paint()
      ..color = const Color(0xFFEDBB00).withValues(alpha: 0.3)
      ..strokeWidth = 40
      ..style = PaintingStyle.stroke;

    final spacing = 160.0;
    for (double x = -size.height; x < size.width + size.height; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        stripePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
