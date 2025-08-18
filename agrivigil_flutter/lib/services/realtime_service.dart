import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class RealtimeService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Map<String, RealtimeChannel> _channels = {};
  final Map<String, StreamController> _streamControllers = {};

  // Dashboard data streams
  Stream<Map<String, dynamic>> getDashboardStream(String userId, String role) {
    final key = 'dashboard_$userId';

    if (!_streamControllers.containsKey(key)) {
      _streamControllers[key] =
          StreamController<Map<String, dynamic>>.broadcast();
      _initializeDashboardChannel(userId, role);
    }

    return (_streamControllers[key] as StreamController<Map<String, dynamic>>)
        .stream;
  }

  // Initialize dashboard realtime channel
  void _initializeDashboardChannel(String userId, String role) {
    final channel = _supabase.channel('dashboard:$userId');

    // Listen to inspection updates
    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'field_executions',
      callback: (payload) {
        _handleDashboardUpdate(userId, 'inspection', payload.newRecord);
      },
    );

    // Listen to seizure updates
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'seizures',
      callback: (payload) {
        _handleDashboardUpdate(userId, 'seizure', payload.newRecord);
      },
    );

    // Listen to lab sample updates
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'lab_samples',
      callback: (payload) {
        _handleDashboardUpdate(userId, 'lab_sample', payload.newRecord);
      },
    );

    // Listen to legal case updates
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'fir_cases',
      callback: (payload) {
        _handleDashboardUpdate(userId, 'legal_case', payload.newRecord);
      },
    );

    // Subscribe to the channel
    channel.subscribe();
    _channels['dashboard:$userId'] = channel;
  }

  // Handle dashboard updates
  void _handleDashboardUpdate(
      String userId, String type, Map<String, dynamic> data) {
    final key = 'dashboard_$userId';
    if (_streamControllers.containsKey(key)) {
      (_streamControllers[key] as StreamController<Map<String, dynamic>>).add({
        'type': type,
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  // Notification streams
  Stream<Map<String, dynamic>> getNotificationStream(String userId) {
    final key = 'notifications_$userId';

    if (!_streamControllers.containsKey(key)) {
      _streamControllers[key] =
          StreamController<Map<String, dynamic>>.broadcast();
      _initializeNotificationChannel(userId);
    }

    return (_streamControllers[key] as StreamController<Map<String, dynamic>>)
        .stream;
  }

  // Initialize notification channel
  void _initializeNotificationChannel(String userId) {
    final channel = _supabase.channel('notifications:$userId');

    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'notifications',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: userId,
      ),
      callback: (payload) {
        final key = 'notifications_$userId';
        if (_streamControllers.containsKey(key)) {
          (_streamControllers[key] as StreamController<Map<String, dynamic>>)
              .add(payload.newRecord);
        }
      },
    );

    channel.subscribe();
    _channels['notifications:$userId'] = channel;
  }

  // Lab sample tracking
  Stream<Map<String, dynamic>> trackLabSample(String sampleId) {
    final key = 'lab_sample_$sampleId';

    if (!_streamControllers.containsKey(key)) {
      _streamControllers[key] =
          StreamController<Map<String, dynamic>>.broadcast();
      _initializeLabSampleChannel(sampleId);
    }

    return (_streamControllers[key] as StreamController<Map<String, dynamic>>)
        .stream;
  }

  void _initializeLabSampleChannel(String sampleId) {
    final channel = _supabase.channel('lab_sample:$sampleId');

    channel.onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'lab_samples',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'id',
        value: sampleId,
      ),
      callback: (payload) {
        final key = 'lab_sample_$sampleId';
        if (_streamControllers.containsKey(key)) {
          (_streamControllers[key] as StreamController<Map<String, dynamic>>)
              .add({
            'type': 'update',
            'data': payload.newRecord,
            'oldData': payload.oldRecord,
          });
        }
      },
    );

    channel.subscribe();
    _channels['lab_sample:$sampleId'] = channel;
  }

  // Field execution tracking
  Stream<Map<String, dynamic>> trackFieldExecution(String taskId) {
    final key = 'field_execution_$taskId';

    if (!_streamControllers.containsKey(key)) {
      _streamControllers[key] =
          StreamController<Map<String, dynamic>>.broadcast();
      _initializeFieldExecutionChannel(taskId);
    }

    return (_streamControllers[key] as StreamController<Map<String, dynamic>>)
        .stream;
  }

  void _initializeFieldExecutionChannel(String taskId) {
    final channel = _supabase.channel('field_execution:$taskId');

    // Track field execution updates
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'field_executions',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'inspection_task_id',
        value: taskId,
      ),
      callback: (payload) {
        _handleFieldExecutionUpdate(taskId, 'execution', payload);
      },
    );

    // Track scan results
    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'scan_results',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'field_execution_id',
        value: taskId,
      ),
      callback: (payload) {
        _handleFieldExecutionUpdate(taskId, 'scan', payload);
      },
    );

    channel.subscribe();
    _channels['field_execution:$taskId'] = channel;
  }

  void _handleFieldExecutionUpdate(
      String taskId, String type, PostgresChangePayload payload) {
    final key = 'field_execution_$taskId';
    if (_streamControllers.containsKey(key)) {
      (_streamControllers[key] as StreamController<Map<String, dynamic>>).add({
        'type': type,
        'event': payload.eventType.name,
        'data': payload.newRecord,
        'oldData': payload.oldRecord,
      });
    }
  }

  // Team collaboration presence
  Stream<List<Map<String, dynamic>>> getTeamPresence(String teamId) {
    final key = 'team_presence_$teamId';

    if (!_streamControllers.containsKey(key)) {
      _streamControllers[key] =
          StreamController<List<Map<String, dynamic>>>.broadcast();
    }

    return (_streamControllers[key]
            as StreamController<List<Map<String, dynamic>>>)
        .stream;
  }

  void trackTeamPresence(String teamId, String userId) {
    final channel = _supabase.channel('team:$teamId');
    final key = 'team_presence_$teamId';

    // Initialize stream controller if needed
    if (!_streamControllers.containsKey(key)) {
      _streamControllers[key] =
          StreamController<List<Map<String, dynamic>>>.broadcast();
    }

    // Simple presence tracking without complex type handling
    channel.subscribe((status, [error]) async {
      if (status == RealtimeSubscribeStatus.subscribed) {
        // Track this user's presence
        await channel.track({
          'user_id': userId,
          'online_at': DateTime.now().toIso8601String(),
        });

        // Emit initial empty presence list
        if (_streamControllers.containsKey(key)) {
          (_streamControllers[key]
                  as StreamController<List<Map<String, dynamic>>>)
              .add([]);
        }
      }
    });

    _channels['team:$teamId'] = channel;
  }

  // Live location tracking for field officers
  void trackFieldOfficerLocation(
      String officerId, Map<String, dynamic> location) async {
    final channel =
        _channels['field_officers'] ?? _supabase.channel('field_officers');

    if (!_channels.containsKey('field_officers')) {
      channel.subscribe();
      _channels['field_officers'] = channel;
    }

    await channel.track({
      'officer_id': officerId,
      'location': location,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Broadcast updates
  Future<void> broadcastUpdate(
      String channel, String event, Map<String, dynamic> payload) async {
    final realtimeChannel = _channels[channel] ?? _supabase.channel(channel);

    if (!_channels.containsKey(channel)) {
      realtimeChannel.subscribe();
      _channels[channel] = realtimeChannel;
    }

    await realtimeChannel.sendBroadcastMessage(
      event: event,
      payload: payload,
    );
  }

  // Subscribe to broadcasts
  void subscribeToBroadcast(String channelName, String event,
      Function(Map<String, dynamic>) callback) {
    final channel = _channels[channelName] ?? _supabase.channel(channelName);

    channel.onBroadcast(
      event: event,
      callback: (payload) {
        callback(Map<String, dynamic>.from(payload));
      },
    );

    if (!_channels.containsKey(channelName)) {
      channel.subscribe();
      _channels[channelName] = channel;
    }
  }

  // Clean up
  void dispose() {
    // Close all stream controllers
    for (final controller in _streamControllers.values) {
      controller.close();
    }
    _streamControllers.clear();

    // Unsubscribe from all channels
    for (final channel in _channels.values) {
      channel.unsubscribe();
    }
    _channels.clear();
  }

  // Unsubscribe from specific channel
  void unsubscribe(String channelKey) {
    if (_channels.containsKey(channelKey)) {
      _channels[channelKey]!.unsubscribe();
      _channels.remove(channelKey);
    }

    if (_streamControllers.containsKey(channelKey)) {
      _streamControllers[channelKey]!.close();
      _streamControllers.remove(channelKey);
    }
  }
}
