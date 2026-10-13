import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';
import 'package:rafeeq/core/app_theme.dart';
import 'package:rafeeq/core/navigation/analytics_screen_names.dart';
import 'package:rafeeq/data/services/app_update_service.dart';
import 'package:rafeeq/data/services/analytics_service.dart';
import 'package:rafeeq/data/providers/shared_prefs_provider.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';
import 'package:rafeeq/ui/widgets/cancel_button.dart';
import 'package:rafeeq/ui/app_home/home/rafeeq_bottom_navigation_bar.dart';
import 'package:rafeeq/ui/app_home/home/settings_screen.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:rafeeq/ui/common/app_info_dialog.dart';
import 'package:rafeeq/utils/localized_font.dart';

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
  static const _redesignReleaseKey = 'redesign_dialog_seen_1_2_18';
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
        _showRedesignDialog();
      }
    });
  }

  Future<void> _showRedesignDialog() async {
    if (!mounted) return;
    final preferences = ref.read(sharedPreferencesProvider);
    if (preferences.getBool(_redesignReleaseKey) ?? false) return;
    await preferences.setBool(_redesignReleaseKey, true);
    if (!mounted) return;
    showRafeeqRedesignSheet(context);
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

Future<void> showRafeeqRedesignSheet(BuildContext context) =>
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, animation, secondaryAnimation) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: DraggableScrollableSheet(
            initialChildSize: .8,
            minChildSize: .55,
            maxChildSize: 1,
            expand: true,
            shouldCloseOnMinExtent: false,
            builder: (context, controller) => _RedesignReleaseSheet(
              scrollController: controller,
              onClose: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) =>
          SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          ),
    );

class _RedesignReleaseSheet extends StatefulWidget {
  const _RedesignReleaseSheet({
    required this.onClose,
    required this.scrollController,
  });

  final VoidCallback onClose;
  final ScrollController scrollController;

  @override
  State<_RedesignReleaseSheet> createState() => _RedesignReleaseSheetState();
}

class _RedesignReleaseSheetState extends State<_RedesignReleaseSheet> {
  static const _oldHomeUrl =
      'https://res.cloudinary.com/djzvkqwvx/image/upload/v1788515295/ohn1gnx840qimspovupd.png';
  static const _newHomeUrl =
      'https://res.cloudinary.com/djzvkqwvx/image/upload/v1788515301/rp10utf2hebln84c7zeo.png';
  static const _oldQiblaUrl =
      'https://res.cloudinary.com/djzvkqwvx/image/upload/v1788516086/WhatsApp_Image_2026-09-02_at_14.19.50_2_awmdo2.jpg';
  static const _newQiblaUrl =
      'https://res.cloudinary.com/djzvkqwvx/image/upload/v1788516072/WhatsApp_Image_2026-09-02_at_14.19.42_1_bfzof7.jpg';
  static const _oldQuranUrl =
      'https://res.cloudinary.com/djzvkqwvx/image/upload/v1788516085/WhatsApp_Image_2026-09-02_at_14.19.49_ihalv6.jpg';
  static const _newQuranUrl =
      'https://res.cloudinary.com/djzvkqwvx/image/upload/v1788516079/WhatsApp_Image_2026-09-02_at_14.19.47_npphu2.jpg';
  static const _oldListUrl =
      'https://res.cloudinary.com/djzvkqwvx/image/upload/v1788516087/WhatsApp_Image_2026-09-02_at_14.19.50_b7mbag.jpg';
  static const _newListUrl =
      'https://res.cloudinary.com/djzvkqwvx/image/upload/v1788516079/WhatsApp_Image_2026-09-02_at_14.19.47_2_chf3j3.jpg';
  static const _ayahUrl =
      'https://res.cloudinary.com/djzvkqwvx/image/upload/v1788516072/WhatsApp_Image_2026-09-02_at_14.19.41_lrfkta.jpg';
  static const _extendedHomeUrl =
      'https://res.cloudinary.com/djzvkqwvx/image/upload/v1788516073/WhatsApp_Image_2026-09-02_at_14.19.47_1_qabbj1.jpg';
  static const _adaptiveThemeUrl =
      'https://res.cloudinary.com/djzvkqwvx/image/upload/v1788516082/WhatsApp_Image_2026-09-02_at_14.19.48_turpkg.jpg';

  @override
  Widget build(BuildContext context) {
    final palette = SettingsPalette.of(context);
    return PopScope(
      canPop: true,
      child: Material(
        color: palette.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: widget.scrollController,
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 28),
                  Text(
                    context.loc.redesignDialogTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: palette.title,
                      fontFamily: localizedFontFamily(context),
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.loc.redesignDialogBody,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: palette.subtitle,
                      fontFamily: localizedFontFamily(context),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _comparison(
                    context.loc.redesignHomeScreen,
                    _oldHomeUrl,
                    _newHomeUrl,
                    palette,
                  ),
                  _comparison(
                    context.loc.redesignQiblaScreen,
                    _oldQiblaUrl,
                    _newQiblaUrl,
                    palette,
                  ),
                  _comparison(
                    context.loc.redesignQuranView,
                    _oldQuranUrl,
                    _newQuranUrl,
                    palette,
                  ),
                  _comparison(
                    context.loc.redesignSurahJuzList,
                    _oldListUrl,
                    _newListUrl,
                    palette,
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      context.loc.redesignNewFeatures,
                      style: TextStyle(
                        color: palette.title,
                        fontFamily: localizedFontFamily(context),
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _feature(
                    context.loc.redesignAyahMaker,
                    context.loc.redesignAyahMakerDescription,
                    _ayahUrl,
                    palette,
                  ),
                  _feature(
                    context.loc.redesignExtendedHome,
                    context.loc.redesignExtendedHomeDescription,
                    _extendedHomeUrl,
                    palette,
                  ),
                  _feature(
                    context.loc.redesignAdaptiveTheme,
                    context.loc.redesignAdaptiveThemeDescription,
                    _adaptiveThemeUrl,
                    palette,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: widget.onClose,
                      child: Text(context.loc.gotIt),
                    ),
                  ),
                ],
              ),
            ),
            PositionedDirectional(
              top: 8,
              end: 8,
              child: IconButton.filledTonal(
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                onPressed: widget.onClose,
                icon: const Icon(Icons.close_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _comparison(
    String title,
    String oldUrl,
    String newUrl,
    SettingsPalette palette,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: palette.title,
              fontFamily: localizedFontFamily(context),
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _networkImage(oldUrl)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward_rounded, color: palette.accent),
              ),
              Expanded(child: _networkImage(newUrl)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _feature(
    String title,
    String description,
    String url,
    SettingsPalette palette,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: palette.title,
                    fontFamily: localizedFontFamily(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    color: palette.subtitle,
                    fontFamily: localizedFontFamily(context),
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(width: 112, child: _networkImage(url)),
        ],
      ),
    );
  }

  Widget _networkImage(String url) {
    final palette = SettingsPalette.of(context);
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: palette.subtitle.withValues(alpha: .45),
          width: 1.25,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: CachedNetworkImage(
        imageUrl: url,
        width: double.infinity,
        fit: BoxFit.fitWidth,
        color: palette.background,
        colorBlendMode: BlendMode.dstOver,
        placeholder: (context, url) => const SizedBox(
          height: 180,
          child: Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => SizedBox(
          height: 180,
          child: Center(child: Text(context.loc.imageLoadError)),
        ),
      ),
    );
  }
}
