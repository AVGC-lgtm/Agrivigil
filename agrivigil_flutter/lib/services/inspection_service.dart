import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/inspection_model.dart';

class InspectionService {
  final _supabase = Supabase.instance.client;
  final _uuid = const Uuid();

  Future<List<InspectionTaskModel>> getInspections() async {
    try {
      final response = await _supabase
          .from('inspection_tasks')
          .select('*, user:users(id, name, email)')
          .order('createdAt', ascending: false);

      return (response as List)
          .map((json) => InspectionTaskModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch inspections: $e');
    }
  }

  Future<InspectionTaskModel> getInspectionById(String id) async {
    try {
      final response = await _supabase
          .from('inspection_tasks')
          .select('*, user:users(id, name, email)')
          .eq('id', id)
          .single();

      return InspectionTaskModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch inspection: $e');
    }
  }

  Future<List<InspectionTaskModel>> getUserInspections(String userId) async {
    try {
      final response = await _supabase
          .from('inspection_tasks')
          .select('*, user:users(id, name, email)')
          .eq('userId', userId)
          .order('datetime', ascending: false);

      return (response as List)
          .map((json) => InspectionTaskModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch user inspections: $e');
    }
  }

  Future<InspectionTaskModel> createInspection(Map<String, dynamic> data) async {
    try {
      // Generate inspection code
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final inspectionCode = 'INSP-${timestamp.substring(timestamp.length - 8)}';

      // Get current user ID from session
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final inspectionData = {
        'inspectioncode': inspectionCode,
        'userId': userId,
        'datetime': data['datetime'].toIso8601String(),
        'state': data['state'],
        'district': data['district'],
        'taluka': data['taluka'],
        'location': data['location'],
        'addressland': data['addressland'],
        'targetType': data['targetType'],
        'typeofpremises': data['typeofpremises'],
        'visitpurpose': data['visitpurpose'],
        'equipment': data['equipment'] ?? [],
        'totaltarget': data['totaltarget'],
        'achievedtarget': data['achievedtarget'],
        'status': 'scheduled',
      };

      final response = await _supabase
          .from('inspection_tasks')
          .insert(inspectionData)
          .select('*, user:users(id, name, email)')
          .single();

      return InspectionTaskModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create inspection: $e');
    }
  }

  Future<InspectionTaskModel> updateInspection({
    required String id,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final response = await _supabase
          .from('inspection_tasks')
          .update(updates)
          .eq('id', id)
          .select('*, user:users(id, name, email)')
          .single();

      return InspectionTaskModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update inspection: $e');
    }
  }

  Future<void> deleteInspection(String id) async {
    try {
      // Check if inspection has related field executions
      final executions = await _supabase
          .from('field_executions')
          .select('id')
          .eq('inspectionid', id)
          .limit(1);

      if ((executions as List).isNotEmpty) {
        throw Exception('Cannot delete inspection: It has related field executions');
      }

      await _supabase.from('inspection_tasks').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete inspection: $e');
    }
  }

  Future<InspectionTaskModel> updateInspectionStatus({
    required String id,
    required String status,
  }) async {
    try {
      return await updateInspection(
        id: id,
        updates: {'status': status},
      );
    } catch (e) {
      throw Exception('Failed to update inspection status: $e');
    }
  }

  Future<Map<String, int>> getInspectionStats() async {
    try {
      final response = await _supabase
          .from('inspection_tasks')
          .select('status');

      final data = response as List;
      final stats = <String, int>{
        'total': data.length,
        'scheduled': 0,
        'in-progress': 0,
        'completed': 0,
        'cancelled': 0,
      };

      for (final item in data) {
        final status = item['status'] as String;
        stats[status] = (stats[status] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      throw Exception('Failed to fetch inspection stats: $e');
    }
  }

  Future<List<FieldExecutionModel>> getInspectionExecutions(String inspectionId) async {
    try {
      final response = await _supabase
          .from('field_executions')
          .select('*, user:users(id, name, email)')
          .eq('inspectionid', inspectionId)
          .order('createdAt', ascending: false);

      return (response as List)
          .map((json) => FieldExecutionModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch inspection executions: $e');
    }
  }
}
