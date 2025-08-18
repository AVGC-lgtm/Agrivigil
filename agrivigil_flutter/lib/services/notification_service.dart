import 'dart:async';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final SupabaseClient _supabase = Supabase.instance.client;

  StreamController<Map<String, dynamic>>? _notificationStreamController;

  // Initialize notification service
  Future<void> initialize() async {
    // Initialize local notifications
    await _initializeLocalNotifications();

    // Initialize notification stream
    _notificationStreamController =
        StreamController<Map<String, dynamic>>.broadcast();

    // Listen to Supabase notifications
    _listenToSupabaseNotifications();
  }

  // Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
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

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  // Listen to Supabase real-time notifications
  void _listenToSupabaseNotifications() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    _supabase
        .channel('notifications:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            final notification = payload.newRecord;
            _handleNotification(notification);
          },
        )
        .subscribe();
  }

  // Handle incoming notification
  void _handleNotification(Map<String, dynamic> notification) {
    // Add to stream
    _notificationStreamController?.add(notification);

    // Show local notification
    _showLocalNotification(notification);
  }

  // Show local notification
  Future<void> _showLocalNotification(Map<String, dynamic> notification) async {
    const androidDetails = AndroidNotificationDetails(
      'agrivigil_channel',
      'AgriVigil Notifications',
      channelDescription: 'Notifications for AgriVigil app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification['id'] ?? 0,
      notification['title'] ?? 'AgriVigil',
      notification['body'] ?? '',
      details,
      payload: jsonEncode(notification),
    );
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      final notification = jsonDecode(response.payload!);
      _handleNotificationAction(notification);
    }
  }

  // Handle notification action
  void _handleNotificationAction(Map<String, dynamic> notification) {
    final type = notification['type'] ?? '';
    final data = notification['data'] ?? {};

    // Handle different notification types
    switch (type) {
      case 'inspection_assigned':
      case 'seizure_alert':
      case 'lab_result':
      case 'legal_update':
        // Navigate to appropriate screen
        // This would be handled by the app's navigation logic
        break;
      default:
        break;
    }
  }

  // Send notification to user
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _supabase.from('notifications').insert({
        'user_id': userId,
        'title': title,
        'body': body,
        'type': type,
        'data': data,
        'read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  // Get notification stream
  Stream<Map<String, dynamic>>? get notificationStream =>
      _notificationStreamController?.stream;

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'read': true}).eq('id', notificationId);
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // Get unread count
  Future<int> getUnreadCount() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return 0;

      final response = await _supabase
          .from('notifications')
          .select('id')
          .eq('user_id', userId)
          .eq('read', false);

      return response.length;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  // Clear all notifications
  Future<void> clearAll() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase.from('notifications').delete().eq('user_id', userId);
    } catch (e) {
      print('Error clearing notifications: $e');
    }
  }

  // Dispose
  void dispose() {
    _notificationStreamController?.close();
  }
}
