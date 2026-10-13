import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';

class RafeeqBottomNavigationBar extends StatelessWidget {
  const RafeeqBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.labels,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    assert(labels.length == 4, 'Four navigation labels are required.');
    final useLightStyle = Theme.of(context).brightness == Brightness.light;
    const lightForeground = Color(0xFF425553);
    const lightSelected = Color(0xFF125E5C);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: useLightStyle
                  ? const [Color(0xF7FFFEFA), Color(0xFFFFFEFA)]
                  : [
                      Colors.black.withValues(alpha: 0.32),
                      Colors.black.withValues(alpha: 0.58),
                    ],
            ),
            border: Border(
              top: BorderSide(
                color: useLightStyle
                    ? const Color(0xFFF2EEE5)
                    : Colors.white.withValues(alpha: 0.14),
                width: 0.7,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                backgroundColor: Colors.transparent,
                elevation: 0,
                height: 68,
                indicatorColor: useLightStyle
                    ? lightSelected.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.16),
                indicatorShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                iconTheme: WidgetStateProperty.resolveWith((states) {
                  return IconThemeData(
                    color: states.contains(WidgetState.selected)
                        ? (useLightStyle ? lightSelected : Colors.white)
                        : (useLightStyle
                              ? lightForeground
                              : Colors.white.withValues(alpha: 0.68)),
                    size: 27,
                    shadows: useLightStyle
                        ? const []
                        : const [Shadow(color: Colors.black54, blurRadius: 8)],
                  );
                }),
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  return TextStyle(
                    color: states.contains(WidgetState.selected)
                        ? (useLightStyle ? lightSelected : Colors.white)
                        : (useLightStyle
                              ? lightForeground
                              : Colors.white.withValues(alpha: 0.68)),
                    fontSize: 12,
                    fontWeight: states.contains(WidgetState.selected)
                        ? FontWeight.w700
                        : FontWeight.w500,
                    shadows: useLightStyle
                        ? const []
                        : const [Shadow(color: Colors.black54, blurRadius: 6)],
                  );
                }),
              ),
              child: NavigationBar(
                selectedIndex: currentIndex,
                onDestinationSelected: onDestinationSelected,
                destinations: [
                  NavigationDestination(
                    icon: const Icon(CupertinoIcons.home),
                    selectedIcon: const Icon(CupertinoIcons.house_fill),
                    label: labels[0],
                  ),
                  NavigationDestination(
                    icon: const Icon(FlutterIslamicIcons.quran2),
                    selectedIcon: const Icon(FlutterIslamicIcons.solidQuran2),
                    label: labels[1],
                  ),
                  NavigationDestination(
                    icon: const Icon(FlutterIslamicIcons.qibla2),
                    selectedIcon: const Icon(FlutterIslamicIcons.solidQibla2),
                    label: labels[2],
                  ),
                  NavigationDestination(
                    icon: const Icon(CupertinoIcons.settings),
                    selectedIcon: const Icon(CupertinoIcons.settings_solid),
                    label: labels[3],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

@Preview(name: 'Rafeeq bottom navigation', group: 'Navigation')
Widget rafeeqBottomNavigationBarPreview() {
  return MaterialApp(
    theme: ThemeData.dark(useMaterial3: true),
    home: Scaffold(
      extendBody: true,
      body: const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF12372A), Color(0xFF071A13)],
          ),
        ),
        child: SizedBox.expand(),
      ),
      bottomNavigationBar: RafeeqBottomNavigationBar(
        currentIndex: 0,
        onDestinationSelected: (_) {},
        labels: const ['Rafeeq', "Qur'an", 'Qibla', 'Settings'],
      ),
    ),
  );
}
