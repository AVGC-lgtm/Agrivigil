import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AnalyticsService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static bool _isEnabled = !kDebugMode;
  
  // Initialize analytics
  static Future<void> initialize() async {
    try {
      await _setUserProperties();
      await logEvent('app_initialized');
    } catch (e) {
      print('Error initializing analytics: $e');
    }
  }

  // Set user properties
  static Future<void> _setUserProperties() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;
      
      // Store user properties in user_analytics table
      await _supabase.from('user_analytics').upsert({
        'user_id': userId,
        'app_version': '1.0.0',
        'platform': defaultTargetPlatform.toString().split('.').last,
        'last_active': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error setting user properties: $e');
    }
  }

  // Set user ID for tracking
  static Future<void> setUserId(String userId) async {
    // User ID is already set through Supabase auth
  }

  // Set user role
  static Future<void> setUserRole(String role) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;
      
      await _supabase.from('user_analytics').upsert({
        'user_id': userId,
        'user_role': role,
      });
    } catch (e) {
      print('Error setting user role: $e');
    }
  }

  // Set user department
  static Future<void> setUserDepartment(String department) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;
      
      await _supabase.from('user_analytics').upsert({
        'user_id': userId,
        'user_department': department,
      });
    } catch (e) {
      print('Error setting user department: $e');
    }
  }

  // Log custom event
  static Future<void> logEvent(
    String name, {
    Map<String, dynamic>? parameters,
  }) async {
    if (!_isEnabled) return;
    
    try {
      final userId = _supabase.auth.currentUser?.id;
      
      await _supabase.from('analytics_events').insert({
        'user_id': userId,
        'event_name': name,
        'parameters': parameters ?? {},
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error logging event $name: $e');
    }
  }

  // Authentication Events
  static Future<void> logLogin(String method) async {
    await logEvent('login', parameters: {'method': method});
  }

  static Future<void> logSignUp(String method) async {
    await logEvent('sign_up', parameters: {'method': method});
  }

  static Future<void> logLogout() async {
    await logEvent('logout');
  }

  // Screen View Events
  static Future<void> logScreenView(String screenName, {String? screenClass}) async {
    await logEvent('screen_view', parameters: {
      'screen_name': screenName,
      'screen_class': screenClass ?? screenName,
    });
  }

  // Inspection Events
  static Future<void> logInspectionCreated({
    required String inspectionId,
    String? location,
    String? dealerType,
  }) async {
    await logEvent('inspection_created', parameters: {
      'inspection_id': inspectionId,
      if (location != null) 'location': location,
      if (dealerType != null) 'dealer_type': dealerType,
    });
  }

  static Future<void> logInspectionCompleted({
    required String inspectionId,
    required bool violationFound,
    int? duration,
  }) async {
    await logEvent('inspection_completed', parameters: {
      'inspection_id': inspectionId,
      'violation_found': violationFound,
      if (duration != null) 'duration_minutes': duration,
    });
  }

  static Future<void> logInspectionViewed(String inspectionId) async {
    await logEvent('inspection_viewed', parameters: {
      'inspection_id': inspectionId,
    });
  }

  // Seizure Events
  static Future<void> logSeizureCreated({
    required String seizureId,
    required double estimatedValue,
    String? category,
  }) async {
    await logEvent('seizure_created', parameters: {
      'seizure_id': seizureId,
      'estimated_value': estimatedValue,
      if (category != null) 'category': category,
    });
  }

  static Future<void> logSeizureUpdated({
    required String seizureId,
    required String status,
  }) async {
    await logEvent('seizure_updated', parameters: {
      'seizure_id': seizureId,
      'status': status,
    });
  }

  // Lab Sample Events
  static Future<void> logLabSampleCreated({
    required String sampleId,
    required String sampleType,
    String? priority,
  }) async {
    await logEvent('lab_sample_created', parameters: {
      'sample_id': sampleId,
      'sample_type': sampleType,
      if (priority != null) 'priority': priority,
    });
  }

  static Future<void> logLabTestCompleted({
    required String sampleId,
    required String result,
    int? processingDays,
  }) async {
    await logEvent('lab_test_completed', parameters: {
      'sample_id': sampleId,
      'result': result,
      if (processingDays != null) 'processing_days': processingDays,
    });
  }

  // FIR Case Events
  static Future<void> logFIRCaseFiled({
    required String caseId,
    required String caseType,
    String? policeStation,
  }) async {
    await logEvent('fir_case_filed', parameters: {
      'case_id': caseId,
      'case_type': caseType,
      if (policeStation != null) 'police_station': policeStation,
    });
  }

  static Future<void> logFIRCaseUpdated({
    required String caseId,
    required String status,
  }) async {
    await logEvent('fir_case_updated', parameters: {
      'case_id': caseId,
      'status': status,
    });
  }

  // Form Submission Events
  static Future<void> logFormSubmitted({
    required String formId,
    required String formType,
    Map<String, dynamic>? additionalData,
  }) async {
    await logEvent('form_submitted', parameters: {
      'form_id': formId,
      'form_type': formType,
      if (additionalData != null) ...additionalData,
    });
  }

  static Future<void> logFormViewed(String formId) async {
    await logEvent('form_viewed', parameters: {
      'form_id': formId,
    });
  }

  // Search Events
  static Future<void> logSearch({
    required String searchTerm,
    String? module,
    int? resultsCount,
  }) async {
    await logEvent('search', parameters: {
      'search_term': searchTerm,
      if (module != null) 'module': module,
      if (resultsCount != null) 'results_count': resultsCount,
    });
  }

  // Export Events
  static Future<void> logExport({
    required String exportType,
    required String module,
    int? recordCount,
  }) async {
    await logEvent('data_exported', parameters: {
      'export_type': exportType,
      'module': module,
      if (recordCount != null) 'record_count': recordCount,
    });
  }

  // Filter Events
  static Future<void> logFilterApplied({
    required String module,
    required Map<String, dynamic> filters,
  }) async {
    await logEvent('filter_applied', parameters: {
      'module': module,
      'filter_count': filters.length,
      ...filters,
    });
  }

  // Notification Events
  static Future<void> logNotificationReceived({
    required String notificationId,
    required String type,
  }) async {
    await logEvent('notification_received', parameters: {
      'notification_id': notificationId,
      'type': type,
    });
  }

  static Future<void> logNotificationOpened({
    required String notificationId,
    required String type,
  }) async {
    await logEvent('notification_opened', parameters: {
      'notification_id': notificationId,
      'type': type,
    });
  }

  // Performance Events
  static Future<void> logPerformance({
    required String metric,
    required double value,
    String? unit,
  }) async {
    await logEvent('performance_metric', parameters: {
      'metric': metric,
      'value': value,
      if (unit != null) 'unit': unit,
    });
  }

  // Error Events
  static Future<void> logError({
    required String errorType,
    required String errorMessage,
    String? stackTrace,
    Map<String, dynamic>? additionalData,
  }) async {
    await logEvent('app_error', parameters: {
      'error_type': errorType,
      'error_message': errorMessage,
      if (stackTrace != null) 'stack_trace': stackTrace.substring(0, 100),
      if (additionalData != null) ...additionalData,
    });
  }

  // User Action Events
  static Future<void> logButtonClick({
    required String buttonName,
    String? screen,
    Map<String, dynamic>? additionalData,
  }) async {
    await logEvent('button_clicked', parameters: {
      'button_name': buttonName,
      if (screen != null) 'screen': screen,
      if (additionalData != null) ...additionalData,
    });
  }

  static Future<void> logFeatureUsed({
    required String featureName,
    Map<String, dynamic>? additionalData,
  }) async {
    await logEvent('feature_used', parameters: {
      'feature_name': featureName,
      if (additionalData != null) ...additionalData,
    });
  }

  // Dashboard Events
  static Future<void> logDashboardViewed({
    required String dashboardType,
    String? role,
  }) async {
    await logEvent('dashboard_viewed', parameters: {
      'dashboard_type': dashboardType,
      if (role != null) 'user_role': role,
    });
  }

  static Future<void> logDashboardInteraction({
    required String dashboardType,
    required String interactionType,
    Map<String, dynamic>? additionalData,
  }) async {
    await logEvent('dashboard_interaction', parameters: {
      'dashboard_type': dashboardType,
      'interaction_type': interactionType,
      if (additionalData != null) ...additionalData,
    });
  }

  // Session Events
  static Future<void> logSessionStart() async {
    await logEvent('session_start', parameters: {
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> logSessionEnd({int? duration}) async {
    await logEvent('session_end', parameters: {
      'timestamp': DateTime.now().toIso8601String(),
      if (duration != null) 'duration_seconds': duration,
    });
  }

  // Revenue Events (for tracking seizure values, fines, etc.)
  static Future<void> logRevenue({
    required String type,
    required double amount,
    String? currency = 'INR',
  }) async {
    await logEvent('revenue', parameters: {
      'revenue_type': type,
      'amount': amount,
      'currency': currency ?? 'INR',
    });
  }

  // Custom Conversion Events
  static Future<void> logConversion({
    required String conversionType,
    Map<String, dynamic>? additionalData,
  }) async {
    await logEvent('conversion', parameters: {
      'conversion_type': conversionType,
      if (additionalData != null) ...additionalData,
    });
  }

  // App Update Events
  static Future<void> logAppUpdated({
    required String oldVersion,
    required String newVersion,
  }) async {
    await logEvent('app_updated', parameters: {
      'old_version': oldVersion,
      'new_version': newVersion,
    });
  }

  // Clear user data (on logout)
  static Future<void> clearUserData() async {
    // Data is cleared automatically when user logs out from Supabase
  }
  
  // Get analytics observer (not applicable for Supabase)
  static get observer => null;
}