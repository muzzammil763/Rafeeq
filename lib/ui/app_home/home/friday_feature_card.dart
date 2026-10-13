import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rafeeq/core/app_theme.dart';
import 'package:rafeeq/core/di_container.dart';
import 'package:rafeeq/core/navigation/app_routes.dart';
import 'package:rafeeq/data/providers/quran_data_provider.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';
import 'package:rafeeq/ui/quran/quran_details_screen.dart';
import 'package:rafeeq/ui/widgets/rafeeq_toast.dart';

class FridayFeatureCard extends HookConsumerWidget {
  final bool isPreview;

  const FridayFeatureCard({super.key, this.isPreview = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    if (!isPreview && now.weekday != DateTime.friday) {
      return const SizedBox.shrink();
    }

    final theme = context.mainTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final quranDataAsync = ref.watch(quranDataProvider);
    DateFormat('yyyy-MM-dd').format(now);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.secondaryColor, theme.primaryColor],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned(
              right: -16,
              top: -16,
              child: Icon(
                Icons.mosque_outlined,
                size: 200,
                color: Colors.white.withValues(alpha: 0.025),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.mosque_outlined,
                          size: 32,
                          color: colorScheme.onSecondary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            context.loc.fridayMubarak,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSecondary,
                                  fontSize: 18,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SunnahCarousel(colorScheme: colorScheme),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.onSecondary.withValues(
                                alpha: 0.08,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.loc.juz,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        fontSize: 10,
                                        color: colorScheme.onSecondary
                                            .withValues(alpha: 0.65),
                                      ),
                                ),
                                Text(
                                  '15-16',
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSecondary,
                                        fontFamily: 'GoogleSans',
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.onSecondary.withValues(
                                alpha: 0.08,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.loc.surah,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        fontSize: 10,
                                        color: colorScheme.onSecondary
                                            .withValues(alpha: 0.65),
                                      ),
                                ),
                                Text(
                                  '18 (110)',
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSecondary,
                                        fontFamily: 'GoogleSans',
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.onSecondary.withValues(
                                alpha: 0.08,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.loc.typeLabel,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        fontSize: 10,
                                        color: colorScheme.onSecondary
                                            .withValues(alpha: 0.65),
                                      ),
                                ),
                                Text(
                                  context.loc.meccan,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSecondary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (quranDataAsync.hasValue) {
                            final data = quranDataAsync.value!;
                            final surah = data.surah.firstWhere(
                              (s) => s.surahNumber == 18,
                            );

                            di.appRouter.pushNamed(
                              AppRoutes.quranDetails,
                              arguments: QuranDetailsArgs(
                                SurahQuranDetailArgs(surah, data.ayahs),
                              ),
                            );
                          } else {
                            showRafeeqToast(
                              context,
                              context.loc.errorLoadingQuranData,
                              type: RafeeqToastType.error,
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colorScheme.primary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: quranDataAsync.isLoading
                              ? Center(
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      strokeCap: StrokeCap.round,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    context.loc.readSurahKahf,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: colorScheme.onSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SunnahCarousel extends HookConsumerWidget {
  final ColorScheme colorScheme;

  const _SunnahCarousel({required this.colorScheme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageController = usePageController();
    final currentPage = useState(0);
    final isManuallyInteracting = useState(false);

    final sunnahItems = [
      _SunnahItemData(
        'ghusl',
        Icons.water_drop_outlined,
        context.loc.sunnahGhuslSubtitle,
      ),
      _SunnahItemData(
        'clothes',
        Icons.checkroom_outlined,
        context.loc.sunnahCleanClothesSubtitle,
      ),
      _SunnahItemData(
        'perfume',
        Icons.air_outlined,
        context.loc.sunnahPerfumeSubtitle,
      ),
      _SunnahItemData(
        'miswak',
        Icons.cleaning_services_outlined,
        context.loc.sunnahMiswakSubtitle,
      ),
      _SunnahItemData(
        'durood',
        Icons.favorite_border,
        context.loc.sunnahDuroodSubtitle,
      ),
    ];

    useEffect(() {
      Timer? timer;

      void startTimer() {
        timer?.cancel();
        timer = Timer.periodic(const Duration(seconds: 3), (_) {
          if (!isManuallyInteracting.value && pageController.hasClients) {
            final nextPage = currentPage.value + 1;
            pageController.animateToPage(
              nextPage,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        });
      }

      startTimer();

      return () => timer?.cancel();
    }, [isManuallyInteracting.value]);
    int getRealIndex(int index) {
      return index % sunnahItems.length;
    }

    return Column(
      children: [
        SizedBox(
          height: 80,
          child: PageView.builder(
            controller: pageController,
            onPageChanged: (index) {
              currentPage.value = index;
            },
            itemCount: 1000,
            itemBuilder: (context, index) {
              final realIndex = getRealIndex(index);
              final item = sunnahItems[realIndex];
              final label = _getLocalizedLabel(context, item.key);

              return GestureDetector(
                onTapDown: (_) => isManuallyInteracting.value = true,
                onTapCancel: () {
                  Future.delayed(const Duration(seconds: 5), () {
                    isManuallyInteracting.value = false;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _SunnahChip(
                    label: label,
                    subtitle: item.subtitle,
                    icon: item.icon,
                    onTap: () {},
                    colorScheme: colorScheme,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 6),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(sunnahItems.length, (index) {
            final realIndex = getRealIndex(currentPage.value);
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: realIndex == index ? 16 : 4,
              height: 4,
              decoration: BoxDecoration(
                color: realIndex == index
                    ? colorScheme.onSecondary
                    : colorScheme.onSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  String _getLocalizedLabel(BuildContext context, String key) {
    switch (key) {
      case 'ghusl':
        return context.loc.sunnahGhusl;
      case 'clothes':
        return context.loc.sunnahCleanClothes;
      case 'perfume':
        return context.loc.sunnahPerfume;
      case 'miswak':
        return context.loc.sunnahMiswak;
      case 'durood':
        return context.loc.sunnahDurood;
      default:
        return key;
    }
  }
}

class _SunnahItemData {
  final String key;
  final IconData icon;
  final String subtitle;

  const _SunnahItemData(this.key, this.icon, this.subtitle);
}

class _SunnahChip extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _SunnahChip({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: colorScheme.primary),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSecondary.withValues(alpha: 0.75),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
