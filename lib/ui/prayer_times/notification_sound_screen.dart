import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rafeeq/core/navigation/analytics_screen_names.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/core/app_theme.dart';
import 'package:rafeeq/data/services/notification_service.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';
import 'package:rafeeq/ui/prayer_times/prayer_times_settings.dart';

class NotificationSoundScreen extends ConsumerWidget {
  final PrayerNotifKey prayerKey;
  final String prayerName;

  const NotificationSoundScreen({
    super.key,
    required this.prayerKey,
    required this.prayerName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.mainTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final settings = ref.watch(prayerTimesSettingsNotifierProvider);
    final currentSound = settings.getSound(prayerKey);
    final isNotificationEnabled =
        settings.notificationSettings[prayerKey] ?? false;

    final currentVolumeType = settings.getVolumeType(prayerKey);

    void testNotification() {
      final service = ref.read(notificationServiceProvider);
      final assetPath = currentSound.getAssetPath();

      // Convert sound to appropriate format for notification service
      String? soundForNotification;
      String? volumeType;
      if (currentSound == NotificationSound.silent) {
        soundForNotification = null; // No sound
      } else if (currentSound == NotificationSound.default_) {
        soundForNotification = ''; // Empty string for default
      } else {
        soundForNotification = assetPath; // Custom sound path
        volumeType = currentVolumeType.name; // 'notification' or 'alarm'
      }

      service.showNotification(
        id: 9999,
        title: 'Test: $prayerName',
        body: 'Testing notification with ${currentSound.getLabel(context)}',
        soundAsset: soundForNotification,
        volumeType: volumeType,
      );
    }

    void toggleNotification(bool value) {
      ref
          .read(prayerTimesSettingsNotifierProvider.notifier)
          .toggleNotification(prayerKey);
    }

    // Get icon based on sound type
    Widget getSoundIcon(NotificationSound sound, double size) {
      switch (sound) {
        case NotificationSound.silent:
          return Icon(
            Icons.notifications_off,
            size: size,
            color: theme.textColor,
          );
        case NotificationSound.default_:
          return Icon(
            Icons.notifications_active,
            size: size,
            color: theme.textColor,
          );
        case NotificationSound.falahSound:
          return Icon(
            FlutterIslamicIcons.solidMosque,
            size: size,
            color: theme.textColor,
          );
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text('$prayerName ${context.loc.notification}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Selection Card with Audio Player
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [theme.primaryColor, theme.secondaryColor],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  getSoundIcon(currentSound, 32),
                  const SizedBox(height: 12),
                  Text(
                    context.loc.currentOption,
                    style: TextStyle(
                      color: theme.textColor.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currentSound.getLabel(context),
                    style: TextStyle(
                      color: theme.textColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isNotificationEnabled
                        ? Icons.notifications_active
                        : Icons.notifications_off,
                    color: isNotificationEnabled
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.loc.notificationEnabled,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          isNotificationEnabled
                              ? context.loc.notificationEnabledOn
                              : context.loc.notificationEnabledOff,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CupertinoSwitch(
                    value: isNotificationEnabled,
                    onChanged: toggleNotification,
                    activeTrackColor: Colors.green,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Text(
                context.loc.selectOption,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                children: _buildSoundOptions(
                  context,
                  ref,
                  currentSound,
                  colorScheme,
                ),
              ),
            ),
            // Volume Control - only show for custom sounds
            if (currentSound == NotificationSound.falahSound) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Text(
                  context.loc.volumeControl,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurfaceVariant,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  children: _buildVolumeOptions(
                    context,
                    ref,
                    currentVolumeType,
                    colorScheme,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            // Test Button (enabled for all options including silent)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                onPressed: isNotificationEnabled ? testNotification : null,
                icon: const Icon(Icons.bug_report_outlined),
                label: Text(context.loc.testNotification),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSoundOptions(
    BuildContext context,
    WidgetRef ref,
    NotificationSound currentSound,
    ColorScheme colorScheme,
  ) {
    final sounds = prayerKey.availableSounds;

    final result = <Widget>[];
    for (var i = 0; i < sounds.length; i++) {
      final sound = sounds[i];
      final isSelected = sound == currentSound;

      result.add(
        ListTile(
          leading: _getSoundIcon(sound, colorScheme, isSelected),
          title: Text(
            sound.getLabel(context),
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? colorScheme.primary : colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            _getSoundDescription(context, sound),
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          ),
          trailing: isSelected
              ? Icon(Icons.check_circle, color: colorScheme.primary)
              : Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurfaceVariant,
                  size: 16,
                ),
          onTap: () {
            ref
                .read(prayerTimesSettingsNotifierProvider.notifier)
                .setNotificationSound(prayerKey, sound);
          },
        ),
      );

      if (i < sounds.length - 1) {
        result.add(
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        );
      }
    }
    return result;
  }

  Widget _getSoundIcon(
    NotificationSound sound,
    ColorScheme colorScheme,
    bool isSelected,
  ) {
    final color = isSelected ? colorScheme.primary : colorScheme.onSecondary;
    switch (sound) {
      case NotificationSound.silent:
        return Icon(Icons.notifications_off, color: color);
      case NotificationSound.default_:
        return Icon(Icons.notifications_active, color: color);
      case NotificationSound.falahSound:
        return Icon(FlutterIslamicIcons.solidMosque, color: color);
    }
  }

  String _getSoundDescription(BuildContext context, NotificationSound sound) {
    switch (sound) {
      case NotificationSound.silent:
        return context.loc.soundSilentDesc;
      case NotificationSound.default_:
        return context.loc.soundDefaultDesc;
      case NotificationSound.falahSound:
        return context.loc.soundFalahDesc;
    }
  }

  List<Widget> _buildVolumeOptions(
    BuildContext context,
    WidgetRef ref,
    NotificationVolumeType currentVolumeType,
    ColorScheme colorScheme,
  ) {
    final volumeTypes = [
      NotificationVolumeType.notification,
      NotificationVolumeType.alarm,
    ];

    final result = <Widget>[];
    for (var i = 0; i < volumeTypes.length; i++) {
      final volumeType = volumeTypes[i];
      final isSelected = volumeType == currentVolumeType;

      result.add(
        ListTile(
          leading: _getVolumeIcon(volumeType, colorScheme, isSelected),
          title: Text(
            volumeType.getLabel(context),
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? colorScheme.primary : colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            volumeType.getDescription(context),
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          ),
          trailing: isSelected
              ? Icon(Icons.check_circle, color: colorScheme.primary)
              : Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurfaceVariant,
                  size: 16,
                ),
          onTap: () {
            ref
                .read(prayerTimesSettingsNotifierProvider.notifier)
                .setNotificationVolumeType(prayerKey, volumeType);
          },
        ),
      );

      if (i < volumeTypes.length - 1) {
        result.add(
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        );
      }
    }
    return result;
  }

  Widget _getVolumeIcon(
    NotificationVolumeType volumeType,
    ColorScheme colorScheme,
    bool isSelected,
  ) {
    final color = isSelected ? colorScheme.primary : colorScheme.onSecondary;
    switch (volumeType) {
      case NotificationVolumeType.notification:
        return Icon(Icons.volume_down, color: color);
      case NotificationVolumeType.alarm:
        return Icon(Icons.volume_up, color: color);
    }
  }
}

void showNotificationSoundScreen(
  BuildContext context,
  PrayerNotifKey prayerKey,
  String prayerName,
) {
  Navigator.of(context).push(
    MaterialPageRoute(
      settings: const RouteSettings(
        name: AnalyticsScreenNames.notificationSound,
      ),
      builder: (context) =>
          NotificationSoundScreen(prayerKey: prayerKey, prayerName: prayerName),
    ),
  );
}
