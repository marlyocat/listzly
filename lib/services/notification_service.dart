import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'listzly_reminders';
  static const _channelName = 'Practice Reminders';
  static const _channelDescription = 'Daily practice reminder notifications';
  static const _notificationId = 0;
  static const _streakWarning2Id = 1;
  static const _streakWarning3Id = 2;

  static const _dailyMessages = [
    ('Time to Practice!', 'Your daily music practice session is waiting for you.'),
    ('Ready to play?', 'A few minutes of practice goes a long way.'),
    ('Your instrument misses you!', "Let's make some music today."),
    ('Practice makes progress!', 'Tap to start your session.'),
    ('Musical moment awaits!', "Even 5 minutes of practice counts."),
    ('Keep the momentum going!', 'Your future self will thank you.'),
    ("Don't break the chain!", 'A quick session keeps your streak alive.'),
    ('Time to level up!', 'Every session brings you closer to your goal.'),
  ];

  static const _streakDay2Messages = [
    ('Your streak is at risk!', 'Practice today to keep your streak alive.'),
    ("Don't lose your progress!", 'One quick session saves your streak.'),
    ('Streak check-in', "You haven't practiced in 2 days — hop back in!"),
    ('Missing your music!', 'A short session today keeps your streak safe.'),
    ('2 days without practice', 'Jump back in before your streak resets!'),
  ];

  static const _streakDay3Messages = [
    ('Last chance!', "Your streak will be lost if you don't practice today."),
    ('Final warning!', 'Today is the last day to save your streak.'),
    ('Your streak needs you!', "It's now or never. Practice to keep it alive!"),
    ('Now or never!', "Your streak expires today, don't let it go!"),
    ('Streak emergency!', 'One session today is all it takes to save it.'),
  ];

  static final _random = Random();

  /// Call once at app startup.
  Future<void> init() async {
    tz.initializeTimeZones();
    try {
      final tzInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(tzInfo.identifier));
    } catch (_) {
      // Fallback: derive a fixed-offset timezone from the device's UTC offset.
      final offset = DateTime.now().timeZoneOffset;
      tz.setLocalLocation(tz.getLocation(
        'Etc/GMT${offset.isNegative ? '+' : '-'}${offset.inHours.abs()}',
      ));
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings: settings);
  }

  /// Request notification permission (Android 13+).
  Future<bool> requestPermission() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  /// Schedule a daily notification at the given time.
  /// [timeStr] is in "HH:mm" format (24-hour).
  Future<void> scheduleDailyReminder(String timeStr) async {
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    await cancelReminder();

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final daily = _dailyMessages[_random.nextInt(_dailyMessages.length)];
    await _plugin.zonedSchedule(
      id: _notificationId,
      title: daily.$1,
      body: daily.$2,
      scheduledDate: scheduledDate,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'daily_reminder',
    );
  }

  /// Cancel the daily reminder notification.
  Future<void> cancelReminder() async {
    await _plugin.cancel(id: _notificationId);
  }

  /// Schedule streak warning notifications for 2 and 3 days from now.
  /// Called after each practice session. [timeStr] is the user's reminder
  /// time in "HH:mm" format. If null, no warnings are scheduled.
  Future<void> scheduleStreakWarnings(String? timeStr) async {
    await cancelStreakWarnings();
    if (timeStr == null || timeStr.isEmpty) return;

    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final now = tz.TZDateTime.now(tz.local);

    // Day 2: "Your streak is at risk!"
    final day2 = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day + 2,
      hour,
      minute,
    );

    // Day 3: "Last chance!"
    final day3 = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day + 3,
      hour,
      minute,
    );

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final warn2 = _streakDay2Messages[_random.nextInt(_streakDay2Messages.length)];
    await _plugin.zonedSchedule(
      id: _streakWarning2Id,
      title: warn2.$1,
      body: warn2.$2,
      scheduledDate: day2,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'streak_warning_2',
    );

    final warn3 = _streakDay3Messages[_random.nextInt(_streakDay3Messages.length)];
    await _plugin.zonedSchedule(
      id: _streakWarning3Id,
      title: warn3.$1,
      body: warn3.$2,
      scheduledDate: day3,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'streak_warning_3',
    );
  }

  /// Cancel any pending streak warning notifications.
  Future<void> cancelStreakWarnings() async {
    await _plugin.cancel(id: _streakWarning2Id);
    await _plugin.cancel(id: _streakWarning3Id);
  }
}
