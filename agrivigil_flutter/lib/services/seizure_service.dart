import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';

class SeizureService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all seizures
  Future<List<Map<String, dynamic>>> getSeizures({
    String? status,
    String? fieldExecutionId,
    String? officerId,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      var query = _supabase.from('seizures').select('''
            *,
            field_executions(*),
            users!created_by(full_name, email, designation),
            products(*)
          ''');

      if (status != null && status.isNotEmpty) {
        query = query.eq('status', status);
      }

      if (fieldExecutionId != null && fieldExecutionId.isNotEmpty) {
        query = query.eq('field_execution_id', fieldExecutionId);
      }

      if (officerId != null && officerId.isNotEmpty) {
        query = query.eq('created_by', officerId);
      }

      if (startDate != null) {
        query = query.gte('seizure_date', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('seizure_date', endDate.toIso8601String());
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
            'seizure_code.ilike.%$searchQuery%,location.ilike.%$searchQuery%,dealer_name.ilike.%$searchQuery%');
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(limit)
          .range(offset, offset + limit - 1);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch seizures: $e');
    }
  }

  // Get seizure by ID
  Future<Map<String, dynamic>> getSeizureById(String seizureId) async {
    try {
      final response = await _supabase.from('seizures').select('''
            *,
            field_executions(*),
            users!created_by(full_name, email, designation),
            products(*),
            seizure_items(*),
            lab_samples(*),
            fir_cases(*)
          ''').eq('id', seizureId).single();

      return response;
    } catch (e) {
      throw Exception('Failed to fetch seizure details: $e');
    }
  }

  // Create new seizure
  Future<Map<String, dynamic>> createSeizure({
    required String fieldExecutionId,
    required String seizureCode,
    required DateTime seizureDate,
    required String location,
    required String dealerName,
    String? dealerLicense,
    required List<Map<String, dynamic>> seizureItems,
    required String reason,
    Map<String, dynamic>? additionalDetails,
    List<String>? witnesses,
    Map<String, dynamic>? gpsLocation,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Start transaction
      final seizureData = {
        'field_execution_id': fieldExecutionId,
        'seizure_code': seizureCode,
        'seizure_date': seizureDate.toIso8601String(),
        'location': location,
        'dealer_name': dealerName,
        'dealer_license': dealerLicense,
        'reason': reason,
        'status': 'pending',
        'additional_details': additionalDetails ?? {},
        'witnesses': witnesses ?? [],
        'gps_location': gpsLocation,
        'created_by': userId,
        'created_at': DateTime.now().toIso8601String(),
      };

      // Insert seizure
      final seizureResponse = await _supabase
          .from('seizures')
          .insert(seizureData)
          .select()
          .single();

      // Insert seizure items
      if (seizureItems.isNotEmpty) {
        final itemsData = seizureItems
            .map((item) => {
                  ...item,
                  'seizure_id': seizureResponse['id'],
                  'created_at': DateTime.now().toIso8601String(),
                })
            .toList();

        await _supabase.from('seizure_items').insert(itemsData);
      }

      // Update field execution status
      await _supabase
          .from('field_executions')
          .update({'has_seizure': true}).eq('id', fieldExecutionId);

      return seizureResponse;
    } catch (e) {
      throw Exception('Failed to create seizure: $e');
    }
  }

  // Update seizure
  Future<Map<String, dynamic>> updateSeizure({
    required String seizureId,
    String? status,
    Map<String, dynamic>? additionalDetails,
    List<String>? witnesses,
    String? updateNotes,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
        'updated_by': userId,
      };

      if (status != null) updateData['status'] = status;
      if (additionalDetails != null) {
        updateData['additional_details'] = additionalDetails;
      }
      if (witnesses != null) updateData['witnesses'] = witnesses;
      if (updateNotes != null) updateData['update_notes'] = updateNotes;

      final response = await _supabase
          .from('seizures')
          .update(updateData)
          .eq('id', seizureId)
          .select()
          .single();

      // Log status change
      if (status != null) {
        await _logSeizureActivity(
          seizureId: seizureId,
          activity: 'status_change',
          details: {'new_status': status, 'notes': updateNotes},
        );
      }

      return response;
    } catch (e) {
      throw Exception('Failed to update seizure: $e');
    }
  }

  // Add seizure item
  Future<Map<String, dynamic>> addSeizureItem({
    required String seizureId,
    required String productId,
    required double quantity,
    required String unit,
    String? batchNumber,
    String? manufacturingDate,
    String? expiryDate,
    Map<String, dynamic>? itemDetails,
  }) async {
    try {
      final itemData = {
        'seizure_id': seizureId,
        'product_id': productId,
        'quantity': quantity,
        'unit': unit,
        'batch_number': batchNumber,
        'manufacturing_date': manufacturingDate,
        'expiry_date': expiryDate,
        'item_details': itemDetails ?? {},
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('seizure_items')
          .insert(itemData)
          .select()
          .single();

      return response;
    } catch (e) {
      throw Exception('Failed to add seizure item: $e');
    }
  }

  // Upload seizure document
  Future<String> uploadSeizureDocument({
    required String seizureId,
    required String documentType,
    required String fileName,
    required List<int> fileBytes,
    String? description,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath =
          'seizures/$seizureId/${documentType}_${timestamp}_$fileName';

      // Upload to storage
      await _supabase.storage
          .from('seizure-documents')
          .uploadBinary(filePath, Uint8List.fromList(fileBytes));

      final url =
          _supabase.storage.from('seizure-documents').getPublicUrl(filePath);

      // Save document reference
      await _supabase.from('seizure_documents').insert({
        'seizure_id': seizureId,
        'document_type': documentType,
        'file_name': fileName,
        'file_url': url,
        'description': description,
        'uploaded_by': userId,
        'uploaded_at': DateTime.now().toIso8601String(),
      });

      return url;
    } catch (e) {
      throw Exception('Failed to upload document: $e');
    }
  }

  // Generate seizure report
  Future<Map<String, dynamic>> generateSeizureReport({
    required String seizureId,
    required String reportType,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Get seizure details
      final seizure = await getSeizureById(seizureId);

      final reportData = {
        'seizure_id': seizureId,
        'report_type': reportType,
        'seizure_data': seizure,
        'additional_data': additionalData ?? {},
        'generated_by': userId,
        'generated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('seizure_reports')
          .insert(reportData)
          .select()
          .single();

      return response;
    } catch (e) {
      throw Exception('Failed to generate report: $e');
    }
  }

  // Get seizure statistics
  Future<Map<String, dynamic>> getSeizureStatistics({
    String? districtId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _supabase
          .from('seizures')
          .select('id, status, seizure_date, field_executions(district_id)');

      if (startDate != null) {
        query = query.gte('seizure_date', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('seizure_date', endDate.toIso8601String());
      }

      final seizures = await query;

      // Filter by district if specified
      final filteredSeizures = districtId != null
          ? seizures
              .where((s) => s['field_executions']?['district_id'] == districtId)
              .toList()
          : seizures;

            // Calculate statistics
      final stats = <String, dynamic>{
        'total': filteredSeizures.length,
        'pending':
            filteredSeizures.where((s) => s['status'] == 'pending').length,
        'under_investigation': filteredSeizures
            .where((s) => s['status'] == 'under_investigation')
            .length,
        'lab_testing':
            filteredSeizures.where((s) => s['status'] == 'lab_testing').length,
        'legal_action':
            filteredSeizures.where((s) => s['status'] == 'legal_action').length,
        'completed': 
            filteredSeizures.where((s) => s['status'] == 'completed').length,
      };

      // Get monthly trend
      final Map<String, int> monthlyTrend =
          _calculateMonthlyTrend(filteredSeizures);
      stats['monthly_trend'] = monthlyTrend;

      return stats;
    } catch (e) {
      throw Exception('Failed to fetch seizure statistics: $e');
    }
  }

  // Request lab testing for seizure
  Future<void> requestLabTesting({
    required String seizureId,
    required List<String> sampleTypes,
    required String priority,
    String? specialInstructions,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Update seizure status
      await updateSeizure(
        seizureId: seizureId,
        status: 'lab_testing',
      );

      // Create lab request
      await _supabase.from('lab_requests').insert({
        'seizure_id': seizureId,
        'sample_types': sampleTypes,
        'priority': priority,
        'special_instructions': specialInstructions,
        'requested_by': userId,
        'requested_at': DateTime.now().toIso8601String(),
        'status': 'pending',
      });

      // Log activity
      await _logSeizureActivity(
        seizureId: seizureId,
        activity: 'lab_test_requested',
        details: {
          'sample_types': sampleTypes,
          'priority': priority,
        },
      );
    } catch (e) {
      throw Exception('Failed to request lab testing: $e');
    }
  }

  // Initiate legal action
  Future<void> initiateLegalAction({
    required String seizureId,
    required String actionType,
    required Map<String, dynamic> legalDetails,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Update seizure status
      await updateSeizure(
        seizureId: seizureId,
        status: 'legal_action',
      );

      // Create legal action record
      await _supabase.from('legal_actions').insert({
        'seizure_id': seizureId,
        'action_type': actionType,
        'legal_details': legalDetails,
        'initiated_by': userId,
        'initiated_at': DateTime.now().toIso8601String(),
        'status': 'initiated',
      });

      // Log activity
      await _logSeizureActivity(
        seizureId: seizureId,
        activity: 'legal_action_initiated',
        details: {
          'action_type': actionType,
          'details': legalDetails,
        },
      );
    } catch (e) {
      throw Exception('Failed to initiate legal action: $e');
    }
  }

  // Private helper methods
  Future<void> _logSeizureActivity({
    required String seizureId,
    required String activity,
    Map<String, dynamic>? details,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      await _supabase.from('seizure_activities').insert({
        'seizure_id': seizureId,
        'activity': activity,
        'details': details ?? {},
        'created_by': userId,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Log error but don't throw
      print('Failed to log seizure activity: $e');
    }
  }

  Map<String, int> _calculateMonthlyTrend(List<dynamic> seizures) {
    final trend = <String, int>{};
    for (final seizure in seizures) {
      final date = DateTime.parse(seizure['seizure_date']);
      final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      trend[monthKey] = (trend[monthKey] ?? 0) + 1;
    }
    return trend;
  }

  // Get seizures pending action
  Future<List<Map<String, dynamic>>> getPendingSeizures({
    String? assignedTo,
    String? actionType,
  }) async {
    try {
      var query = _supabase
          .from('seizures')
          .select('*, field_executions(*)')
          .inFilter('status', ['pending', 'under_investigation']);

      if (assignedTo != null) {
        query = query.eq('assigned_to', assignedTo);
      }

      final response = await query.order('created_at', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch pending seizures: $e');
    }
  }
}
