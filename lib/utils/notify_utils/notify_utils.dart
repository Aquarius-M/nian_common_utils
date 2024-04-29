import 'dart:async';
import 'dart:io';

import 'package:nian_common_utils/utils/notify_utils/payload.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../log_utils/app_log_utils.dart';

/// android/app/build.gradle
// android {
//   defaultConfig {
//     multiDexEnabled true
//   }

//   compileOptions {
//     // Flag to enable support for the new language APIs
//     coreLibraryDesugaringEnabled true
//     // Sets Java compatibility to Java 8
//     sourceCompatibility JavaVersion.VERSION_1_8
//     targetCompatibility JavaVersion.VERSION_1_8
//   }
// }

// dependencies {
//   coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:1.1.5'
// }

/// android/build.gradle
// buildscript {
//    ...
//   dependencies {
//       classpath 'com.android.tools.build:gradle:4.2.2'
//       ...
//   }
// dependencies {
//     implementation 'androidx.window:window:1.0.0'
//     implementation 'androidx.window:window-java:1.0.0'
//     ...
// }

// android/app/src/main/AndroidManifest.xml
// <activity
//   android:showWhenLocked="true"
//   android:turnScreenOn="true">

/// 通知封装
int id = 0;

class NotifyUtils {
  factory NotifyUtils() {
    _singleton ??= NotifyUtils._();
    return _singleton!;
  }

  static NotifyUtils? _singleton;

  NotifyUtils._();

  static final _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future init() async {
    if (Platform.isAndroid) {
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()!
          .requestNotificationsPermission();
    }
    var android = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = const DarwinInitializationSettings();
    var initSetttings = InitializationSettings(android: android, iOS: iOS);
    _flutterLocalNotificationsPlugin.initialize(
      initSetttings,
      onDidReceiveNotificationResponse: (notificationResponse) {
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            var payload = NoticePayload.fromJson(notificationResponse.payload);
            var path = payload.path;
            debugPrint(path);
            break;
          case NotificationResponseType.selectedNotificationAction:
            break;
        }
      },
    ).then((value) {
      AppLog.i("初始化通知成功");
    });
  }

  static void requestPermissions() async {
    if (Platform.isIOS) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.requestNotificationsPermission();
    }
  }

  static Future<int> showNotification(
    String title,
    String content,
    ReceivedInfo payload, {
    bool playSound = true,
    bool enableVibration = true,
  }) async {
    var androidNotificationDetails = AndroidNotificationDetails(
      '962464',
      'SoulChat',
      channelDescription: 'SoulChat Notice',
      icon: "@mipmap/ic_launcher",
      playSound: playSound,
      enableVibration: enableVibration,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'SoulChat Ticker',
    );
    var iosNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: playSound,
    );
    var notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );
    id++;
    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      content,
      notificationDetails,
      payload: payload.payload!.toJsonString(),
    );
    return id;
  }

  static Future<void> cancelNotice(int id, {String? tag}) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  static Future<void> cancelAll() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
