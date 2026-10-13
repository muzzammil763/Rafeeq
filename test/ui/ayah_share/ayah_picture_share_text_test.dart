import 'package:flutter_test/flutter_test.dart';
import 'package:rafeeq/ui/app_home/home/settings_sheets.dart';
import 'package:rafeeq/ui/ayah_share/ayah_picture_share_text.dart';

void main() {
  test('includes the Rafeeq description and canonical installation link', () {
    final text = buildAyahPictureShareText();

    expect(
      text,
      contains(
        'Shared From Rafeeq - Muslim Companion, Islamic App For Muslims.',
      ),
    );
    expect(text, contains('You Can Also Install The App:'));
    expect(text, contains(playStoreUri.toString()));
  });
}
