import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/memo.dart';

import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings: settings);
    // timezoneデータを読み込む
    tz.initializeTimeZones();
    // 端末の現在のタイムゾーンを取得
    final currentTimeZone = await FlutterTimezone.getLocalTimezone();
    // timezoneパッケージ側にも設定
    tz.setLocalLocation(tz.getLocation(currentTimeZone.identifier));
  }

  Future<void> requestPermission() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleMemoNotification(Memo memo) async {
    final scheduledAt = memo.scheduledAt;
    if (memo.id == null || scheduledAt == null || !memo.notificationEnabled) {
      return;
    }
    // ここで scheduledAt を使って予約通知を登録
  }

  Future<void> scheduleTestNotification() async {
    await _plugin.zonedSchedule(
      id: 100,
      title: '予約通知テスト',
      body: '10秒前に予約した通知です',
      scheduledDate: tz.TZDateTime.now(tz.local)
          .add(const Duration(seconds: 10)),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'memo_schedule_channel',
          'Memo Schedule',
          channelDescription: 'メモの日時通知',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
