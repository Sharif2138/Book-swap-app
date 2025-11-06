import 'package:flutter/material.dart';

class BookIcon extends StatelessWidget {
  final double size;

  const BookIcon({super.key, this.size = 100});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 🟡 Golden outline (book cover shape)
          CustomPaint(size: Size(size, size), painter: _BookOutlinePainter()),

          // ⚪ White pages (two rounded rectangles)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Left page
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(size * 0.1),
                  bottomRight: Radius.circular(size * 0.05),
                ),
                child: Container(
                  width: size * 0.4,
                  height: size * 0.55,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: size * 0.05),
              // Right page
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(size * 0.1),
                  bottomLeft: Radius.circular(size * 0.05),
                ),
                child: Container(
                  width: size * 0.4,
                  height: size * 0.55,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 🎨 Custom painter draws the golden outline under the pages
class _BookOutlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          const Color(0xFFFBC02D) // golden yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    // Start from bottom left curve
    path.moveTo(size.width * 0.1, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.85, // curve center
      size.width * 0.9,
      size.height * 0.7, // bottom right
    );

    // Extend upward on both sides
    path.moveTo(size.width * 0.1, size.height * 0.7);
    path.lineTo(size.width * 0.1, size.height * 0.25);

    path.moveTo(size.width * 0.9, size.height * 0.7);
    path.lineTo(size.width * 0.9, size.height * 0.25);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
