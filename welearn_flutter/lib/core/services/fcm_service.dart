import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../services/storage_service.dart';
import '../../features/auth/auth_provider.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background message
  debugPrint('Background FCM: ${message.messageId}');
}

class FCMService {
  static final _messaging = FirebaseMessaging.instance;
  static final _localNotifications = FlutterLocalNotificationsPlugin();

  static const _channel = AndroidNotificationChannel(
    'welearn_high_importance',
    'WeLearn Notifications',
    description: 'Important notifications from WeLearn',
    importance: Importance.high,
  );

  static Future<void> initialize(WidgetRef ref) async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );

    FirebaseMessaging.onMessage.listen((message) => _handleForeground(message));

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleNotificationTap(message, ref);
    });

    await _getAndRegisterToken(ref);
    _messaging.onTokenRefresh.listen((token) => _registerToken(token, ref));
  }

  static Future<void> _getAndRegisterToken(WidgetRef ref) async {
    final token = await _messaging.getToken();
    if (token != null) {
      await StorageService.saveFcmToken(token);
      await _registerToken(token, ref);
    }
  }

  static Future<void> _registerToken(String token, WidgetRef ref) async {
    try {
      final client = ref.read(apiClientProvider);
      await client.post(ApiEndpoints.registerFcmToken, data: {
        'token': token,
        'platform': defaultTargetPlatform.name.toLowerCase(),
      });
    } catch (_) {}
  }

  static void _handleForeground(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }

  static void _handleNotificationTap(RemoteMessage message, WidgetRef ref) {
    // Route based on notification type
    final type = message.data['type'] as String?;
    debugPrint('Notification tap type: $type');
  }
}
