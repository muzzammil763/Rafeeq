import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';
import 'package:rafeeq/core/app_theme.dart';
import 'package:rafeeq/core/navigation/analytics_screen_names.dart';
import 'package:rafeeq/data/services/app_update_service.dart';
import 'package:rafeeq/data/services/analytics_service.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';
import 'package:rafeeq/ui/widgets/cancel_button.dart';
import 'package:rafeeq/ui/app_home/home/rafeeq_bottom_navigation_bar.dart';
import 'package:rafeeq/ui/app_home/home/settings_screen.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:rafeeq/ui/common/app_info_dialog.dart';

import '../../qibla/qibla_screen.dart';
import '../../quran/read_quran_home_screen.dart';
import '../../quran/quran_audio_controller.dart';
import '../../quran/quran_player_overlay.dart';
import 'home_screen.dart';

final homeNavigationIndexProvider = StateProvider<int>((ref) => 0);

class AppHomeScreen extends ConsumerStatefulWidget {
  const AppHomeScreen({super.key});

  @override
  ConsumerState<AppHomeScreen> createState() {
    return _AppHomeScreenState();
  }
}

class _AppHomeScreenState extends ConsumerState<AppHomeScreen> {
  static const _navigationScreenNames = <String>[
    AnalyticsScreenNames.home,
    AnalyticsScreenNames.quran,
    AnalyticsScreenNames.qibla,
    AnalyticsScreenNames.settings,
  ];

  @override
  void initState() {
    super.initState();
    // Check for updates after the first frame to ensure context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        AppUpdateService.checkForUpdate(context);
      }
    });
  }

  void _showExitConfirmation(BuildContext context) {
    final theme = context.mainTheme;
    final colorScheme = Theme.of(context).colorScheme;
    AppInfoDialog.show(
      context,
      title: context.loc.exitApp,
      iconAsset: "assets/logo.svg",
      gradientColors: [theme.secondaryColor, theme.primaryColor],
      contentWidgets: [
        Center(
          child: Text(
            context.loc.exitAppConfirmation,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: SettingsPalette.of(context).title,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(child: CancelButton()),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => SystemNavigator.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SettingsPalette.of(context).accent,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  context.loc.exit,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _selectDestination(int index) {
    final currentIndex = ref.read(homeNavigationIndexProvider);
    if (currentIndex == index) return;

    ref.read(homeNavigationIndexProvider.notifier).state = index;
    ref
        .read(analyticsServiceProvider)
        .logScreenView(_navigationScreenNames[index]);
  }

  @override
  Widget build(BuildContext context) {
    final currentPageIndex = ref.watch(homeNavigationIndexProvider);
    final showQuranPlayer = ref.watch(
      quranAudioControllerProvider.select((state) => state.isVisible),
    );
    final iconBrightness = Theme.of(context).brightness == Brightness.light
        ? Brightness.dark
        : Brightness.light;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (currentPageIndex == 0) {
          _showExitConfirmation(context);
        } else {
          _selectDestination(0);
        }
      },
      child: AnnotatedRegion(
        value: SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.transparent,
          statusBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: iconBrightness,
          statusBarIconBrightness: iconBrightness,
        ),
        child: Scaffold(
          extendBody: !showQuranPlayer,
          body: IndexedStack(
            index: currentPageIndex,
            children: [
              const HomeScreen(),
              ReadQuranHomeScreen(onBack: () => _selectDestination(0)),
              QiblaScreen(onBack: () => _selectDestination(0)),
              SettingsScreen(onBack: () => _selectDestination(0)),
            ],
          ),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showQuranPlayer) const QuranMiniPlayer(),
              RafeeqBottomNavigationBar(
                currentIndex: currentPageIndex,
                onDestinationSelected: _selectDestination,
                labels: [
                  context.loc.appTitle,
                  context.loc.quran,
                  context.loc.qibla,
                  context.loc.settings,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
