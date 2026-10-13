import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/core/app_settings_notifier.dart';
import 'package:rafeeq/core/app_theme.dart';
import 'package:rafeeq/core/di_container.dart';
import 'package:rafeeq/core/navigation/app_routes.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';
import 'package:rafeeq/ui/common/app_info_dialog.dart';
import 'package:rafeeq/ui/quran/sixteen_line_quran/quran_juz_manager.dart';
import 'package:rafeeq/ui/quran/sixteen_line_quran/quran_pages_config.dart';
import 'package:rafeeq/ui/widgets/build_gradient_bg.dart';
import 'package:rafeeq/ui/widgets/rafeeq_toast.dart';
import 'package:rafeeq/utils/juz_names_provider.dart';

enum JuzPosition { start, quarter, half, threeQuarters }

class QuranJuzIndexScreen extends HookConsumerWidget {
  const QuranJuzIndexScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.mainTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final juzManager = ref.watch(quranJuzManagerProvider);
    final appSettings = ref.watch(appSettingsNotifierProvider);

    // Check file existence on mount
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(quranJuzManagerProvider.notifier).checkAllJuzFiles();
      });
      return null;
    }, const []);

    // Get start page for each juz from config
    final getJuzStartPage = QuranPagesConfig.getJuzStartPage;

    return Scaffold(
      backgroundColor: theme.bgColor,
      appBar: AppBar(
        title: Text(context.loc.sixteenLineQuran),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          // Build appropriate action based on download state
          _buildAppBarAction(context, ref, juzManager, theme, colorScheme),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const Positioned.fill(child: BuildGradientBg()),
          SafeArea(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 32),
              itemCount: 30,
              itemBuilder: (context, index) {
                final juzNumber = index + 1;
                final status =
                    juzManager[juzNumber] ?? const JuzDownloadStatus();
                final pageNumber = getJuzStartPage(juzNumber);
                final isDownloaded = status.isDownloaded;

                // Get localized name based on language
                final localizedName = appSettings.language == AppLanguage.ur
                    ? JuzNamesProvider.getUrduName(juzNumber)
                    : JuzNamesProvider.getEnglishName(juzNumber);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        if (isDownloaded) {
                          _showJuzPositionSheet(
                            context,
                            ref,
                            juzNumber,
                            theme,
                            colorScheme,
                          );
                        } else {
                          showRafeeqToast(
                            context,
                            '${JuzNamesProvider.getEnglishName(juzNumber)} is not downloaded. Download it from the top button.',
                            type: RafeeqToastType.warning,
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [theme.primaryColor, theme.secondaryColor],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.textColor.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Juz number uses the app's English font.
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: theme.secondaryColor.withValues(
                                  alpha: 0.4,
                                ),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                juzNumber.toString(),
                                style: TextStyle(
                                  color: theme.textColor,
                                  fontFamily: 'GoogleSans',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Juz Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Localized Juz Name
                                  Text(
                                    localizedName,
                                    style: TextStyle(
                                      color: colorScheme.onSecondary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  // Page Count (only show if downloaded)
                                  if (isDownloaded) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      '#$pageNumber',
                                      style: TextStyle(
                                        color: colorScheme.onSecondary
                                            .withValues(alpha: 0.6),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            // Always show Arabic Juz name in trailing (full opacity for all)
                            Text(
                              JuzNamesProvider.getArabicName(juzNumber),
                              style: TextStyle(
                                fontFamily: 'Muhammadi Uthmanic',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDownloaded
                                    ? colorScheme.primary
                                    : colorScheme.onSecondary.withValues(
                                        alpha: 0.6,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDownloadAllSheet(
    BuildContext context,
    WidgetRef ref,
    RafeeqTheme theme,
    ColorScheme colorScheme,
  ) {
    AppInfoDialog.show(
      context,
      title: 'Download All Quran Pages',
      iconAsset: 'assets/logo.svg',
      gradientColors: [theme.secondaryColor, theme.primaryColor],
      contentWidgets: [
        _DownloadAllContent(theme: theme, colorScheme: colorScheme),
      ],
    );
  }

  void _showJuzPositionSheet(
    BuildContext context,
    WidgetRef ref,
    int juzNumber,
    RafeeqTheme theme,
    ColorScheme colorScheme,
  ) {
    AppInfoDialog.show(
      context,
      title: JuzNamesProvider.getEnglishName(juzNumber),
      iconAsset: 'assets/logo.svg',
      gradientColors: [theme.secondaryColor, theme.primaryColor],
      contentWidgets: [
        _JuzPositionContent(
          juzNumber: juzNumber,
          theme: theme,
          colorScheme: colorScheme,
          onRead: (position) {
            Navigator.of(context).pop();
            _openJuz(context, ref, juzNumber, position);
          },
        ),
      ],
    );
  }

  void _openJuz(
    BuildContext context,
    WidgetRef ref,
    int juzNumber,
    JuzPosition position,
  ) {
    // Get position pages for this juz
    final positionPages = QuranPagesConfig.getJuzPositionPages(juzNumber);
    int startPageIndex = 0;

    switch (position) {
      case JuzPosition.start:
        // Already 0
        break;
      case JuzPosition.quarter:
        // Find the index of the quarter page
        final quarterPage = positionPages['quarter'];
        if (quarterPage != null) {
          startPageIndex =
              quarterPage - QuranPagesConfig.getJuzStartPage(juzNumber);
        }
        break;
      case JuzPosition.half:
        final halfPage = positionPages['half'];
        if (halfPage != null) {
          startPageIndex =
              halfPage - QuranPagesConfig.getJuzStartPage(juzNumber);
        }
        break;
      case JuzPosition.threeQuarters:
        final threeQPage = positionPages['threeQuarters'];
        if (threeQPage != null) {
          startPageIndex =
              threeQPage - QuranPagesConfig.getJuzStartPage(juzNumber);
        }
        break;
    }

    di.appRouter.pushNamed(
      AppRoutes.sixteenLineQuran,
      arguments: {'juzNumber': juzNumber, 'startPage': startPageIndex},
    );
  }

  Widget _buildAppBarAction(
    BuildContext context,
    WidgetRef ref,
    Map<int, JuzDownloadStatus> juzManager,
    RafeeqTheme theme,
    ColorScheme colorScheme,
  ) {
    // Calculate download state from Juz states
    final allDownloaded = juzManager.values.every(
      (status) => status.isDownloaded,
    );

    // Check if any Juz is currently downloading
    final isDownloading = juzManager.values.any(
      (status) => status.isDownloading,
    );

    // Calculate overall progress using downloadedPages for smooth updates
    final totalPages = juzManager.values.fold<int>(
      0,
      (sum, status) => sum + status.totalPages,
    );
    final downloadedPages = juzManager.values.fold<int>(
      0,
      (sum, status) => sum + status.downloadedPages,
    );
    final overallProgress = totalPages > 0 ? downloadedPages / totalPages : 0.0;

    // Check if there's partial progress (some pages downloaded but not all)
    final hasPartialProgress =
        downloadedPages > 0 && downloadedPages < totalPages;

    // If all downloaded, hide the button
    if (allDownloaded) {
      return const SizedBox.shrink();
    }

    // Otherwise show download button/progress
    return GestureDetector(
      onTap: () => _showDownloadAllSheet(context, ref, theme, colorScheme),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: isDownloading
                ? LinearGradient(
                    colors: [
                      colorScheme.primary.withValues(alpha: 0.3),
                      colorScheme.secondary.withValues(alpha: 0.3),
                    ],
                  )
                : null,
            color: isDownloading
                ? null
                : theme.primaryColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.3),
            ),
            boxShadow: isDownloading
                ? [
                    BoxShadow(
                      color: theme.primaryColor.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isDownloading) ...[
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    value: overallProgress,
                    strokeWidth: 2,
                    strokeCap: StrokeCap.round,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.primary,
                    ),
                    backgroundColor: colorScheme.primary.withValues(
                      alpha: 0.15,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(overallProgress * 100).toInt()}%',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'GoogleSans',
                  ),
                ),
              ] else ...[
                Icon(
                  hasPartialProgress
                      ? CupertinoIcons.arrow_clockwise
                      : CupertinoIcons.cloud_download,
                  color: colorScheme.primary,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  hasPartialProgress ? 'Resume' : 'Download',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DownloadAllContent extends ConsumerStatefulWidget {
  final RafeeqTheme theme;
  final ColorScheme colorScheme;

  const _DownloadAllContent({required this.theme, required this.colorScheme});

  @override
  ConsumerState<_DownloadAllContent> createState() =>
      _DownloadAllContentState();
}

class _DownloadAllContentState extends ConsumerState<_DownloadAllContent> {
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    // Check download state on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final juzManager = ref.read(quranJuzManagerProvider);
      final isDownloading = juzManager.values.any(
        (status) => status.isDownloading,
      );

      // Calculate if there's partial progress
      final totalPages = juzManager.values.fold<int>(
        0,
        (sum, status) => sum + status.totalPages,
      );
      final downloadedPages = juzManager.values.fold<int>(
        0,
        (sum, status) => sum + status.downloadedPages,
      );
      final hasPartialProgress =
          downloadedPages > 0 && downloadedPages < totalPages;

      if (mounted && (isDownloading || hasPartialProgress)) {
        setState(() {
          _isDownloading = isDownloading;
        });
      }
    });
  }

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
    });

    // Start the download - progress is tracked via provider
    await ref.read(quranJuzManagerProvider.notifier).downloadAllJuz();
  }

  @override
  Widget build(BuildContext context) {
    // Watch Juz manager state for real-time updates
    final juzManager = ref.watch(quranJuzManagerProvider);

    // Calculate download state from Juz states using downloadedPages for smooth progress
    final isDownloading = juzManager.values.any(
      (status) => status.isDownloading,
    );
    final totalPages = juzManager.values.fold<int>(
      0,
      (sum, status) => sum + status.totalPages,
    );
    final downloadedPages = juzManager.values.fold<int>(
      0,
      (sum, status) => sum + status.downloadedPages,
    );
    final downloadedJuz = juzManager.values
        .where((status) => status.isDownloaded)
        .length;

    // Check if there's partial progress (some pages downloaded but not all)
    final hasPartialProgress =
        downloadedPages > 0 && downloadedPages < totalPages;
    final isActuallyDownloading = isDownloading || _isDownloading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Description
        Text(
          'Download all 30 Juz (548 pages) for offline reading',
          style: TextStyle(
            fontSize: 14,
            color: widget.colorScheme.onSecondary.withValues(alpha: 0.75),
          ),
        ),
        const SizedBox(height: 12),

        // Show progress if actively downloading OR if there's partial progress to resume
        if (isActuallyDownloading || hasPartialProgress) ...[
          // Overall Progress Section with gradient card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.colorScheme.primary.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Overall Progress',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: widget.colorScheme.onSecondary,
                      ),
                    ),
                    Text(
                      '${totalPages > 0 ? ((downloadedPages / totalPages) * 100).toInt() : 0}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: widget.colorScheme.primary,
                        fontFamily: 'GoogleSans',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Progress bar with glow effect
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: totalPages > 0 ? downloadedPages / totalPages : 0,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(32),
                      backgroundColor: widget.colorScheme.onSecondary
                          .withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                Text(
                  '$downloadedPages of $totalPages pages downloaded',
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.colorScheme.onSecondary.withValues(
                      alpha: 0.75,
                    ),
                  ),
                ),
                Text(
                  '$downloadedJuz of 30 Juz completed',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: widget.colorScheme.onSecondary.withValues(
                      alpha: 0.75,
                    ),
                  ),
                ),
                // Show Resume button when paused (has partial progress but not actively downloading)
                if (hasPartialProgress && !isActuallyDownloading) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _startDownload,
                      icon: Icon(
                        CupertinoIcons.arrow_clockwise,
                        size: 20,
                        color: widget.colorScheme.onPrimary,
                      ),
                      label: const Text(
                        'Resume Download',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.colorScheme.primary,
                        foregroundColor: widget.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 4,
                        shadowColor: widget.colorScheme.primary.withValues(
                          alpha: 0.4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ] else ...[
          // Fresh download state - Enhanced info card
          Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.colorScheme.primary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.cloud_download,
                      color: widget.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Download Complete Quran',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: widget.colorScheme.onSecondary,
                          ),
                        ),
                        Text(
                          '548 pages • ~200MB',
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.colorScheme.onSecondary.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: widget.colorScheme.onSecondary.withValues(
                      alpha: 0.25,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: widget.colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Make sure you have a stable internet connection before starting.',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: widget.colorScheme.onSecondary.withValues(
                            alpha: 0.75,
                          ),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Enhanced Download button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _startDownload,
              icon: Icon(
                hasPartialProgress
                    ? CupertinoIcons.arrow_clockwise
                    : CupertinoIcons.cloud_download,
                size: 20,
              ),
              label: Text(
                hasPartialProgress ? 'Resume Download' : 'Start Download',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.colorScheme.primary,
                foregroundColor: widget.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 4,
                shadowColor: widget.colorScheme.primary.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _JuzPositionContent extends StatefulWidget {
  final int juzNumber;
  final RafeeqTheme theme;
  final ColorScheme colorScheme;
  final Function(JuzPosition) onRead;

  const _JuzPositionContent({
    required this.juzNumber,
    required this.theme,
    required this.colorScheme,
    required this.onRead,
  });

  @override
  State<_JuzPositionContent> createState() => _JuzPositionContentState();
}

class _JuzPositionContentState extends State<_JuzPositionContent> {
  JuzPosition selectedPosition = JuzPosition.start;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select where to start reading:',
          style: TextStyle(
            fontSize: 14,
            color: widget.colorScheme.onSecondary.withValues(alpha: 0.75),
          ),
        ),
        const SizedBox(height: 12),
        _buildPositionOption(
          position: JuzPosition.start,
          label: 'START',
          arabicLabel: JuzNamesProvider.getUrduName(widget.juzNumber),
        ),
        const SizedBox(height: 12),
        _buildPositionOption(
          position: JuzPosition.quarter,
          label: 'QUARTER',
          arabicLabel: 'الربع',
        ),
        const SizedBox(height: 12),
        _buildPositionOption(
          position: JuzPosition.half,
          label: 'HALF',
          arabicLabel: 'النصف',
        ),
        const SizedBox(height: 12),
        _buildPositionOption(
          position: JuzPosition.threeQuarters,
          label: 'THIRD QUARTER',
          arabicLabel: 'الثلثة',
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: _isLoading
                ? null
                : () {
                    setState(() {
                      _isLoading = true;
                    });
                    widget.onRead(selectedPosition);
                  },
            // style: OutlinedButton.styleFrom(
            //   backgroundColor: widget.colorScheme.primary,
            //   foregroundColor: widget.colorScheme.onPrimary,
            //   padding: const EdgeInsets.symmetric(vertical: 16),
            //   shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(12),
            //   ),
            // ),
            child: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      strokeCap: StrokeCap.round,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.colorScheme.onSecondary,
                      ),
                    ),
                  )
                : Text(
                    'Read',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: widget.colorScheme.onSecondary,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildPositionOption({
    required JuzPosition position,
    required String label,
    required String arabicLabel,
  }) {
    final isSelected = selectedPosition == position;
    final primaryColor = widget.colorScheme.primary;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPosition = position;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : primaryColor.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : primaryColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              arabicLabel,
              style: TextStyle(
                fontFamily: 'Muhammadi Uthmanic',
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSecondary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
