import 'package:flutter/material.dart';

class BuildGradientBg extends StatelessWidget {
  const BuildGradientBg({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // ignore: prefer_const_constructors
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
    );
  }
}
