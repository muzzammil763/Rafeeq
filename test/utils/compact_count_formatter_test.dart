import 'package:flutter_test/flutter_test.dart';
import 'package:rafeeq/utils/compact_count_formatter.dart';

void main() {
  test('formats engagement counts compactly', () {
    expect(formatCompactCount(999), '999');
    expect(formatCompactCount(1000), '1K');
    expect(formatCompactCount(1200), '1.2K');
    expect(formatCompactCount(100200), '100.2K');
    expect(formatCompactCount(1200000), '1.2M');
  });
}
