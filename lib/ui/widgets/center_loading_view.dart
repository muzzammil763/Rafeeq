import 'package:flutter/material.dart';

class CenterLoadingView extends StatelessWidget {
  const CenterLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: Colors.limeAccent),
    );
  }
}
