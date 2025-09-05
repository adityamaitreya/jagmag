import 'package:flutter/material.dart';

class JagmagLogo extends StatelessWidget {
  final double size;

  const JagmagLogo({super.key, required this.size});

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
