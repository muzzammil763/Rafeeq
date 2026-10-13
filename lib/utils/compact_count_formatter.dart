String formatCompactCount(int count) {
  if (count < 1000) return count.toString();
  if (count < 1000000) return _formatScaled(count / 1000, 'K');
  if (count < 1000000000) return _formatScaled(count / 1000000, 'M');
  return _formatScaled(count / 1000000000, 'B');
}

String _formatScaled(double value, String suffix) {
  final number = value.toStringAsFixed(1).replaceFirst(RegExp(r'\.0$'), '');
  return '$number$suffix';
}
