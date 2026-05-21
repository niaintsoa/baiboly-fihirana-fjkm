import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baiboly_apk/presentation/cubits/preferences_cubit.dart';

class NotificationCubit extends Cubit<void> {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final PreferencesCubit _preferencesCubit;
  late final StreamSubscription _prefSubscription;

  NotificationCubit(this._preferencesCubit) : super(null) {
    _initialize();
    // Listen to changes in preferences
    _prefSubscription = _preferencesCubit.stream.listen(_handlePreferenceChange);
  }

  Future<void> _initialize() async {
    // Initialize timezone data
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
    // Schedule initial notifications based on current state
    _scheduleFromState(_preferencesCubit.state);
  }

  void _handlePreferenceChange(PreferencesState state) {
    _cancelAll();
    _scheduleFromState(state);
  }

  Future<void> _scheduleFromState(PreferencesState state) async {
    if (state.dailyReadingEnabled && state.dailyReadingTime.isNotEmpty) {
      await _scheduleDailyNotification(
        id: 1,
        title: 'Lecture Biblique',
        body: 'C\'est le moment de lire la Bible.',
        timeString: state.dailyReadingTime,
      );
    }
    if (state.dailyWorshipEnabled && state.dailyWorshipTime.isNotEmpty) {
      await _scheduleDailyNotification(
        id: 2,
        title: 'Culte Quotidien',
        body: 'Temps de prière et de culte.',
        timeString: state.dailyWorshipTime,
      );
    }
  }

  Future<void> _scheduleDailyNotification({required int id, required String title, required String body, required String timeString}) async {
    final parts = timeString.split(':');
    if (parts.length != 2) return;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return;
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'daily_channel',
      'Daily Notifications',
      channelDescription: 'Notifications for daily reading and worship',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _cancelAll() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  @override
  Future<void> close() async {
    await _prefSubscription.cancel();
    await _cancelAll();
    return super.close();
  }
}
