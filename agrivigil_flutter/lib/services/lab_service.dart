import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';

class LabService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all lab samples
  Future<List<Map<String, dynamic>>> getLabSamples({
    String? status,
    String? labId,
    String? searchQuery,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      var query = _supabase
          .from('lab_samples')
          .select('*, seizures(*), field_executions(*)');

      if (status != null && status.isNotEmpty) {
        query = query.eq('status', status);
      }

      if (labId != null && labId.isNotEmpty) {
        query = query.eq('lab_id', labId);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
            'sample_code.ilike.%$searchQuery%,sample_type.ilike.%$searchQuery%');
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(limit)
          .range(offset, offset + limit - 1);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch lab samples: $e');
    }
  }

  // Get lab sample by ID
  Future<Map<String, dynamic>> getLabSampleById(String sampleId) async {
    try {
      final response = await _supabase
          .from('lab_samples')
          .select('*, seizures(*), field_executions(*), test_results(*)')
          .eq('id', sampleId)
          .single();

      return response;
    } catch (e) {
      throw Exception('Failed to fetch lab sample: $e');
    }
  }

  // Create new lab sample
  Future<Map<String, dynamic>> createLabSample({
    required String seizureId,
    required String sampleType,
    required String sampleCode,
    required Map<String, dynamic> sampleDetails,
    String? assignedTo,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final sampleData = {
        'seizure_id': seizureId,
        'sample_type': sampleType,
        'sample_code': sampleCode,
        'sample_details': sampleDetails,
        'status': 'pending',
        'created_by': userId,
        'assigned_to': assignedTo,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('lab_samples')
          .insert(sampleData)
          .select()
          .single();

      return response;
    } catch (e) {
      throw Exception('Failed to create lab sample: $e');
    }
  }

  // Update lab sample
  Future<Map<String, dynamic>> updateLabSample({
    required String sampleId,
    String? status,
    Map<String, dynamic>? sampleDetails,
    String? assignedTo,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
        'updated_by': userId,
      };

      if (status != null) updateData['status'] = status;
      if (sampleDetails != null) updateData['sample_details'] = sampleDetails;
      if (assignedTo != null) updateData['assigned_to'] = assignedTo;

      final response = await _supabase
          .from('lab_samples')
          .update(updateData)
          .eq('id', sampleId)
          .select()
          .single();

      return response;
    } catch (e) {
      throw Exception('Failed to update lab sample: $e');
    }
  }

  // Submit test result
  Future<Map<String, dynamic>> submitTestResult({
    required String sampleId,
    required String testType,
    required Map<String, dynamic> results,
    required String conclusion,
    List<String>? attachments,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final testData = {
        'sample_id': sampleId,
        'test_type': testType,
        'results': results,
        'conclusion': conclusion,
        'attachments': attachments ?? [],
        'tested_by': userId,
        'tested_at': DateTime.now().toIso8601String(),
        'status': 'completed',
      };

      // Insert test result
      final testResponse = await _supabase
          .from('test_results')
          .insert(testData)
          .select()
          .single();

      // Update sample status
      await _supabase.from('lab_samples').update({
        'status': 'tested',
        'test_completed_at': DateTime.now().toIso8601String(),
      }).eq('id', sampleId);

      return testResponse;
    } catch (e) {
      throw Exception('Failed to submit test result: $e');
    }
  }

  // Get test results for a sample
  Future<List<Map<String, dynamic>>> getTestResults(String sampleId) async {
    try {
      final response = await _supabase
          .from('test_results')
          .select('*, users!tested_by(full_name, email)')
          .eq('sample_id', sampleId)
          .order('tested_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch test results: $e');
    }
  }

  // Get lab statistics
  Future<Map<String, dynamic>> getLabStatistics({
    String? labId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _supabase.from('lab_samples').select('status, created_at');

      if (labId != null && labId.isNotEmpty) {
        query = query.eq('lab_id', labId);
      }

      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }

      final samples = await query;

      // Calculate statistics
      final stats = {
        'total': samples.length,
        'pending': samples.where((s) => s['status'] == 'pending').length,
        'in_progress':
            samples.where((s) => s['status'] == 'in_progress').length,
        'tested': samples.where((s) => s['status'] == 'tested').length,
        'completed': samples.where((s) => s['status'] == 'completed').length,
      };

      return stats;
    } catch (e) {
      throw Exception('Failed to fetch lab statistics: $e');
    }
  }

  // Generate lab report
  Future<Map<String, dynamic>> generateLabReport({
    required String sampleId,
    required String reportType,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final reportData = {
        'sample_id': sampleId,
        'report_type': reportType,
        'additional_data': additionalData ?? {},
        'generated_by': userId,
        'generated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('lab_reports')
          .insert(reportData)
          .select()
          .single();

      return response;
    } catch (e) {
      throw Exception('Failed to generate lab report: $e');
    }
  }

  // Get pending samples for analyst
  Future<List<Map<String, dynamic>>> getPendingSamplesForAnalyst(
      String analystId) async {
    try {
      final response = await _supabase
          .from('lab_samples')
          .select('*, seizures(*)')
          .eq('assigned_to', analystId)
          .inFilter('status', ['pending', 'in_progress']).order('created_at',
              ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch pending samples: $e');
    }
  }

  // Upload lab document
  Future<String> uploadLabDocument({
    required String sampleId,
    required String fileName,
    required List<int> fileBytes,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final filePath =
          'lab-documents/$sampleId/${DateTime.now().millisecondsSinceEpoch}_$fileName';

      await _supabase.storage
          .from('lab-documents')
          .uploadBinary(filePath, Uint8List.fromList(fileBytes));

      final url =
          _supabase.storage.from('lab-documents').getPublicUrl(filePath);

      return url;
    } catch (e) {
      throw Exception('Failed to upload document: $e');
    }
  }

  // Search test methods
  Future<List<Map<String, dynamic>>> searchTestMethods(String query) async {
    try {
      final response = await _supabase
          .from('test_methods')
          .select()
          .ilike('name', '%$query%')
          .limit(10);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to search test methods: $e');
    }
  }
}
