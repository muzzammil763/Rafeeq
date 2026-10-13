import 'package:flutter/widgets.dart';

const urduFontFamily = 'Jameel Noori Nastaleeq';
const latinFontFamily = 'GoogleSans';

String localizedFontFamily(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'ur'
    ? urduFontFamily
    : latinFontFamily;
