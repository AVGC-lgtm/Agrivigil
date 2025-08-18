import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';

class LegalService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all FIR cases
  Future<List<Map<String, dynamic>>> getFIRCases({
    String? status,
    String? caseType,
    String? assignedTo,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      var query = _supabase.from('fir_cases').select('''
            *,
            seizures(*),
            lab_samples(*),
            users!filed_by(full_name, email, designation),
            legal_officers:users!assigned_to(full_name, email)
          ''');

      if (status != null && status.isNotEmpty) {
        query = query.eq('status', status);
      }

      if (caseType != null && caseType.isNotEmpty) {
        query = query.eq('case_type', caseType);
      }

      if (assignedTo != null && assignedTo.isNotEmpty) {
        query = query.eq('assigned_to', assignedTo);
      }

      if (startDate != null) {
        query = query.gte('filed_date', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('filed_date', endDate.toIso8601String());
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
            'fir_number.ilike.%$searchQuery%,accused_name.ilike.%$searchQuery%,case_title.ilike.%$searchQuery%');
      }

      final response = await query
          .order('filed_date', ascending: false)
          .limit(limit)
          .range(offset, offset + limit - 1);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch FIR cases: $e');
    }
  }

  // Get FIR case by ID
  Future<Map<String, dynamic>> getFIRCaseById(String caseId) async {
    try {
      final response = await _supabase.from('fir_cases').select('''
            *,
            seizures(*),
            lab_samples(*),
            users!filed_by(full_name, email, designation),
            legal_officers:users!assigned_to(full_name, email),
            court_hearings(*),
            case_documents(*),
            case_evidences(*)
          ''').eq('id', caseId).single();

      return response;
    } catch (e) {
      throw Exception('Failed to fetch FIR case details: $e');
    }
  }

  // File new FIR case
  Future<Map<String, dynamic>> fileNewFIRCase({
    required String firNumber,
    required String caseTitle,
    required String caseType,
    required DateTime filedDate,
    required String policeStation,
    required String accusedName,
    String? accusedAddress,
    String? accusedContact,
    required Map<String, dynamic> offenseDetails,
    String? seizureId,
    String? labSampleId,
    List<String>? sections,
    List<Map<String, dynamic>>? witnesses,
    Map<String, dynamic>? additionalDetails,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final caseData = {
        'fir_number': firNumber,
        'case_title': caseTitle,
        'case_type': caseType,
        'filed_date': filedDate.toIso8601String(),
        'police_station': policeStation,
        'accused_name': accusedName,
        'accused_address': accusedAddress,
        'accused_contact': accusedContact,
        'offense_details': offenseDetails,
        'seizure_id': seizureId,
        'lab_sample_id': labSampleId,
        'sections': sections ?? [],
        'witnesses': witnesses ?? [],
        'additional_details': additionalDetails ?? {},
        'status': 'filed',
        'filed_by': userId,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response =
          await _supabase.from('fir_cases').insert(caseData).select().single();

      // Update related seizure if exists
      if (seizureId != null) {
        await _supabase
            .from('seizures')
            .update({'fir_filed': true, 'fir_case_id': response['id']}).eq(
                'id', seizureId);
      }

      // Log activity
      await _logLegalActivity(
        caseId: response['id'],
        activity: 'case_filed',
        details: {'fir_number': firNumber},
      );

      return response;
    } catch (e) {
      throw Exception('Failed to file FIR case: $e');
    }
  }

  // Update FIR case
  Future<Map<String, dynamic>> updateFIRCase({
    required String caseId,
    String? status,
    String? assignedTo,
    Map<String, dynamic>? additionalDetails,
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
      if (assignedTo != null) updateData['assigned_to'] = assignedTo;
      if (additionalDetails != null) {
        updateData['additional_details'] = additionalDetails;
      }
      if (updateNotes != null) updateData['update_notes'] = updateNotes;

      final response = await _supabase
          .from('fir_cases')
          .update(updateData)
          .eq('id', caseId)
          .select()
          .single();

      // Log status change
      if (status != null) {
        await _logLegalActivity(
          caseId: caseId,
          activity: 'status_change',
          details: {'new_status': status, 'notes': updateNotes},
        );
      }

      return response;
    } catch (e) {
      throw Exception('Failed to update FIR case: $e');
    }
  }

  // Schedule court hearing
  Future<Map<String, dynamic>> scheduleCourtHearing({
    required String caseId,
    required DateTime hearingDate,
    required String hearingType,
    required String courtName,
    String? judgeName,
    String? courtRoom,
    String? purpose,
    Map<String, dynamic>? hearingDetails,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final hearingData = {
        'case_id': caseId,
        'hearing_date': hearingDate.toIso8601String(),
        'hearing_type': hearingType,
        'court_name': courtName,
        'judge_name': judgeName,
        'court_room': courtRoom,
        'purpose': purpose,
        'hearing_details': hearingDetails ?? {},
        'status': 'scheduled',
        'scheduled_by': userId,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('court_hearings')
          .insert(hearingData)
          .select()
          .single();

      // Update case status
      await updateFIRCase(
        caseId: caseId,
        status: 'hearing_scheduled',
      );

      // Log activity
      await _logLegalActivity(
        caseId: caseId,
        activity: 'hearing_scheduled',
        details: {
          'hearing_date': hearingDate.toIso8601String(),
          'hearing_type': hearingType,
        },
      );

      return response;
    } catch (e) {
      throw Exception('Failed to schedule court hearing: $e');
    }
  }

  // Update hearing outcome
  Future<Map<String, dynamic>> updateHearingOutcome({
    required String hearingId,
    required String outcome,
    required Map<String, dynamic> outcomeDetails,
    DateTime? nextHearingDate,
    String? courtOrder,
    List<String>? documents,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final updateData = {
        'outcome': outcome,
        'outcome_details': outcomeDetails,
        'next_hearing_date': nextHearingDate?.toIso8601String(),
        'court_order': courtOrder,
        'documents': documents ?? [],
        'status': 'completed',
        'updated_by': userId,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('court_hearings')
          .update(updateData)
          .eq('id', hearingId)
          .select('*, fir_cases(*)')
          .single();

      // Update case status based on outcome
      String newStatus = 'hearing_completed';
      if (outcome == 'convicted') {
        newStatus = 'convicted';
      } else if (outcome == 'acquitted') {
        newStatus = 'acquitted';
      } else if (outcome == 'adjourned' && nextHearingDate != null) {
        newStatus = 'adjourned';
        // Schedule next hearing
        await scheduleCourtHearing(
          caseId: response['case_id'],
          hearingDate: nextHearingDate,
          hearingType: 'continued',
          courtName: response['court_name'],
          judgeName: response['judge_name'],
          purpose: 'Continued hearing',
        );
      }

      await updateFIRCase(
        caseId: response['case_id'],
        status: newStatus,
      );

      return response;
    } catch (e) {
      throw Exception('Failed to update hearing outcome: $e');
    }
  }

  // Add case evidence
  Future<Map<String, dynamic>> addCaseEvidence({
    required String caseId,
    required String evidenceType,
    required String description,
    String? evidenceNumber,
    String? collectedFrom,
    DateTime? collectedDate,
    Map<String, dynamic>? evidenceDetails,
    List<String>? attachments,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final evidenceData = {
        'case_id': caseId,
        'evidence_type': evidenceType,
        'evidence_number': evidenceNumber,
        'description': description,
        'collected_from': collectedFrom,
        'collected_date': collectedDate?.toIso8601String(),
        'evidence_details': evidenceDetails ?? {},
        'attachments': attachments ?? [],
        'added_by': userId,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('case_evidences')
          .insert(evidenceData)
          .select()
          .single();

      // Log activity
      await _logLegalActivity(
        caseId: caseId,
        activity: 'evidence_added',
        details: {
          'evidence_type': evidenceType,
          'evidence_number': evidenceNumber,
        },
      );

      return response;
    } catch (e) {
      throw Exception('Failed to add case evidence: $e');
    }
  }

  // Upload legal document
  Future<String> uploadLegalDocument({
    required String caseId,
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
          'legal-documents/$caseId/${documentType}_${timestamp}_$fileName';

      // Upload to storage
      await _supabase.storage
          .from('legal-documents')
          .uploadBinary(filePath, Uint8List.fromList(fileBytes));

      final url =
          _supabase.storage.from('legal-documents').getPublicUrl(filePath);

      // Save document reference
      await _supabase.from('case_documents').insert({
        'case_id': caseId,
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

  // Get case statistics
  Future<Map<String, dynamic>> getCaseStatistics({
    String? districtId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _supabase
          .from('fir_cases')
          .select('id, status, filed_date, case_type');

      if (startDate != null) {
        query = query.gte('filed_date', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('filed_date', endDate.toIso8601String());
      }

      final cases = await query;

      // Calculate statistics
      final stats = <String, dynamic>{
        'total': cases.length,
        'filed': cases.where((c) => c['status'] == 'filed').length,
        'under_investigation':
            cases.where((c) => c['status'] == 'under_investigation').length,
        'hearing_scheduled':
            cases.where((c) => c['status'] == 'hearing_scheduled').length,
        'in_court': cases.where((c) => c['status'] == 'in_court').length,
        'convicted': cases.where((c) => c['status'] == 'convicted').length,
        'acquitted': cases.where((c) => c['status'] == 'acquitted').length,
        'closed': cases.where((c) => c['status'] == 'closed').length,
      };

      // Case type breakdown
      final caseTypes = <String, int>{};
      for (final c in cases) {
        final type = c['case_type'] as String;
        caseTypes[type] = (caseTypes[type] ?? 0) + 1;
      }
      stats['case_types'] = caseTypes;

      // Monthly trend
      final monthlyTrend = _calculateMonthlyTrend(cases);
      stats['monthly_trend'] = monthlyTrend;

      return stats;
    } catch (e) {
      throw Exception('Failed to fetch case statistics: $e');
    }
  }

  // Get pending cases for officer
  Future<List<Map<String, dynamic>>> getPendingCasesForOfficer(
    String officerId,
  ) async {
    try {
      final response = await _supabase
          .from('fir_cases')
          .select('*, seizures(*), court_hearings(*)')
          .eq('assigned_to', officerId)
          .inFilter('status', [
        'filed',
        'under_investigation',
        'hearing_scheduled',
        'in_court',
        'adjourned'
      ]).order('filed_date', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch pending cases: $e');
    }
  }

  // Get upcoming hearings
  Future<List<Map<String, dynamic>>> getUpcomingHearings({
    String? officerId,
    int daysAhead = 30,
  }) async {
    try {
      final today = DateTime.now();
      final endDate = today.add(Duration(days: daysAhead));

      var query = _supabase
          .from('court_hearings')
          .select('*, fir_cases(*)')
          .gte('hearing_date', today.toIso8601String())
          .lte('hearing_date', endDate.toIso8601String())
          .eq('status', 'scheduled');

      if (officerId != null) {
        query = query.eq('fir_cases.assigned_to', officerId);
      }

      final response = await query.order('hearing_date', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch upcoming hearings: $e');
    }
  }

  // Generate legal notice
  Future<Map<String, dynamic>> generateLegalNotice({
    required String caseId,
    required String noticeType,
    required String recipientName,
    required String recipientAddress,
    required Map<String, dynamic> noticeContent,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final noticeData = {
        'case_id': caseId,
        'notice_type': noticeType,
        'recipient_name': recipientName,
        'recipient_address': recipientAddress,
        'notice_content': noticeContent,
        'status': 'generated',
        'generated_by': userId,
        'generated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('legal_notices')
          .insert(noticeData)
          .select()
          .single();

      return response;
    } catch (e) {
      throw Exception('Failed to generate legal notice: $e');
    }
  }

  // Close case
  Future<void> closeCase({
    required String caseId,
    required String closureReason,
    required Map<String, dynamic> closureDetails,
  }) async {
    try {
      await updateFIRCase(
        caseId: caseId,
        status: 'closed',
        additionalDetails: {
          'closure_reason': closureReason,
          'closure_details': closureDetails,
          'closed_at': DateTime.now().toIso8601String(),
        },
      );

      // Log activity
      await _logLegalActivity(
        caseId: caseId,
        activity: 'case_closed',
        details: {
          'reason': closureReason,
          'details': closureDetails,
        },
      );
    } catch (e) {
      throw Exception('Failed to close case: $e');
    }
  }

  // Private helper methods
  Future<void> _logLegalActivity({
    required String caseId,
    required String activity,
    Map<String, dynamic>? details,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      await _supabase.from('legal_activities').insert({
        'case_id': caseId,
        'activity': activity,
        'details': details ?? {},
        'created_by': userId,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Failed to log legal activity: $e');
    }
  }

  Map<String, int> _calculateMonthlyTrend(List<dynamic> cases) {
    final trend = <String, int>{};
    for (final c in cases) {
      final date = DateTime.parse(c['filed_date']);
      final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      trend[monthKey] = (trend[monthKey] ?? 0) + 1;
    }
    return trend;
  }
}
