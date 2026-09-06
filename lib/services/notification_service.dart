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
    final id = memo.id;
    final scheduledAt = memo.scheduledAt;

    if (id == null || scheduledAt == null || !memo.notificationEnabled) {
      return;
    }
    // 過去の日時には予約しない
    if (!scheduledAt.isAfter(DateTime.now())) {
      return;
    }
    final scheduledDate = tz.TZDateTime(
      tz.local,
      scheduledAt.year,
      scheduledAt.month,
      scheduledAt.day,
      scheduledAt.hour,
      scheduledAt.minute,
    );
    await _plugin.zonedSchedule(
      id: id,
      title: memo.title.isEmpty ? 'メモ' : memo.title,
      body: memo.content.isEmpty ? '予定の時刻になりました' : memo.content,
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'memo_schedule_channel',
          'Memo Schedule',
          channelDescription: '日時付きメモの通知',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: id.toString(),
    );
  }

  Future<void> cancelMemoNotification(int memoId) async {
    await _plugin.cancel(id: memoId);
  }
}
