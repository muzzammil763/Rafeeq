import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qiblah_advanced/flutter_qiblah_advanced.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/core/navigation/analytics_screen_names.dart';
import 'package:rafeeq/data/models/user_location.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';
import 'package:rafeeq/ui/app_home/home/location_screen.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:rafeeq/ui/prayer_times/user_location_notifier.dart';
import 'package:rafeeq/ui/quran/quran_audio_controller.dart';
import 'package:rafeeq/ui/quran/quran_player_layout.dart';
import 'package:rafeeq/ui/qibla/qibla_compass.dart';
import 'package:rafeeq/ui/widgets/rafeeq_app_bar.dart';
import 'package:rafeeq/utils/localized_font.dart';

final compassSupportedProvider = FutureProvider<bool?>(
  (ref) => FlutterQiblah.androidDeviceSensorSupport(),
);

class QiblaScreen extends ConsumerWidget {
  const QiblaScreen({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = SettingsPalette.of(context);
    final location = ref.watch(userLocationNotifierProvider);
    final compassEnabled = ref.watch(compassSupportedProvider);
    final playerVisible = ref.watch(
      quranAudioControllerProvider.select((state) => state.isVisible),
    );

    void _openLocation(BuildContext context) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          settings: const RouteSettings(name: AnalyticsScreenNames.location),
          builder: (context) => const LocationScreen(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: palette.background,
      appBar: RafeeqAppBar(
        title: context.loc.qibla,
        palette: palette,
        showBackButton: onBack != null,
        onBack: onBack,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _openLocation(context),
                child: _LocationSummary(location: location, palette: palette),
              ),
              Expanded(
                child: compassEnabled.when(
                  data: (enabled) => enabled == true
                      ? const QiblahCompass()
                      : _CompassUnavailable(palette: palette),
                  loading: () => Center(
                    child: CircularProgressIndicator(color: palette.accent),
                  ),
                  error: (error, stackTrace) =>
                      _CompassUnavailable(palette: palette),
                ),
              ),
              SizedBox(
                height: navigationScreenPlayerAwareBottomPadding(
                  playerVisible: playerVisible,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationSummary extends StatelessWidget {
  const _LocationSummary({required this.location, required this.palette});

  final UserLocation? location;
  final SettingsPalette palette;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.location, color: palette.title),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.loc.location,
                  style: TextStyle(
                    color: palette.title,
                    fontFamily: localizedFontFamily(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                MediaQuery.withNoTextScaling(
                  child: Text(
                    _locationLabel(context, location),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.subtitle,
                      fontFamily: 'GoogleSans',
                      fontSize: 14,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _locationLabel(BuildContext context, UserLocation? location) {
  if (location == null) return context.loc.locationNotSet;

  final place = [
    location.city?.trim(),
    location.country?.trim(),
  ].whereType<String>().where((part) => part.isNotEmpty).join(', ');

  if (place.isNotEmpty) return place;
  return '${location.latitude.toStringAsFixed(2)}, '
      '${location.longitude.toStringAsFixed(2)}';
}

class _CompassUnavailable extends StatelessWidget {
  const _CompassUnavailable({required this.palette});

  final SettingsPalette palette;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.explore_outlined,
              size: 56,
              color: palette.subtitle.withValues(alpha: 0.45),
            ),
            const SizedBox(height: 16),
            Text(
              context.loc.compassNotSupported,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.subtitle,
                fontFamily: localizedFontFamily(context),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
