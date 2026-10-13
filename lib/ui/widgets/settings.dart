import 'package:flutter/material.dart';
import 'package:rafeeq/core/app_theme.dart';
import 'package:rafeeq/utils/extensions/iterable_ext.dart';

class SettingsList extends StatelessWidget {
  final List<SettingSection> sections;

  const SettingsList({super.key, required this.sections});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.only(
        bottom:
            MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight,
      ),
      children: <Widget>[
        ...sections,
      ].separatedBy(const SizedBox(height: 8)).toList(),
    );
  }
}

class SettingSection extends StatelessWidget {
  final String? title;
  final List<SettingTile> tiles;

  const SettingSection({super.key, this.title, required this.tiles});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 8),
        Text(
          title ?? "",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 16),
        ListView.separated(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return tiles[index];
          },
          itemCount: tiles.length,
          separatorBuilder: (BuildContext context, int index) {
            return const SizedBox(height: 8);
          },
        ),
      ],
    );
  }
}

class SettingTile extends StatelessWidget {
  final Widget child;

  const SettingTile({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      color: context.mainTheme.primaryColor,
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: child,
    );
  }
}
