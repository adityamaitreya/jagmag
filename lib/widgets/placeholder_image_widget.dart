import 'package:flutter/material.dart';

class PlaceholderImageWidget extends StatelessWidget {
  final String type;
  final double size;

  const PlaceholderImageWidget({super.key, required this.type, this.size = 50});

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color backgroundColor;
    Color iconColor;

    switch (type) {
      case 'streetlight':
        iconData = Icons.lightbulb;
        backgroundColor = Colors.orange[100]!;
        iconColor = Colors.orange[600]!;
        break;
      case 'pothole':
        iconData = Icons.construction;
        backgroundColor = Colors.brown[100]!;
        iconColor = Colors.brown[600]!;
        break;
      case 'water_leakage':
        iconData = Icons.water_drop;
        backgroundColor = Colors.blue[100]!;
        iconColor = Colors.blue[600]!;
        break;
      case 'garbage':
        iconData = Icons.delete;
        backgroundColor = Colors.red[100]!;
        iconColor = Colors.red[600]!;
        break;
      default:
        iconData = Icons.image;
        backgroundColor = Colors.grey[200]!;
        iconColor = Colors.grey[500]!;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: iconColor, size: size * 0.5),
    );
  }
}

