import 'package:flutter/material.dart';

class JagmagLogo extends StatelessWidget {
  final double size;
  final Color? color;

  const JagmagLogo({
    super.key,
    this.size = 100,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Streetlight icon (J)
            Icon(
              Icons.lightbulb,
              color: Colors.orange[400],
              size: size * 0.3,
            ),
            const SizedBox(height: 4),
            // Text "JAGMAG"
            Text(
              'JAGMAG',
              style: TextStyle(
                fontSize: size * 0.15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
