import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/qc_models.dart';

class QCService {
  final _supabase = Supabase.instance.client;

  // QC Inspections
  Future<List<QCInspection>> getQCInspections({
    String? status,
    String? processType,
    String? assignedOfficerId,
  }) async {
    try {
      var query = _supabase
          .from('qc_inspections')
          .select('*, assigned_officer:users(id, name, email)');

      if (status != null && status != 'all') {
        query = query.eq('status', status);
      }
      if (processType != null && processType != 'all') {
        query = query.eq('process_type', processType);
      }
      if (assignedOfficerId != null) {
        query = query.eq('assigned_officer_id', assignedOfficerId);
      }

      final response = await query.order('scheduled_date', ascending: false);
      
      // Note: You'll need to map the response to QCInspection model
      // This is a simplified version
      return [];
    } catch (e) {
      throw Exception('Failed to fetch QC inspections: $e');
    }
  }

  Future<QCInspection> createQCInspection(Map<String, dynamic> data) async {
    try {
      // Generate inspection code
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final inspectionCode = 'QC-${timestamp.substring(timestamp.length - 8)}';

      final inspectionData = {
        'inspection_code': inspectionCode,
        'process_type': data['process_type'],
        'scheduled_date': data['scheduled_date'].toIso8601String(),
        'assigned_officer_id': data['assigned_officer_id'],
        'status': 'pending',
        'checkpoints': data['checkpoints'] ?? [],
        'remarks': data['remarks'],
        'priority': data['priority'] ?? 'medium',
        'department': 'QC',
      };

      final response = await _supabase
          .from('qc_inspections')
          .insert(inspectionData)
          .select()
          .single();

      // Map response to QCInspection model
      throw UnimplementedError('Mapping not implemented');
    } catch (e) {
      throw Exception('Failed to create QC inspection: $e');
    }
  }

