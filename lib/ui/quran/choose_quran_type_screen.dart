import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/core/di_container.dart';
import 'package:rafeeq/core/navigation/app_routes.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';
import 'package:rafeeq/data/providers/quran_data_provider.dart';
import 'package:rafeeq/ui/widgets/build_gradient_bg.dart';

class ChooseQuranTypeScreen extends HookConsumerWidget {
  const ChooseQuranTypeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahList = ref.watch(quranDataProvider).asData?.value.surah ?? [];
    return Scaffold(
      appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const Positioned.fill(child: BuildGradientBg()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Expanded(
                    child: _buildHomeScreen(
                      "https://i2.pickpik.com/photos/830/52/847/holy-quran-ramadan-holy-month-preview.jpg",
                      title: context.loc.read,
                      icon: FlutterIslamicIcons.quran,
                      onTap: () {
                        di.appRouter.pushNamed(AppRoutes.readQuranHome);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _buildHomeScreen(
                      "https://i1.sndcdn.com/artworks-mtHD3NsLXkJutzHd-Ib1X9g-t500x500.jpg",
                      title: context.loc.listen,
                      icon: Icons.headset,
                      onTap: () {
                        if (surahList.isEmpty) return;

                        di.appRouter.pushNamed(
                          AppRoutes.listenQuranHome,
                          arguments: ListenQuranArgs(surahList),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeScreen(
    String imageUrl, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Builder(
      builder: (context) {
        return GestureDetector(
          onTap: onTap,
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  width: double.infinity,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 80,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        fontSize: 32,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
