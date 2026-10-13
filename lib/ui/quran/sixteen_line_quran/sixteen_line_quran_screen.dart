import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/core/app_settings_notifier.dart';
import 'package:rafeeq/core/app_theme.dart';
import 'package:rafeeq/data/services/analytics_service.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';
import 'package:rafeeq/ui/quran/sixteen_line_quran/quran_juz_manager.dart';
import 'package:rafeeq/utils/juz_names_provider.dart';

class SixteenLineQuranScreen extends StatefulHookConsumerWidget {
  final int? juzNumber;
  final int startPage;

  const SixteenLineQuranScreen({super.key, this.juzNumber, this.startPage = 0});

  @override
  ConsumerState<SixteenLineQuranScreen> createState() =>
      _SixteenLineQuranScreenState();
}

class _SixteenLineQuranScreenState
    extends ConsumerState<SixteenLineQuranScreen> {
  List<String>? _imagePaths;
  int? _currentJuzNumber;
  int _currentPageIndex = 0;
  PageController? _pageController;

  @override
  void initState() {
    super.initState();
    _loadJuz();
  }

  Future<void> _loadJuz() async {
    int juzToLoad = widget.juzNumber ?? 1;

    final imagePaths = await ref
        .read(quranJuzManagerProvider.notifier)
        .getJuzImagePaths(juzToLoad);

    if (imagePaths != null && mounted) {
      setState(() {
        _currentJuzNumber = juzToLoad;
        _imagePaths = imagePaths;
        _currentPageIndex = widget.startPage.clamp(0, imagePaths.length - 1);
        _pageController = PageController(initialPage: _currentPageIndex);
      });
      ref.read(analyticsServiceProvider).logQuranJuzViewed(juzToLoad);
    } else if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsNotifierProvider);
    final themeOption =
        AppTheme.availableOptions.elementAtOrNull(settings.themeIndex) ??
        AppTheme.availableOptions[0];
    final colorScheme = Theme.of(context).colorScheme;
    final appSettings = ref.watch(appSettingsNotifierProvider);

    // Derive gradient colors from the theme
    final surfaceColor =
        themeOption.surfaceOverride ??
        ColorScheme.fromSeed(
          seedColor: themeOption.seedColor,
          brightness: Brightness.dark,
        ).surface;

    final secondaryColor =
        themeOption.secondaryOverride ?? themeOption.seedColor;

    final gradientDark = Color.lerp(surfaceColor, Colors.black, 0.4)!;
    final gradientMid = surfaceColor;
    final gradientLight = Color.lerp(surfaceColor, secondaryColor, 0.3)!;

    final juzName = _currentJuzNumber != null
        ? (appSettings.language == AppLanguage.ur
              ? JuzNamesProvider.getUrduName(_currentJuzNumber!)
              : JuzNamesProvider.getEnglishName(_currentJuzNumber!))
        : '';

    return Scaffold(
      backgroundColor: gradientDark,
      appBar: AppBar(
        title: _currentJuzNumber != null
            ? Text('${_currentJuzNumber.toString()}. $juzName')
            : Text(context.loc.sixteenLineQuran),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          if (_imagePaths != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  '${_currentPageIndex + 1}/${_imagePaths!.length}',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [gradientDark, gradientMid, gradientLight],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: _imagePaths != null && _pageController != null
              ? Directionality(
                  textDirection: ui.TextDirection.rtl,
                  child: PageView.builder(
                    controller: _pageController,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _imagePaths!.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return _buildImagePage(_imagePaths![index]);
                    },
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        'Loading Quran...',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 300.ms),
                ),
        ),
      ),
    );
  }

  Widget _buildImagePage(String imagePath) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(
        child: Image.file(
          File(imagePath),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 8),
                Text(
                  'Failed to load image',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
