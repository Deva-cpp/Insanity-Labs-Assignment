import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  final double size;
  final bool center;

  const Loader({
    super.key,
    this.size = 26,
    this.center = false,
  });

  @override
  Widget build(BuildContext context) {
    final indicator = SizedBox(
      height: size,
      width: size,
      child: const CircularProgressIndicator(strokeWidth: 2.2),
    );

    if (center) {
      return Center(child: indicator);
    }

    return indicator;
  }
}
