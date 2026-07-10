import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:async';


class LocalNotificationService {

  static final LocalNotificationService _instance =
      LocalNotificationService._internal();


  factory LocalNotificationService(){
    return _instance;
  }


  LocalNotificationService._internal();



  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();


  bool _isInitialized = false;



  Future<void> initialize() async {

    if(_isInitialized) return;


    tz.initializeTimeZones();


    const androidSettings =
    AndroidInitializationSettings(
      '@mipmap/ic_launcher'
    );


    const iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission:true,
      requestBadgePermission:true,
      requestSoundPermission:true,
    );


    const settings =
    InitializationSettings(
      android:androidSettings,
      iOS:iosSettings,
    );



   await _notificationsPlugin.initialize(
  settings: settings,
  onDidReceiveNotificationResponse:
      _onNotificationTapped,
);


    _isInitialized=true;

  }





  /// Request permission

  Future<bool> requestPermission() async {


    await initialize();


    final android =
        _notificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();


    final ios =
        _notificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();


    final androidGranted =
        await android?.requestNotificationsPermission()
        ?? true;


    final iosGranted =
        await ios?.requestPermissions(
          alert:true,
          badge:true,
          sound:true,
        )
        ?? true;



    return androidGranted && iosGranted;

  }






  Future<void> showNotification({

    required int id,

    required String title,

    required String body,

    String? payload,

  }) async {


    await initialize();



    const details =
    NotificationDetails(

      android:
      AndroidNotificationDetails(

        'fertility_reminders',

        'Fertility Reminders',

        importance:
        Importance.max,

        priority:
        Priority.high,

        enableVibration:true,

      ),


      iOS:
      DarwinNotificationDetails(

        presentAlert:true,

        presentBadge:true,

        presentSound:true,

      ),

    );



    await _notificationsPlugin.show(
  id: id,
  title: title,
  body: body,
  notificationDetails: details,
  payload: payload,
);


  }







  Future<void> scheduleNotification({

    required int id,

    required String title,

    required String body,

    required DateTime scheduledTime,

    String? payload,


  }) async {



    await initialize();



    const details =
    NotificationDetails(

      android:
      AndroidNotificationDetails(

        'fertility_reminders',

        'Fertility Reminders',

        importance:
        Importance.high,

        priority:
        Priority.high,

      ),


      iOS:
      DarwinNotificationDetails(

        presentAlert:true,

        presentBadge:true,

        presentSound:true,

      ),

    );




   await _notificationsPlugin.zonedSchedule(

  id: id,

  title: title,

  body: body,

  scheduledDate:
      tz.TZDateTime.from(
        scheduledTime,
        tz.local,
      ),

  notificationDetails: details,

  androidScheduleMode:
      AndroidScheduleMode.exactAllowWhileIdle,

  payload: payload,

);
  }







  Future<void> cancelNotification(
      int id
      ) async {


    await _notificationsPlugin.cancel(
  id: id,
);

  }




  Future<void> cancelAllNotifications() async {

    await _notificationsPlugin.cancelAll();

  }





  Future<List<PendingNotificationRequest>>
  getPendingNotifications() async {


    return await
    _notificationsPlugin
        .pendingNotificationRequests();

  }





  void _onNotificationTapped(
      NotificationResponse response
      ){

    debugPrint(
      "Notification tapped ${response.payload}"
    );

  }


}