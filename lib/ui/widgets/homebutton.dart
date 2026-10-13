import 'package:flutter/material.dart';
import 'package:rafeeq/core/app_theme.dart';

class HomeButton extends StatelessWidget {
  final String label;
  final Widget imgSrc;
  final Color? imageColor;
  final VoidCallback onTap;
  final Color bgColor;

  const HomeButton({
    super.key,
    required this.label,
    required this.imgSrc,
    this.imageColor,
    this.bgColor = Colors.green,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.mainTheme.primaryColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: SizedBox(height: 35, width: 35, child: imgSrc),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.limeAccent),
          ],
        ),
      ),
    );
  }
}