  Future<void> updateQCInspectionStatus(String id, String status) async {
    try {
      await _supabase
          .from('qc_inspections')
          .update({'status': status, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to update inspection status: $e');
    }
  }

  // Compliance Management
  Future<List<QCCompliance>> getComplianceRules({String? regulationType}) async {
    try {
      var query = _supabase
          .from('qc_compliance_rules')
          .select();

      if (regulationType != null && regulationType != 'all') {
        query = query.eq('regulation_type', regulationType);
      }

      final response = await query.order('created_at', ascending: false);
      
      // Map response to QCCompliance model
      return [];
    } catch (e) {
      throw Exception('Failed to fetch compliance rules: $e');
    }
  }

  Future<QCCompliance> createComplianceRule(Map<String, dynamic> data) async {
    try {
      final response = await _supabase
          .from('qc_compliance_rules')
          .insert(data)
          .select()
          .single();

      // Map response to QCCompliance model
      throw UnimplementedError('Mapping not implemented');
    } catch (e) {
      throw Exception('Failed to create compliance rule: $e');
    }
  }

  // ABC Analysis
  Future<List<ABCAnalysis>> getABCAnalyses({
    String? analysisType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _supabase
          .from('qc_abc_analysis')
          .select('*, analyzed_by_user:users(id, name)');

      if (analysisType != null && analysisType != 'all') {
        query = query.eq('analysis_type', analysisType);
      }
      if (startDate != null) {
        query = query.gte('analysis_date', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('analysis_date', endDate.toIso8601String());
      }

      final response = await query.order('analysis_date', ascending: false);
      
      // Map response to ABCAnalysis model
      return [];
    } catch (e) {
      throw Exception('Failed to fetch ABC analyses: $e');
    }
  }

  Future<ABCAnalysis> performABCAnalysis({
    required String analysisType,
    required String timeRange,
  }) async {
    try {
      // This would typically involve complex calculations
      // For now, we'll create a mock analysis
      
      final analysisData = {
        'analysis_type': analysisType,
        'analysis_date': DateTime.now().toIso8601String(),
        'analyzed_by': _supabase.auth.currentUser?.id,
        'time_range': timeRange,
        'categories': {
          'A': {
            'percentage': 70,
            'items': [],
            'action': 'Increase monitoring frequency'
          },
          'B': {
            'percentage': 20,
            'items': [],
            'action': 'Standard monitoring'
          },
          'C': {
            'percentage': 10,
            'items': [],
            'action': 'Periodic review'
          }
        },
        'recommendations': 'Focus on Category A items for maximum impact',
      };

      final response = await _supabase
          .from('qc_abc_analysis')
          .insert(analysisData)
          .select()
          .single();

      // Map response to ABCAnalysis model
      throw UnimplementedError('Mapping not implemented');
    } catch (e) {
      throw Exception('Failed to perform ABC analysis: $e');
    }
  }

  // Approval Workflow
  Future<List<Map<String, dynamic>>> getPendingApprovals(String approvalLevel) async {
    try {
      final response = await _supabase
          .from('qc_approvals')
          .select('*, approver:users(id, name)')
          .eq('approval_level', approvalLevel)
          .isFilter('decision', null)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch pending approvals: $e');
    }
  }

  Future<void> processApproval({
    required String itemType,
    required String itemId,
    required String decision,
    String? comments,
    List<String>? conditions,
  }) async {
    try {
      final approvalData = {
        'item_type': itemType,
        'item_id': itemId,
        'approver_id': _supabase.auth.currentUser?.id,
        'decision': decision,
        'comments': comments,
        'conditions': conditions ?? [],
        'approval_date': DateTime.now().toIso8601String(),
      };

      await _supabase
          .from('qc_approvals')
          .insert(approvalData);

      // Update the related item status based on decision
      if (itemType == 'inspection') {
        final newStatus = decision == 'approved' ? 'approved' : 'rejected';
        await updateQCInspectionStatus(itemId, newStatus);
      }
    } catch (e) {
      throw Exception('Failed to process approval: $e');
    }
  }

  // Checkpoints
  Future<List<Map<String, dynamic>>> getCheckpointMaster({String? category}) async {
    try {
      var query = _supabase
          .from('qc_checkpoint_master')
          .select();

      if (category != null) {
        query = query.eq('category', category);
      }

      final response = await query.order('checkpoint_name');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch checkpoints: $e');
    }
  }

  // Non-Compliance
  Future<void> recordNonCompliance(Map<String, dynamic> data) async {
    try {
      await _supabase
          .from('qc_non_compliance')
          .insert(data);
    } catch (e) {
      throw Exception('Failed to record non-compliance: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getNonComplianceRecords({
    String? inspectionId,
    String? status,
  }) async {
    try {
      var query = _supabase
          .from('qc_non_compliance')
          .select('*, inspection:qc_inspections(*), checkpoint:qc_checkpoint_master(*)');

      if (inspectionId != null) {
        query = query.eq('inspection_id', inspectionId);
      }
      if (status != null) {
        query = query.eq('status', status);
      }

      final response = await query.order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch non-compliance records: $e');
    }
  }

  // Dashboard Statistics
  Future<Map<String, dynamic>> getQCDashboardStats() async {
    try {
      // Get pending inspections count
      final pendingInspections = await _supabase
          .from('qc_inspections')
          .select('id')
          .eq('status', 'pending')
          .count();

      // Get today's approvals
      final todayStart = DateTime.now().toLocal().toIso8601String().split('T')[0];
      final approvedToday = await _supabase
          .from('qc_approvals')
          .select('id')
          .eq('decision', 'approved')
          .gte('approval_date', todayStart)
          .count();

      // Get non-compliance count
      final nonCompliance = await _supabase
          .from('qc_non_compliance')
          .select('id')
          .eq('status', 'open')
          .count();

      // Get pending lab tests (from lab_samples table)
      final pendingLabTests = await _supabase
          .from('lab_samples')
          .select('id')
          .eq('status', 'in-transit')
          .count();

      return {
        'pendingInspections': pendingInspections,
        'approvedToday': approvedToday,
        'nonCompliance': nonCompliance,
        'pendingLabTests': pendingLabTests,
      };
    } catch (e) {
      throw Exception('Failed to fetch dashboard stats: $e');
    }
  }

  // Test Parameters
  Future<List<Map<String, dynamic>>> getTestParameters({String? productCategory}) async {
    try {
      var query = _supabase
          .from('qc_test_parameters')
          .select();

      if (productCategory != null) {
        query = query.eq('product_category', productCategory);
      }

      final response = await query.order('parameter_name');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch test parameters: $e');
    }
  }

  // Compliance Check
  Future<bool> checkCompliance({
    required String productCategory,
    required Map<String, double> testResults,
  }) async {
    try {
      // Get applicable test parameters
      final parameters = await getTestParameters(productCategory: productCategory);
      
      bool isCompliant = true;
      
      for (final param in parameters) {
        final paramName = param['parameter_name'] as String;
        final minValue = param['min_value'] as double?;
        final maxValue = param['max_value'] as double?;
        final testValue = testResults[paramName];
        
        if (testValue != null) {
          if (minValue != null && testValue < minValue) {
            isCompliant = false;
            break;
          }
          if (maxValue != null && testValue > maxValue) {
            isCompliant = false;
            break;
          }
        }
      }
      
      return isCompliant;
    } catch (e) {
      throw Exception('Failed to check compliance: $e');
    }
  }
}
