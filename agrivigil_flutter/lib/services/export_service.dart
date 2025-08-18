import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class ExportService {
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

  // Export data to PDF
  static Future<String?> exportToPDF({
    required String title,
    required List<Map<String, dynamic>> data,
    required List<String> columns,
    Map<String, String>? columnLabels,
    String? subtitle,
    Map<String, dynamic>? metadata,
    bool share = true,
  }) async {
    try {
      final pdf = pw.Document();

      // Build PDF content
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return [
              _buildPDFHeader(title, subtitle, metadata),
              pw.SizedBox(height: 20),
              _buildPDFTable(data, columns, columnLabels),
              pw.SizedBox(height: 20),
              _buildPDFFooter(),
            ];
          },
        ),
      );

      // Save PDF
      final output = await _getOutputDirectory();
      final fileName =
          '${title.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      // Share if requested
      if (share) {
        await Share.shareXFiles([XFile(file.path)], text: '$title Export');
      }

      return file.path;
    } catch (e) {
      print('Error exporting to PDF: $e');
      return null;
    }
  }

  // Export data to Excel
  static Future<String?> exportToExcel({
    required String title,
    required List<Map<String, dynamic>> data,
    required List<String> columns,
    Map<String, String>? columnLabels,
    String? sheetName,
    Map<String, dynamic>? metadata,
    bool share = true,
  }) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel[sheetName ?? 'Sheet1'];

      // Add title and metadata
      int rowIndex = 0;

      // Title
      sheet.merge(
        CellIndex.indexByString('A${rowIndex + 1}'),
        CellIndex.indexByString(
            '${String.fromCharCode(65 + columns.length - 1)}${rowIndex + 1}'),
      );
      sheet.cell(CellIndex.indexByString('A${rowIndex + 1}')).value =
          TextCellValue(title);
      sheet.cell(CellIndex.indexByString('A${rowIndex + 1}')).cellStyle =
          CellStyle(
        bold: true,
        fontSize: 16,
        horizontalAlign: HorizontalAlign.Center,
      );
      rowIndex += 2;

      // Metadata
      if (metadata != null) {
        metadata.forEach((key, value) {
          sheet.cell(CellIndex.indexByString('A${rowIndex + 1}')).value =
              TextCellValue(key);
          sheet.cell(CellIndex.indexByString('B${rowIndex + 1}')).value =
              TextCellValue(value.toString());
          rowIndex++;
        });
        rowIndex++;
      }

      // Headers
      for (int i = 0; i < columns.length; i++) {
        final column = columns[i];
        final label = columnLabels?[column] ?? column;
        final cell = sheet.cell(CellIndex.indexByString(
            '${String.fromCharCode(65 + i)}${rowIndex + 1}'));
        cell.value = TextCellValue(label);
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.fromHexString('#4CAF50'),
          fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
        );
      }
      rowIndex++;

      // Data rows
      for (final row in data) {
        for (int i = 0; i < columns.length; i++) {
          final column = columns[i];
          final value = row[column];
          final cell = sheet.cell(CellIndex.indexByString(
              '${String.fromCharCode(65 + i)}${rowIndex + 1}'));

          if (value == null) {
            cell.value = TextCellValue('');
          } else if (value is DateTime) {
            cell.value = TextCellValue(_dateTimeFormat.format(value));
          } else if (value is bool) {
            cell.value = TextCellValue(value ? 'Yes' : 'No');
          } else if (value is num) {
            cell.value = IntCellValue(value.toInt());
          } else {
            cell.value = TextCellValue(value.toString());
          }
        }
        rowIndex++;
      }

      // Auto-fit columns
      for (int i = 0; i < columns.length; i++) {
        sheet.setColumnWidth(i, 15);
      }

      // Save Excel file
      final output = await _getOutputDirectory();
      final fileName =
          '${title.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(excel.save()!);

      // Share if requested
      if (share) {
        await Share.shareXFiles([XFile(file.path)], text: '$title Export');
      }

      return file.path;
    } catch (e) {
      print('Error exporting to Excel: $e');
      return null;
    }
  }

  // Export specific report types
  static Future<String?> exportInspectionReport({
    required Map<String, dynamic> inspection,
    bool asPDF = true,
  }) async {
    final data = [inspection];
    final columns = [
      'inspection_code',
      'location',
      'dealer_name',
      'execution_date',
      'status',
      'violation_found',
      'remarks',
    ];
    final columnLabels = {
      'inspection_code': 'Inspection Code',
      'location': 'Location',
      'dealer_name': 'Dealer Name',
      'execution_date': 'Execution Date',
      'status': 'Status',
      'violation_found': 'Violation Found',
      'remarks': 'Remarks',
    };

    if (asPDF) {
      return await exportToPDF(
        title: 'Inspection Report',
        subtitle: inspection['inspection_code'],
        data: data,
        columns: columns,
        columnLabels: columnLabels,
        metadata: {
          'Generated On': _dateTimeFormat.format(DateTime.now()),
          'Inspector': inspection['inspector_name'] ?? 'N/A',
          'District': inspection['district'] ?? 'N/A',
        },
      );
    } else {
      return await exportToExcel(
        title: 'Inspection Report',
        sheetName: 'Inspection',
        data: data,
        columns: columns,
        columnLabels: columnLabels,
        metadata: {
          'Generated On': _dateTimeFormat.format(DateTime.now()),
          'Inspector': inspection['inspector_name'] ?? 'N/A',
          'District': inspection['district'] ?? 'N/A',
        },
      );
    }
  }

  static Future<String?> exportSeizureReport({
    required Map<String, dynamic> seizure,
    bool asPDF = true,
  }) async {
    final data = [seizure];
    final columns = [
      'seizure_code',
      'location',
      'dealer_name',
      'seizure_date',
      'total_quantity',
      'estimated_value',
      'status',
      'reason',
    ];
    final columnLabels = {
      'seizure_code': 'Seizure Code',
      'location': 'Location',
      'dealer_name': 'Dealer Name',
      'seizure_date': 'Seizure Date',
      'total_quantity': 'Total Quantity',
      'estimated_value': 'Estimated Value',
      'status': 'Status',
      'reason': 'Reason',
    };

    if (asPDF) {
      return await exportToPDF(
        title: 'Seizure Report',
        subtitle: seizure['seizure_code'],
        data: data,
        columns: columns,
        columnLabels: columnLabels,
        metadata: {
          'Generated On': _dateTimeFormat.format(DateTime.now()),
          'Officer': seizure['officer_name'] ?? 'N/A',
          'District': seizure['district'] ?? 'N/A',
        },
      );
    } else {
      return await exportToExcel(
        title: 'Seizure Report',
        sheetName: 'Seizure',
        data: data,
        columns: columns,
        columnLabels: columnLabels,
        metadata: {
          'Generated On': _dateTimeFormat.format(DateTime.now()),
          'Officer': seizure['officer_name'] ?? 'N/A',
          'District': seizure['district'] ?? 'N/A',
        },
      );
    }
  }

  static Future<String?> exportLabReport({
    required Map<String, dynamic> labSample,
    bool asPDF = true,
  }) async {
    final data = [labSample];
    final columns = [
      'sample_code',
      'sample_type',
      'collection_date',
      'test_date',
      'status',
      'test_result',
      'analyst_name',
      'remarks',
    ];
    final columnLabels = {
      'sample_code': 'Sample Code',
      'sample_type': 'Sample Type',
      'collection_date': 'Collection Date',
      'test_date': 'Test Date',
      'status': 'Status',
      'test_result': 'Test Result',
      'analyst_name': 'Analyst Name',
      'remarks': 'Remarks',
    };

    if (asPDF) {
      return await exportToPDF(
        title: 'Lab Test Report',
        subtitle: labSample['sample_code'],
        data: data,
        columns: columns,
        columnLabels: columnLabels,
        metadata: {
          'Generated On': _dateTimeFormat.format(DateTime.now()),
          'Lab Name': labSample['lab_name'] ?? 'N/A',
          'Priority': labSample['priority'] ?? 'Normal',
        },
      );
    } else {
      return await exportToExcel(
        title: 'Lab Test Report',
        sheetName: 'Lab Test',
        data: data,
        columns: columns,
        columnLabels: columnLabels,
        metadata: {
          'Generated On': _dateTimeFormat.format(DateTime.now()),
          'Lab Name': labSample['lab_name'] ?? 'N/A',
          'Priority': labSample['priority'] ?? 'Normal',
        },
      );
    }
  }

  // Export bulk data
  static Future<String?> exportBulkData({
    required String title,
    required List<Map<String, dynamic>> data,
    required ExportType type,
    bool share = true,
  }) async {
    if (data.isEmpty) return null;

    // Get all unique columns from data
    final columns = <String>{};
    for (final row in data) {
      columns.addAll(row.keys);
    }

    final columnList = columns.toList()..sort();

    if (type == ExportType.pdf) {
      return await exportToPDF(
        title: title,
        data: data,
        columns: columnList,
        share: share,
        metadata: {
          'Total Records': data.length.toString(),
          'Generated On': _dateTimeFormat.format(DateTime.now()),
        },
      );
    } else {
      return await exportToExcel(
        title: title,
        data: data,
        columns: columnList,
        share: share,
        metadata: {
          'Total Records': data.length.toString(),
          'Generated On': _dateTimeFormat.format(DateTime.now()),
        },
      );
    }
  }

  // Helper methods
  static pw.Widget _buildPDFHeader(
    String title,
    String? subtitle,
    Map<String, dynamic>? metadata,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        if (subtitle != null) ...[
          pw.SizedBox(height: 5),
          pw.Text(
            subtitle,
            style: pw.TextStyle(
              fontSize: 16,
              color: PdfColors.grey700,
            ),
          ),
        ],
        if (metadata != null) ...[
          pw.SizedBox(height: 10),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(5),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: metadata.entries.map((entry) {
                return pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      '${entry.key}:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(entry.value.toString()),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  static pw.Widget _buildPDFTable(
    List<Map<String, dynamic>> data,
    List<String> columns,
    Map<String, String>? columnLabels,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      children: [
        // Header row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.green),
          children: columns.map((column) {
            final label = columnLabels?[column] ?? column;
            return pw.Container(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                label,
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            );
          }).toList(),
        ),
        // Data rows
        ...data.map((row) {
          return pw.TableRow(
            children: columns.map((column) {
              final value = row[column];
              String displayValue = '';

              if (value == null) {
                displayValue = '-';
              } else if (value is DateTime) {
                displayValue = _dateFormat.format(value);
              } else if (value is bool) {
                displayValue = value ? 'Yes' : 'No';
              } else {
                displayValue = value.toString();
              }

              return pw.Container(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(displayValue),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  static pw.Widget _buildPDFFooter() {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Text(
        'Generated by AGRIVIGIL on ${_dateTimeFormat.format(DateTime.now())}',
        style: const pw.TextStyle(
          fontSize: 10,
          color: PdfColors.grey600,
        ),
      ),
    );
  }

  static Future<Directory> _getOutputDirectory() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Storage permission denied');
      }
      return await getExternalStorageDirectory() ??
          await getApplicationDocumentsDirectory();
    } else {
      return await getApplicationDocumentsDirectory();
    }
  }

  // Request storage permissions
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return true;
  }
}

enum ExportType {
  pdf,
  excel,
}
