import 'package:flutter/material.dart';

class JagmagLogo extends StatelessWidget {
  final double size;
  final Color? color;

  const JagmagLogo({super.key, this.size = 100, this.color});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/icons/jagmag_logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
