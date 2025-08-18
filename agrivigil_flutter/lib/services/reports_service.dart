import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';

class ReportsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Generate inspection report
  Future<Map<String, dynamic>> generateInspectionReport({
    required DateTime startDate,
    required DateTime endDate,
    String? districtId,
    String? inspectorId,
    String? reportFormat,
  }) async {
    try {
      // Fetch inspection data
      var query = _supabase
          .from('field_executions')
          .select('''
            *,
            inspections(*),
            users!created_by(full_name, designation),
            products(*),
            seizures(*)
          ''')
          .gte('execution_date', startDate.toIso8601String())
          .lte('execution_date', endDate.toIso8601String());

      if (districtId != null) {
        query = query.eq('district_id', districtId);
      }

      if (inspectorId != null) {
        query = query.eq('created_by', inspectorId);
      }

      final inspections = await query;

      // Calculate statistics
      final stats = _calculateInspectionStats(inspections);

      // Generate report data
      final reportData = {
        'report_type': 'inspection',
        'period': {
          'start': startDate.toIso8601String(),
          'end': endDate.toIso8601String(),
        },
        'filters': {
          'district_id': districtId,
          'inspector_id': inspectorId,
        },
        'statistics': stats,
        'data': inspections,
        'generated_at': DateTime.now().toIso8601String(),
      };

      // Store report
      await _storeReport(reportData);

      return reportData;
    } catch (e) {
      throw Exception('Failed to generate inspection report: $e');
    }
  }

  // Generate seizure report
  Future<Map<String, dynamic>> generateSeizureReport({
    required DateTime startDate,
    required DateTime endDate,
    String? districtId,
    String? status,
  }) async {
    try {
      // Fetch seizure data
      var query = _supabase
          .from('seizures')
          .select('''
            *,
            field_executions(*),
            products(*),
            seizure_items(*),
            lab_samples(*),
            fir_cases(*)
          ''')
          .gte('seizure_date', startDate.toIso8601String())
          .lte('seizure_date', endDate.toIso8601String());

      if (status != null) {
        query = query.eq('status', status);
      }

      final seizures = await query;

      // Filter by district if needed
      final filteredSeizures = districtId != null
          ? seizures
              .where((s) => s['field_executions']?['district_id'] == districtId)
              .toList()
          : seizures;

      // Calculate statistics
      final stats = _calculateSeizureStats(filteredSeizures);

      // Generate report data
      final reportData = {
        'report_type': 'seizure',
        'period': {
          'start': startDate.toIso8601String(),
          'end': endDate.toIso8601String(),
        },
        'filters': {
          'district_id': districtId,
          'status': status,
        },
        'statistics': stats,
        'data': filteredSeizures,
        'generated_at': DateTime.now().toIso8601String(),
      };

      // Store report
      await _storeReport(reportData);

      return reportData;
    } catch (e) {
      throw Exception('Failed to generate seizure report: $e');
    }
  }

  // Generate lab testing report
  Future<Map<String, dynamic>> generateLabReport({
    required DateTime startDate,
    required DateTime endDate,
    String? labId,
    String? testStatus,
  }) async {
    try {
      // Fetch lab sample data
      var query = _supabase
          .from('lab_samples')
          .select('''
            *,
            seizures(*),
            test_results(*),
            users!assigned_to(full_name)
          ''')
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String());

      if (labId != null) {
        query = query.eq('lab_id', labId);
      }

      if (testStatus != null) {
        query = query.eq('status', testStatus);
      }

      final samples = await query;

      // Calculate statistics
      final stats = _calculateLabStats(samples);

      // Generate report data
      final reportData = {
        'report_type': 'lab_testing',
        'period': {
          'start': startDate.toIso8601String(),
          'end': endDate.toIso8601String(),
        },
        'filters': {
          'lab_id': labId,
          'status': testStatus,
        },
        'statistics': stats,
        'data': samples,
        'generated_at': DateTime.now().toIso8601String(),
      };

      // Store report
      await _storeReport(reportData);

      return reportData;
    } catch (e) {
      throw Exception('Failed to generate lab report: $e');
    }
  }

  // Generate legal cases report
  Future<Map<String, dynamic>> generateLegalReport({
    required DateTime startDate,
    required DateTime endDate,
    String? caseStatus,
    String? caseType,
  }) async {
    try {
      // Fetch legal case data
      var query = _supabase
          .from('fir_cases')
          .select('''
            *,
            seizures(*),
            court_hearings(*),
            users!filed_by(full_name)
          ''')
          .gte('filed_date', startDate.toIso8601String())
          .lte('filed_date', endDate.toIso8601String());

      if (caseStatus != null) {
        query = query.eq('status', caseStatus);
      }

      if (caseType != null) {
        query = query.eq('case_type', caseType);
      }

      final cases = await query;

      // Calculate statistics
      final stats = _calculateLegalStats(cases);

      // Generate report data
      final reportData = {
        'report_type': 'legal_cases',
        'period': {
          'start': startDate.toIso8601String(),
          'end': endDate.toIso8601String(),
        },
        'filters': {
          'status': caseStatus,
          'case_type': caseType,
        },
        'statistics': stats,
        'data': cases,
        'generated_at': DateTime.now().toIso8601String(),
      };

      // Store report
      await _storeReport(reportData);

      return reportData;
    } catch (e) {
      throw Exception('Failed to generate legal report: $e');
    }
  }

  // Generate compliance report
  Future<Map<String, dynamic>> generateComplianceReport({
    required DateTime startDate,
    required DateTime endDate,
    String? districtId,
  }) async {
    try {
      // Fetch all relevant data
      final inspections = await _supabase
          .from('field_executions')
          .select('*')
          .gte('execution_date', startDate.toIso8601String())
          .lte('execution_date', endDate.toIso8601String());

      final seizures = await _supabase
          .from('seizures')
          .select('*')
          .gte('seizure_date', startDate.toIso8601String())
          .lte('seizure_date', endDate.toIso8601String());

      final labTests = await _supabase
          .from('lab_samples')
          .select('*, test_results(*)')
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String());

      final legalCases = await _supabase
          .from('fir_cases')
          .select('*')
          .gte('filed_date', startDate.toIso8601String())
          .lte('filed_date', endDate.toIso8601String());

      // Calculate compliance metrics
      final complianceStats = {
        'total_inspections': inspections.length,
        'violations_found': seizures.length,
        'compliance_rate': inspections.isNotEmpty
            ? ((inspections.length - seizures.length) /
                    inspections.length *
                    100)
                .toStringAsFixed(2)
            : '0',
        'samples_tested': labTests.length,
        'failed_samples': labTests
            .where((s) => s['test_results']?['conclusion'] == 'failed')
            .length,
        'legal_actions': legalCases.length,
        'convictions':
            legalCases.where((c) => c['status'] == 'convicted').length,
      };

      // Generate report data
      final reportData = {
        'report_type': 'compliance',
        'period': {
          'start': startDate.toIso8601String(),
          'end': endDate.toIso8601String(),
        },
        'filters': {
          'district_id': districtId,
        },
        'statistics': complianceStats,
        'summary': {
          'inspections': inspections.length,
          'seizures': seizures.length,
          'lab_tests': labTests.length,
          'legal_cases': legalCases.length,
        },
        'generated_at': DateTime.now().toIso8601String(),
      };

      // Store report
      await _storeReport(reportData);

      return reportData;
    } catch (e) {
      throw Exception('Failed to generate compliance report: $e');
    }
  }

  // Generate dashboard analytics
  Future<Map<String, dynamic>> getDashboardAnalytics({
    String? userId,
    String? role,
    String? districtId,
  }) async {
    try {
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));
      final sevenDaysAgo = now.subtract(const Duration(days: 7));

      // Get various statistics based on role
      Map<String, dynamic> analytics = {
        'generated_at': now.toIso8601String(),
      };

      // Overall statistics
      analytics['overview'] = await _getOverviewStats(thirtyDaysAgo, now);

      // Recent activities
      analytics['recent_activities'] = await _getRecentActivities(sevenDaysAgo);

      // Trend data
      analytics['trends'] = await _getTrendData(thirtyDaysAgo, now);

      // Role-specific data
      if (role != null) {
        analytics['role_specific'] = await _getRoleSpecificData(role, userId);
      }

      // District-specific data
      if (districtId != null) {
        analytics['district_data'] = await _getDistrictData(districtId);
      }

      return analytics;
    } catch (e) {
      throw Exception('Failed to generate dashboard analytics: $e');
    }
  }

  // Export report as PDF
  Future<Uint8List> exportReportAsPDF(Map<String, dynamic> reportData) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'AGRIVIGIL Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Paragraph(
              text: 'Report Type: ${reportData['report_type']}',
            ),
            pw.Paragraph(
              text: 'Generated: ${reportData['generated_at']}',
            ),
            pw.SizedBox(height: 20),
            pw.Header(
              level: 1,
              child: pw.Text('Statistics'),
            ),
            _buildPDFStatistics(reportData['statistics']),
            pw.SizedBox(height: 20),
            pw.Header(
              level: 1,
              child: pw.Text('Details'),
            ),
            _buildPDFDetails(reportData['data']),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // Get saved reports
  Future<List<Map<String, dynamic>>> getSavedReports({
    String? reportType,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    try {
      var query = _supabase.from('generated_reports').select('*');

      if (reportType != null) {
        query = query.eq('report_type', reportType);
      }

      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }

      final reports =
          await query.order('created_at', ascending: false).limit(limit);
      return List<Map<String, dynamic>>.from(reports);
    } catch (e) {
      throw Exception('Failed to fetch saved reports: $e');
    }
  }

  // Private helper methods
  Map<String, dynamic> _calculateInspectionStats(List<dynamic> inspections) {
    return {
      'total_inspections': inspections.length,
      'with_violations': inspections.where((i) => i['seizures'] != null).length,
      'compliance_rate': inspections.isNotEmpty
          ? ((inspections.where((i) => i['seizures'] == null).length /
                      inspections.length) *
                  100)
              .toStringAsFixed(2)
          : '0',
      'by_district': _groupByDistrict(inspections),
      'by_product': _groupByProduct(inspections),
    };
  }

  Map<String, dynamic> _calculateSeizureStats(List<dynamic> seizures) {
    return {
      'total_seizures': seizures.length,
      'pending': seizures.where((s) => s['status'] == 'pending').length,
      'under_investigation':
          seizures.where((s) => s['status'] == 'under_investigation').length,
      'lab_testing': seizures.where((s) => s['status'] == 'lab_testing').length,
      'legal_action':
          seizures.where((s) => s['status'] == 'legal_action').length,
      'completed': seizures.where((s) => s['status'] == 'completed').length,
      'total_items': _calculateTotalSeizureItems(seizures),
      'by_reason': _groupByReason(seizures),
    };
  }

  Map<String, dynamic> _calculateLabStats(List<dynamic> samples) {
    return {
      'total_samples': samples.length,
      'pending': samples.where((s) => s['status'] == 'pending').length,
      'in_progress': samples.where((s) => s['status'] == 'in_progress').length,
      'tested': samples.where((s) => s['status'] == 'tested').length,
      'completed': samples.where((s) => s['status'] == 'completed').length,
      'average_turnaround': _calculateAverageTurnaround(samples),
      'by_sample_type': _groupBySampleType(samples),
    };
  }

  Map<String, dynamic> _calculateLegalStats(List<dynamic> cases) {
    return {
      'total_cases': cases.length,
      'filed': cases.where((c) => c['status'] == 'filed').length,
      'under_investigation':
          cases.where((c) => c['status'] == 'under_investigation').length,
      'in_court': cases.where((c) => c['status'] == 'in_court').length,
      'convicted': cases.where((c) => c['status'] == 'convicted').length,
      'acquitted': cases.where((c) => c['status'] == 'acquitted').length,
      'closed': cases.where((c) => c['status'] == 'closed').length,
      'conviction_rate': cases.isNotEmpty
          ? ((cases.where((c) => c['status'] == 'convicted').length /
                      cases.length) *
                  100)
              .toStringAsFixed(2)
          : '0',
      'by_case_type': _groupByCaseType(cases),
    };
  }

  Future<void> _storeReport(Map<String, dynamic> reportData) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      await _supabase.from('generated_reports').insert({
        'report_type': reportData['report_type'],
        'report_data': reportData,
        'generated_by': userId,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Failed to store report: $e');
    }
  }

  Future<Map<String, dynamic>> _getOverviewStats(
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Implementation for overview statistics
    return {
      'inspections': 0,
      'seizures': 0,
      'lab_tests': 0,
      'legal_cases': 0,
    };
  }

  Future<List<Map<String, dynamic>>> _getRecentActivities(
      DateTime since) async {
    // Implementation for recent activities
    return [];
  }

  Future<Map<String, dynamic>> _getTrendData(
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Implementation for trend data
    return {};
  }

  Future<Map<String, dynamic>> _getRoleSpecificData(
    String role,
    String? userId,
  ) async {
    // Implementation for role-specific data
    return {};
  }

  Future<Map<String, dynamic>> _getDistrictData(String districtId) async {
    // Implementation for district-specific data
    return {};
  }

  Map<String, int> _groupByDistrict(List<dynamic> data) {
    final grouped = <String, int>{};
    for (final item in data) {
      final district = item['district_id'] ?? 'Unknown';
      grouped[district] = (grouped[district] ?? 0) + 1;
    }
    return grouped;
  }

  Map<String, int> _groupByProduct(List<dynamic> data) {
    final grouped = <String, int>{};
    for (final item in data) {
      final product = item['products']?['name'] ?? 'Unknown';
      grouped[product] = (grouped[product] ?? 0) + 1;
    }
    return grouped;
  }

  Map<String, int> _groupByReason(List<dynamic> seizures) {
    final grouped = <String, int>{};
    for (final seizure in seizures) {
      final reason = seizure['reason'] ?? 'Unknown';
      grouped[reason] = (grouped[reason] ?? 0) + 1;
    }
    return grouped;
  }

  Map<String, int> _groupBySampleType(List<dynamic> samples) {
    final grouped = <String, int>{};
    for (final sample in samples) {
      final type = sample['sample_type'] ?? 'Unknown';
      grouped[type] = (grouped[type] ?? 0) + 1;
    }
    return grouped;
  }

  Map<String, int> _groupByCaseType(List<dynamic> cases) {
    final grouped = <String, int>{};
    for (final c in cases) {
      final type = c['case_type'] ?? 'Unknown';
      grouped[type] = (grouped[type] ?? 0) + 1;
    }
    return grouped;
  }

  int _calculateTotalSeizureItems(List<dynamic> seizures) {
    int total = 0;
    for (final seizure in seizures) {
      if (seizure['seizure_items'] != null) {
        total += (seizure['seizure_items'] as List).length;
      }
    }
    return total;
  }

  String _calculateAverageTurnaround(List<dynamic> samples) {
    // Implementation for average turnaround calculation
    return '0 days';
  }

  pw.Widget _buildPDFStatistics(Map<String, dynamic>? stats) {
    if (stats == null) return pw.Container();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: stats.entries.map((entry) {
        return pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 2),
          child: pw.Text('${entry.key}: ${entry.value}'),
        );
      }).toList(),
    );
  }

  pw.Widget _buildPDFDetails(List<dynamic>? data) {
    if (data == null || data.isEmpty) {
      return pw.Text('No data available');
    }

    return pw.Column(
      children: [
        pw.Text('Total Records: ${data.length}'),
        // Add more detailed formatting as needed
      ],
    );
  }
}
