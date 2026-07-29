import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log('[FCM] Background message: ${message.messageId}');
}

class FirebaseMessagingService {
  FirebaseMessagingService._();

  static final FirebaseMessagingService instance = FirebaseMessagingService._();

  factory FirebaseMessagingService() => instance;

  static const String _channelId = 'ezhandy_provider_notifications';
  static const String _channelName = 'Ezhandy Provider Notifications';
  static const String _tokenPrefsKey = 'fcm_device_token';

  late final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp();
      _messaging = FirebaseMessaging.instance;
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      await _setupLocalNotifications();
      await _requestPermission();
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      await _fetchAndStoreToken();
      _messaging.onTokenRefresh.listen(_persistToken);

      _initialized = true;
    } catch (e, stack) {
      log('[FCM] Initialization failed: $e', stackTrace: stack);
    }
  }

  Future<void> initializeNotificationSettings() async {
    await initialize();
  }

  void foregroundNotification() {
    if (!_initialized) return;
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('[FCM] Foreground message: ${message.messageId}');
      _showLocalNotification(message);
    });
  }

  void backgroundTapNotification() {
    if (!_initialized) return;
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('[FCM] Opened from background: ${message.messageId}');
      _handleNotificationTap(message.data);
    });
  }

  Future<void> terminateTapNotification() async {
    if (!_initialized) return;
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage == null) return;

    log('[FCM] Opened from terminated: ${initialMessage.messageId}');
    _handleNotificationTap(initialMessage.data);
  }

  Future<void> _setupLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) return;
        try {
          final data = jsonDecode(payload);
          if (data is Map<String, dynamic>) {
            _handleNotificationTap(data);
          }
        } catch (e) {
          log('[FCM] Invalid notification payload: $e');
        }
      },
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: 'Push notifications for Ezhandy Provider',
        importance: Importance.high,
      ),
    );
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    log('[FCM] Permission: ${settings.authorizationStatus}');

    if (!Platform.isAndroid) return;

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
  }

  Future<void> _fetchAndStoreToken() async {
    try {
      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) {
        log('[FCM] Token is null/empty');
        return;
      }
      await _persistToken(token);
    } catch (e) {
      log('[FCM] Failed to get token: $e');
    }
  }

  Future<void> _persistToken(String token) async {
    _fcmToken = token;
    log('[FCM] Device token: $token');

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenPrefsKey, token);
  }

  Future<String?> getStoredToken() async {
    if (_fcmToken != null && _fcmToken!.isNotEmpty) return _fcmToken;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenPrefsKey);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final title = notification?.title ?? message.data['title']?.toString();
    final body = notification?.body ?? message.data['body']?.toString();

    if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
      return;
    }

    await _localNotifications.show(
      notification?.hashCode ?? message.hashCode,
      title ?? 'Ezhandy Provider',
      body ?? '',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Push notifications for Ezhandy Provider',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void _handleNotificationTap(Map<String, dynamic> data) {
    log('[FCM] Notification tap data: $data');
  }
}
