import 'package:flutter/material.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';

class QuranReaderAppBarTitle extends StatelessWidget {
  const QuranReaderAppBarTitle({
    super.key,
    required this.title,
    required this.subtitle,
    required this.palette,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final SettingsPalette palette;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isUrdu = Localizations.localeOf(context).languageCode == 'ur';
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: palette.title,
            fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : 'GoogleSans',
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: palette.subtitle,
            fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : 'GoogleSans',
            fontSize: 12,
          ),
        ),
      ],
    );
    if (onTap == null) return content;
    return Semantics(
      button: true,
      label: 'Choose Quran section',
      child: InkWell(
        key: const ValueKey('quran_section_picker_action'),
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: content,
        ),
      ),
    );
  }
}
