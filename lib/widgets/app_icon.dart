import 'package:flutter/material.dart';

class AppIcon extends StatelessWidget {
  final String path;
  final double size;

  const AppIcon({
    super.key,
    required this.path,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}