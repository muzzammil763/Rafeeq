import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    await _configureLocalTimeZone();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
          macOS: initializationSettingsDarwin,
        );

    await _flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
      },
    );

    _isInitialized = true;
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
    final String timeZoneName = timeZoneInfo.identifier;
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  Future<bool?> requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      return await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      // Request notification permission
      final granted = await androidImplementation
          ?.requestNotificationsPermission();

      // Also request exact alarm permission (required on Android 12+)
      await androidImplementation?.requestExactAlarmsPermission();

      return granted;
    }
    return false;
  }

  Future<bool> hasExactAlarmPermission() async {
    if (Platform.isAndroid) {
      return await _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.canScheduleExactNotifications() ??
          false;
    }
    return true; // Not required on iOS/macOS
  }

  Future<bool> hasPermission() async {
    if (Platform.isIOS || Platform.isMacOS) {
      final settings = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.checkPermissions();
      return settings?.isEnabled ?? false;
    } else if (Platform.isAndroid) {
      return await _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.areNotificationsEnabled() ??
          false;
    }
    return true;
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    String? soundAsset,
    String? volumeType,
  }) async {
    // Determine the schedule mode — fall back to inexact if exact alarms
    // are not permitted (Android 12+ requires explicit user grant).
    var scheduleMode = AndroidScheduleMode.exactAllowWhileIdle;

    if (Platform.isAndroid) {
      final androidImpl = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final canScheduleExact =
          await androidImpl?.canScheduleExactNotifications() ?? false;
      if (!canScheduleExact) {
        scheduleMode = AndroidScheduleMode.inexactAllowWhileIdle;
      }
    }

    // Build notification details based on sound type and volume type
    final notificationDetails = _buildNotificationDetails(
      soundAsset,
      body,
      volumeType,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: notificationDetails,
      androidScheduleMode: scheduleMode,
      payload: payload,
    );
  }

  /// Build notification details with appropriate channel for each sound type
  NotificationDetails _buildNotificationDetails(
    String? soundAsset,
    String body,
    String? volumeType,
  ) {
    // Determine sound configuration
    String? androidSound;
    bool playSound = true;
    bool isSilent = false;
    String channelId;
    String channelName;
    AudioAttributesUsage audioAttributesUsage =
        AudioAttributesUsage.notification;

    if (soundAsset == null) {
      // Silent mode - respects device silent/do not disturb
      playSound = false;
      isSilent = true;
      androidSound = null;
      channelId = 'prayer_silent';
      channelName = 'Prayer Times - Silent';
    } else if (soundAsset.isEmpty) {
      // Default sound - uses system default notification sound
      playSound = true;
      isSilent = false;
      androidSound = null;
      channelId = 'prayer_default';
      channelName = 'Prayer Times - Default';
    } else {
      // Custom sound (Salah Sound)
      playSound = true;
      isSilent = false;
      final fileName = soundAsset.split('/').last;
      androidSound = fileName.replaceAll('.mp3', '');
      // Include volume type in channel ID to separate notification and alarm channels
      final volumeSuffix = volumeType == 'alarm' ? '_alarm' : '_notif';
      channelId = 'prayer_custom_$androidSound$volumeSuffix';
      channelName = volumeType == 'alarm'
          ? 'Prayer Times - Custom (Alarm Volume)'
          : 'Prayer Times - Custom (Notification Volume)';
      // Use specified volume type or default to notification
      audioAttributesUsage = volumeType == 'alarm'
          ? AudioAttributesUsage.alarm
          : AudioAttributesUsage.notification;
    }

    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: 'Notifications for prayer times',
        importance: Importance.max,
        priority: Priority.high,
        playSound: playSound,
        silent: isSilent,
        sound: androidSound != null
            ? RawResourceAndroidNotificationSound(androidSound)
            : null,
        enableVibration: playSound, // Vibrate only when sound is enabled
        audioAttributesUsage: audioAttributesUsage,
        styleInformation: BigTextStyleInformation(body),
      ),
      iOS: DarwinNotificationDetails(
        presentSound: playSound,
        sound: soundAsset != null && soundAsset.isNotEmpty
            ? soundAsset.split('/').last
            : null,
      ),
    );
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? soundAsset,
    String? volumeType,
  }) async {
    // Build notification details with appropriate channel for each sound type
    final notificationDetails = _buildNotificationDetails(
      soundAsset,
      body,
      volumeType,
    );

    await _flutterLocalNotificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
    );
  }

  Future<void> cancelAll() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> cancel(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id: id);
  }
}
