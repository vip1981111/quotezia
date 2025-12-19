import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // Sample quotes for notifications
  static const List<Map<String, String>> _notificationQuotes = [
    {
      'text': 'The only way to do great work is to love what you do.',
      'author': 'Steve Jobs',
      'textAr': 'الطريقة الوحيدة لعمل عظيم هي أن تحب ما تفعله.',
      'authorAr': 'ستيف جوبز',
    },
    {
      'text': 'Believe you can and you\'re halfway there.',
      'author': 'Theodore Roosevelt',
      'textAr': 'آمن بقدرتك وستكون قد قطعت نصف الطريق.',
      'authorAr': 'ثيودور روزفلت',
    },
    {
      'text': 'Success is not final, failure is not fatal.',
      'author': 'Winston Churchill',
      'textAr': 'النجاح ليس نهائياً، والفشل ليس قاتلاً.',
      'authorAr': 'ونستون تشرشل',
    },
    {
      'text': 'The future belongs to those who believe in the beauty of their dreams.',
      'author': 'Eleanor Roosevelt',
      'textAr': 'المستقبل ملك لأولئك الذين يؤمنون بجمال أحلامهم.',
      'authorAr': 'إليانور روزفلت',
    },
    {
      'text': 'It does not matter how slowly you go as long as you do not stop.',
      'author': 'Confucius',
      'textAr': 'لا يهم كم تسير ببطء طالما أنك لا تتوقف.',
      'authorAr': 'كونفوشيوس',
    },
    {
      'text': 'The best time to plant a tree was 20 years ago. The second best time is now.',
      'author': 'Chinese Proverb',
      'textAr': 'أفضل وقت لزراعة شجرة كان قبل 20 عاماً. ثاني أفضل وقت هو الآن.',
      'authorAr': 'مثل صيني',
    },
    {
      'text': 'Your limitation—it\'s only your imagination.',
      'author': 'Unknown',
      'textAr': 'حدودك - هي فقط خيالك.',
      'authorAr': 'مجهول',
    },
  ];

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz_data.initializeTimeZones();

    // Android settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // macOS settings
    const macOSSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: macOSSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    _isInitialized = true;
    debugPrint('NotificationService: Initialized');
  }

  void _onNotificationResponse(NotificationResponse response) {
    debugPrint('NotificationService: Notification tapped: ${response.payload}');
  }

  // Request permissions (iOS/macOS)
  Future<bool> requestPermissions() async {
    // For iOS
    final iOS = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    // For macOS
    final macOS = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    // For Android 13+
    final android = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    debugPrint('NotificationService: Permissions - iOS: $iOS, macOS: $macOS, Android: $android');
    return iOS ?? macOS ?? android ?? true;
  }

  // Schedule daily notification
  Future<void> scheduleDailyNotification({
    required TimeOfDay time,
    bool isArabic = false,
  }) async {
    await cancelAllNotifications();

    final quote = _getRandomQuote();
    final title = isArabic ? 'اقتباس اليوم' : 'Quote of the Day';
    final body = isArabic
        ? '${quote['textAr']}\n— ${quote['authorAr']}'
        : '${quote['text']}\n— ${quote['author']}';

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If the time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'daily_quote_channel',
      'Daily Quote',
      channelDescription: 'Daily inspirational quote notification',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      0,
      title,
      body,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'daily_quote',
    );

    debugPrint('NotificationService: Daily notification scheduled for ${time.hour}:${time.minute}');
  }

  // Show immediate test notification
  Future<void> showTestNotification({bool isArabic = false}) async {
    final quote = _getRandomQuote();
    final title = isArabic ? 'اقتباس تجريبي' : 'Test Quote';
    final body = isArabic
        ? '${quote['textAr']}\n— ${quote['authorAr']}'
        : '${quote['text']}\n— ${quote['author']}';

    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      channelDescription: 'Test notifications channel',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: iosDetails,
    );

    await _notificationsPlugin.show(
      1,
      title,
      body,
      notificationDetails,
      payload: 'test_quote',
    );

    debugPrint('NotificationService: Test notification shown');
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    debugPrint('NotificationService: All notifications cancelled');
  }

  // Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
    debugPrint('NotificationService: Notification $id cancelled');
  }

  Map<String, String> _getRandomQuote() {
    final random = Random();
    return _notificationQuotes[random.nextInt(_notificationQuotes.length)];
  }
}
