import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/field_execution_model.dart';
import '../models/seizure_model.dart';  // Contains SeizureModel, LabSampleModel, FIRCaseModel
import '../models/scan_result_model.dart';

class FieldOfficerService {
  final _supabase = Supabase.instance.client;

  // ============= Field Execution Operations =============
  
  Future<List<FieldExecutionModel>> getFieldExecutions({
    String? status,
    String? district,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _supabase
          .from('field_executions')
          .select('*, assigned_officer:users(id, name, email)');

      if (status != null && status != 'all') {
        query = query.eq('status', status);
      }
      if (district != null) {
        query = query.eq('district', district);
      }
      if (startDate != null) {
        query = query.gte('scheduled_date', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('scheduled_date', endDate.toIso8601String());
      }

      final response = await query.order('scheduled_date', ascending: false);
      
      return (response as List)
          .map((json) => FieldExecutionModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch field executions: $e');
    }
  }

  Future<FieldExecutionModel> createFieldExecution(Map<String, dynamic> data) async {
    try {
      // Generate execution code
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final executionCode = 'FE-${timestamp.substring(timestamp.length - 8)}';

      final executionData = {
        'execution_code': executionCode,
        'location': data['location'],
        'district': data['district'],
        'scheduled_date': data['scheduled_date'].toIso8601String(),
        'inspection_type': data['inspection_type'],
        'assigned_officer_id': _supabase.auth.currentUser?.id,
        'status': 'scheduled',
        'remarks': data['remarks'],
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('field_executions')
          .insert(executionData)
          .select()
          .single();

      return FieldExecutionModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create field execution: $e');
    }
  }

  Future<void> updateFieldExecutionStatus(String id, String status) async {
    try {
      await _supabase
          .from('field_executions')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to update execution status: $e');
    }
  }

  // ============= Seizure Operations =============
  
  Future<List<SeizureModel>> getSeizures({
    String? status,
    String? fieldExecutionId,
  }) async {
    try {
      var query = _supabase
          .from('seizures')
          .select('*, field_execution:field_executions(*)');

      if (status != null && status != 'all') {
        query = query.eq('status', status);
      }
      if (fieldExecutionId != null) {
        query = query.eq('field_execution_id', fieldExecutionId);
      }

      final response = await query.order('created_at', ascending: false);
      
      return (response as List)
          .map((json) => SeizureModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch seizures: $e');
    }
  }

  Future<SeizureModel> createSeizure(Map<String, dynamic> data) async {
    try {
      // Generate seizure code
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final seizureCode = 'SEIZ-${timestamp.substring(timestamp.length - 8)}';

      final seizureData = {
        'seizure_code': seizureCode,
        'field_execution_id': data['field_execution_id'],
        'location': data['location'],
        'district': data['district'],
        'taluka': data['taluka'],
        'premises_type': data['premises_type'],
        'fertilizer_type': data['fertilizer_type'],
        'batch_no': data['batch_no'],
        'quantity': data['quantity'],
        'estimated_value': data['estimated_value'],
        'witness_name': data['witness_name'],
        'evidence_photos': data['evidence_photos'] ?? [],
        'video_evidence': data['video_evidence'],
        'status': 'pending',
        'seizure_date': data['seizure_date'].toIso8601String(),
        'memo_no': data['memo_no'],
        'officer_name': data['officer_name'],
        'remarks': data['remarks'],
        'user_id': _supabase.auth.currentUser?.id,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('seizures')
          .insert(seizureData)
          .select()
          .single();

      return SeizureModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create seizure: $e');
    }
  }

  // ============= Lab Sample Operations =============
  
  Future<LabSampleModel> sendToLab(Map<String, dynamic> data) async {
    try {
      // Generate sample code
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final sampleCode = 'LAB-${timestamp.substring(timestamp.length - 8)}';

      final sampleData = {
        'sample_code': sampleCode,
        'seizure_id': data['seizure_id'],
        'department': 'Quality Control',
        'sample_desc': data['sample_desc'],
        'district': data['district'],
        'status': 'in-transit',
        'collected_at': DateTime.now().toIso8601String(),
        'dispatched_at': DateTime.now().toIso8601String(),
        'under_testing': false,
        'officer_name': data['officer_name'],
        'remarks': data['remarks'],
        'user_id': _supabase.auth.currentUser?.id,
      };

      final response = await _supabase
          .from('lab_samples')
          .insert(sampleData)
          .select()
          .single();

      // Update seizure status
      await updateSeizureStatus(data['seizure_id'], 'dispatched');

      return LabSampleModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to send sample to lab: $e');
    }
  }

  Future<void> updateSeizureStatus(String id, String status) async {
    try {
      await _supabase
          .from('seizures')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to update seizure status: $e');
    }
  }

  // ============= FIR Case Operations =============
  
  Future<FIRCaseModel> fileFIRCase(Map<String, dynamic> data) async {
    try {
      // Generate FIR code
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final firCode = 'FIR-${timestamp.substring(timestamp.length - 8)}';

      final firData = {
        'fir_code': firCode,
        'police_station': data['police_station'],
        'accused_party': data['accused_party'],
        'suspect_name': data['suspect_name'],
        'entity_type': data['entity_type'],
        'street1': data['street1'],
        'street2': data['street2'],
        'village': data['village'],
        'district': data['district'],
        'state': data['state'],
        'license_no': data['license_no'],
        'contact_no': data['contact_no'],
        'brand_name': data['brand_name'],
        'fertilizer_type': data['fertilizer_type'],
        'batch_no': data['batch_no'],
        'manufacture_date': data['manufacture_date']?.toIso8601String(),
        'expiry_date': data['expiry_date']?.toIso8601String(),
        'violation_type': data['violation_type'],
        'evidence': data['evidence'],
        'remarks': data['remarks'],
        'user_id': _supabase.auth.currentUser?.id,
        'lab_sample_id': data['lab_sample_id'],
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('fir_cases')
          .insert(firData)
          .select()
          .single();

      return FIRCaseModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to file FIR case: $e');
    }
  }

  // ============= Product Scan Operations =============
  
  Future<ScanResultModel> scanProduct(String code) async {
    try {
      // Check product authenticity in database
      final response = await _supabase
          .from('products')
          .select()
          .eq('batch_no', code)
          .maybeSingle();

      if (response != null) {
        // Product found - check for violations
        final violations = await checkProductViolations(response);
        
        return ScanResultModel(
          id: response['id'],
          company: response['company'],
          product: response['product_name'],
          batchNumber: code,
          authenticityScore: violations.isEmpty ? 95.0 : 45.0,
          issues: violations,
          recommendation: violations.isEmpty ? 'Authentic' : 'Suspicious',
          geoLocation: response['location'],
          timestamp: DateTime.now().toIso8601String(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      } else {
        // Product not found - likely counterfeit
        return ScanResultModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          company: 'Unknown',
          product: 'Unknown Product',
          batchNumber: code,
          authenticityScore: 0.0,
          issues: ['Product not found in database', 'Possible counterfeit'],
          recommendation: 'Counterfeit',
          geoLocation: 'Unknown',
          timestamp: DateTime.now().toIso8601String(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
    } catch (e) {
      throw Exception('Failed to scan product: $e');
    }
  }

  Future<List<String>> checkProductViolations(Map<String, dynamic> product) async {
    final violations = <String>[];
    
    // Check expiry date
    if (product['expiry_date'] != null) {
      final expiryDate = DateTime.parse(product['expiry_date']);
      if (expiryDate.isBefore(DateTime.now())) {
        violations.add('Product expired');
      }
    }
    
    // Check for recent complaints
    final complaints = await _supabase
        .from('complaints')
        .select()
        .eq('product_batch', product['batch_no'])
        .limit(1);
    
    if ((complaints as List).isNotEmpty) {
      violations.add('Product has complaints registered');
    }
    
    // Check if manufacturer license is valid
    if (product['manufacturer_license_expired'] == true) {
      violations.add('Manufacturer license expired');
    }
    
    return violations;
  }

  // ============= Dashboard Statistics =============
  
  Future<Map<String, dynamic>> getFieldOfficerStats() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      // Get inspection count
      final inspections = await _supabase
          .from('field_executions')
          .select('id')
          .eq('assigned_officer_id', userId)
          .count();
      
      // Get seizure count
      final seizures = await _supabase
          .from('seizures')
          .select('id')
          .eq('user_id', userId)
          .count();
      
      // Get pending tasks
      final pendingTasks = await _supabase
          .from('field_executions')
          .select('id')
          .eq('assigned_officer_id', userId)
          .eq('status', 'scheduled')
          .count();
      
      // Get this month's performance
      final startOfMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
      final monthlyInspections = await _supabase
          .from('field_executions')
          .select('id')
          .eq('assigned_officer_id', userId)
          .gte('created_at', startOfMonth.toIso8601String())
          .count();

      return {
        'totalInspections': inspections,
        'totalSeizures': seizures,
        'pendingTasks': pendingTasks,
        'monthlyInspections': monthlyInspections,
      };
    } catch (e) {
      throw Exception('Failed to fetch statistics: $e');
    }
  }

  // ============= Upload Operations =============
  
  Future<String> uploadEvidence(String filePath, String type) async {
    try {
      final file = await _supabase.storage
          .from('evidence')
          .upload(
            '$type/${DateTime.now().millisecondsSinceEpoch}.jpg',
            filePath as dynamic,
          );
      
      final url = _supabase.storage
          .from('evidence')
          .getPublicUrl(file);
      
      return url;
    } catch (e) {
      throw Exception('Failed to upload evidence: $e');
    }
  }

  // ============= Notification Operations =============
  
  Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return [];
      }
      
      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .eq('is_read', false)
          .order('created_at', ascending: false)
          .limit(10);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  Future<void> markNotificationAsRead(String id) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }
}