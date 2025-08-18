import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';

class AgriFormService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all available forms
  Future<List<Map<String, dynamic>>> getAvailableForms({
    String? category,
    String? status,
    String? searchQuery,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      var query = _supabase.from('agri_forms').select('''
            *,
            form_categories(*),
            form_fields(*)
          ''').eq('is_active', true);

      if (category != null && category.isNotEmpty) {
        query = query.eq('category_id', category);
      }

      if (status != null && status.isNotEmpty) {
        query = query.eq('status', status);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
            'form_name.ilike.%$searchQuery%,description.ilike.%$searchQuery%');
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(limit)
          .range(offset, offset + limit - 1);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch available forms: $e');
    }
  }

  // Get form by ID with all fields
  Future<Map<String, dynamic>> getFormById(String formId) async {
    try {
      final response = await _supabase.from('agri_forms').select('''
            *,
            form_categories(*),
            form_fields(*),
            form_sections(*)
          ''').eq('id', formId).single();

      return response;
    } catch (e) {
      throw Exception('Failed to fetch form details: $e');
    }
  }

  // Submit form
  Future<Map<String, dynamic>> submitForm({
    required String formId,
    required Map<String, dynamic> formData,
    required String farmerName,
    required String farmerContact,
    String? farmerAddress,
    String? farmerAadhaar,
    String? landDetails,
    Map<String, dynamic>? additionalInfo,
    List<String>? attachments,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;

      final submissionData = {
        'form_id': formId,
        'form_data': formData,
        'farmer_name': farmerName,
        'farmer_contact': farmerContact,
        'farmer_address': farmerAddress,
        'farmer_aadhaar': farmerAadhaar,
        'land_details': landDetails,
        'additional_info': additionalInfo ?? {},
        'attachments': attachments ?? [],
        'status': 'submitted',
        'submitted_by': userId,
        'submitted_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('form_submissions')
          .insert(submissionData)
          .select()
          .single();

      // Send notification to farmer
      await _sendSubmissionNotification(
        submissionId: response['id'],
        farmerContact: farmerContact,
        formId: formId,
      );

      // Log activity
      await _logFormActivity(
        submissionId: response['id'],
        activity: 'form_submitted',
        details: {'form_id': formId, 'farmer': farmerName},
      );

      return response;
    } catch (e) {
      throw Exception('Failed to submit form: $e');
    }
  }

  // Get form submissions
  Future<List<Map<String, dynamic>>> getFormSubmissions({
    String? formId,
    String? status,
    String? submittedBy,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      var query = _supabase.from('form_submissions').select('''
            *,
            agri_forms(*),
            users!submitted_by(full_name, email),
            approver:users!approved_by(full_name)
          ''');

      if (formId != null && formId.isNotEmpty) {
        query = query.eq('form_id', formId);
      }

      if (status != null && status.isNotEmpty) {
        query = query.eq('status', status);
      }

      if (submittedBy != null && submittedBy.isNotEmpty) {
        query = query.eq('submitted_by', submittedBy);
      }

      if (startDate != null) {
        query = query.gte('submitted_at', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('submitted_at', endDate.toIso8601String());
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
            'farmer_name.ilike.%$searchQuery%,farmer_contact.ilike.%$searchQuery%,submission_code.ilike.%$searchQuery%');
      }

      final response = await query
          .order('submitted_at', ascending: false)
          .limit(limit)
          .range(offset, offset + limit - 1);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch form submissions: $e');
    }
  }

  // Get submission by ID
  Future<Map<String, dynamic>> getSubmissionById(String submissionId) async {
    try {
      final response = await _supabase.from('form_submissions').select('''
            *,
            agri_forms(*),
            users!submitted_by(full_name, email, designation),
            approver:users!approved_by(full_name),
            form_activities(*),
            form_feedback(*)
          ''').eq('id', submissionId).single();

      return response;
    } catch (e) {
      throw Exception('Failed to fetch submission details: $e');
    }
  }

  // Update submission status
  Future<Map<String, dynamic>> updateSubmissionStatus({
    required String submissionId,
    required String status,
    String? remarks,
    Map<String, dynamic>? reviewData,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final updateData = <String, dynamic>{
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
        'updated_by': userId,
      };

      if (status == 'approved' || status == 'rejected') {
        updateData['approved_by'] = userId;
        updateData['approved_at'] = DateTime.now().toIso8601String();
        updateData['approval_remarks'] = remarks;
      }

      if (reviewData != null) {
        updateData['review_data'] = reviewData;
      }

      final response = await _supabase
          .from('form_submissions')
          .update(updateData)
          .eq('id', submissionId)
          .select()
          .single();

      // Send notification to farmer
      await _sendStatusUpdateNotification(
        submissionId: submissionId,
        newStatus: status,
        remarks: remarks,
      );

      // Log activity
      await _logFormActivity(
        submissionId: submissionId,
        activity: 'status_updated',
        details: {'new_status': status, 'remarks': remarks},
      );

      return response;
    } catch (e) {
      throw Exception('Failed to update submission status: $e');
    }
  }

  // Approve submission
  Future<Map<String, dynamic>> approveSubmission({
    required String submissionId,
    String? approvalRemarks,
    Map<String, dynamic>? approvalData,
  }) async {
    return updateSubmissionStatus(
      submissionId: submissionId,
      status: 'approved',
      remarks: approvalRemarks,
      reviewData: approvalData,
    );
  }

  // Reject submission
  Future<Map<String, dynamic>> rejectSubmission({
    required String submissionId,
    required String rejectionReason,
    Map<String, dynamic>? rejectionData,
  }) async {
    return updateSubmissionStatus(
      submissionId: submissionId,
      status: 'rejected',
      remarks: rejectionReason,
      reviewData: rejectionData,
    );
  }

  // Request additional information
  Future<void> requestAdditionalInfo({
    required String submissionId,
    required String requestDetails,
    List<String>? requiredDocuments,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Update submission status
      await updateSubmissionStatus(
        submissionId: submissionId,
        status: 'pending_info',
        remarks: requestDetails,
      );

      // Create information request
      await _supabase.from('information_requests').insert({
        'submission_id': submissionId,
        'request_details': requestDetails,
        'required_documents': requiredDocuments ?? [],
        'requested_by': userId,
        'requested_at': DateTime.now().toIso8601String(),
        'status': 'pending',
      });

      // Send notification
      await _sendInfoRequestNotification(
        submissionId: submissionId,
        requestDetails: requestDetails,
      );
    } catch (e) {
      throw Exception('Failed to request additional information: $e');
    }
  }

  // Submit additional information
  Future<Map<String, dynamic>> submitAdditionalInfo({
    required String submissionId,
    required Map<String, dynamic> additionalData,
    List<String>? documents,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;

      // Update submission with additional info
      final response = await _supabase
          .from('form_submissions')
          .update({
            'additional_info': additionalData,
            'additional_documents': documents ?? [],
            'status': 'under_review',
            'info_submitted_at': DateTime.now().toIso8601String(),
          })
          .eq('id', submissionId)
          .select()
          .single();

      // Update information request status
      await _supabase
          .from('information_requests')
          .update({
            'status': 'completed',
            'completed_at': DateTime.now().toIso8601String(),
          })
          .eq('submission_id', submissionId)
          .eq('status', 'pending');

      // Log activity
      await _logFormActivity(
        submissionId: submissionId,
        activity: 'additional_info_submitted',
        details: {'submitted_by': userId},
      );

      return response;
    } catch (e) {
      throw Exception('Failed to submit additional information: $e');
    }
  }

  // Get form categories
  Future<List<Map<String, dynamic>>> getFormCategories() async {
    try {
      final response = await _supabase
          .from('form_categories')
          .select('*')
          .eq('is_active', true)
          .order('display_order', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch form categories: $e');
    }
  }

  // Get farmer submissions
  Future<List<Map<String, dynamic>>> getFarmerSubmissions({
    required String farmerContact,
    String? status,
    int limit = 50,
  }) async {
    try {
      var query = _supabase.from('form_submissions').select('''
            *,
            agri_forms(form_name, category_id),
            form_feedback(*)
          ''').eq('farmer_contact', farmerContact);

      if (status != null && status.isNotEmpty) {
        query = query.eq('status', status);
      }

      final response =
          await query.order('submitted_at', ascending: false).limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch farmer submissions: $e');
    }
  }

  // Add feedback to submission
  Future<Map<String, dynamic>> addFeedback({
    required String submissionId,
    required int rating,
    String? feedback,
    String? farmerName,
    String? farmerContact,
  }) async {
    try {
      final feedbackData = {
        'submission_id': submissionId,
        'rating': rating,
        'feedback': feedback,
        'farmer_name': farmerName,
        'farmer_contact': farmerContact,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('form_feedback')
          .insert(feedbackData)
          .select()
          .single();

      return response;
    } catch (e) {
      throw Exception('Failed to add feedback: $e');
    }
  }

  // Get form statistics
  Future<Map<String, dynamic>> getFormStatistics({
    String? formId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _supabase
          .from('form_submissions')
          .select('id, status, submitted_at, form_id');

      if (formId != null) {
        query = query.eq('form_id', formId);
      }

      if (startDate != null) {
        query = query.gte('submitted_at', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('submitted_at', endDate.toIso8601String());
      }

      final submissions = await query;

      // Calculate statistics
      final stats = {
        'total_submissions': submissions.length,
        'submitted':
            submissions.where((s) => s['status'] == 'submitted').length,
        'under_review':
            submissions.where((s) => s['status'] == 'under_review').length,
        'approved': submissions.where((s) => s['status'] == 'approved').length,
        'rejected': submissions.where((s) => s['status'] == 'rejected').length,
        'pending_info':
            submissions.where((s) => s['status'] == 'pending_info').length,
        'approval_rate': submissions.isNotEmpty
            ? ((submissions.where((s) => s['status'] == 'approved').length /
                        submissions.length) *
                    100)
                .toStringAsFixed(2)
            : '0',
      };

      // Monthly trend
      final monthlyTrend = _calculateMonthlyTrend(submissions);
      stats['monthly_trend'] = monthlyTrend;

      return stats;
    } catch (e) {
      throw Exception('Failed to fetch form statistics: $e');
    }
  }

  // Upload form attachment
  Future<String> uploadFormAttachment({
    required String submissionId,
    required String fileName,
    required List<int> fileBytes,
    String? documentType,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = 'form-attachments/$submissionId/${timestamp}_$fileName';

      await _supabase.storage
          .from('form-attachments')
          .uploadBinary(filePath, Uint8List.fromList(fileBytes));

      final url =
          _supabase.storage.from('form-attachments').getPublicUrl(filePath);

      // Save attachment reference
      await _supabase.from('form_attachments').insert({
        'submission_id': submissionId,
        'file_name': fileName,
        'file_url': url,
        'document_type': documentType,
        'uploaded_at': DateTime.now().toIso8601String(),
      });

      return url;
    } catch (e) {
      throw Exception('Failed to upload attachment: $e');
    }
  }

  // Private helper methods
  Future<void> _sendSubmissionNotification({
    required String submissionId,
    required String farmerContact,
    required String formId,
  }) async {
    try {
      // Implementation for sending SMS/notification to farmer
      await _supabase.from('notifications').insert({
        'type': 'form_submission',
        'recipient': farmerContact,
        'title': 'Form Submitted Successfully',
        'message':
            'Your form has been submitted successfully. Submission ID: $submissionId',
        'data': {'submission_id': submissionId, 'form_id': formId},
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Failed to send notification: $e');
    }
  }

  Future<void> _sendStatusUpdateNotification({
    required String submissionId,
    required String newStatus,
    String? remarks,
  }) async {
    try {
      // Get submission details
      final submission = await getSubmissionById(submissionId);

      await _supabase.from('notifications').insert({
        'type': 'status_update',
        'recipient': submission['farmer_contact'],
        'title': 'Form Status Updated',
        'message': 'Your form status has been updated to: $newStatus',
        'data': {
          'submission_id': submissionId,
          'status': newStatus,
          'remarks': remarks,
        },
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Failed to send status notification: $e');
    }
  }

  Future<void> _sendInfoRequestNotification({
    required String submissionId,
    required String requestDetails,
  }) async {
    try {
      // Get submission details
      final submission = await getSubmissionById(submissionId);

      await _supabase.from('notifications').insert({
        'type': 'info_request',
        'recipient': submission['farmer_contact'],
        'title': 'Additional Information Required',
        'message': requestDetails,
        'data': {'submission_id': submissionId},
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Failed to send info request notification: $e');
    }
  }

  Future<void> _logFormActivity({
    required String submissionId,
    required String activity,
    Map<String, dynamic>? details,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      await _supabase.from('form_activities').insert({
        'submission_id': submissionId,
        'activity': activity,
        'details': details ?? {},
        'created_by': userId,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Failed to log form activity: $e');
    }
  }

  Map<String, int> _calculateMonthlyTrend(List<dynamic> submissions) {
    final trend = <String, int>{};
    for (final submission in submissions) {
      final date = DateTime.parse(submission['submitted_at']);
      final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      trend[monthKey] = (trend[monthKey] ?? 0) + 1;
    }
    return trend;
  }
}
