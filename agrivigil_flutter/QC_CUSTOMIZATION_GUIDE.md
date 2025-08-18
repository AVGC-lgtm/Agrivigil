# QC Department Customization Guide

Since I cannot read your "Actual Process Of QC department - For Agrivigil Software.pdf" document, here's a guide on how to customize the QC module based on your specific requirements.

## 1. Adding Specific QC Checkpoints

### Example: Adding Fertilizer QC Checkpoints

```dart
// In qc_service.dart, add your specific checkpoints:

final fertilizerCheckpoints = [
  {
    'name': 'Physical Appearance Check',
    'category': 'physical',
    'description': 'Check color, texture, granule size',
    'required_evidence': 'photo',
    'parameters': ['color', 'texture', 'granule_uniformity'],
  },
  {
    'name': 'Moisture Content Test',
    'category': 'chemical',
    'description': 'Test moisture percentage',
    'required_evidence': 'document',
    'parameters': ['moisture_percentage'],
    'limits': {'min': 0.5, 'max': 1.5},
  },
  {
    'name': 'NPK Content Analysis',
    'category': 'chemical',
    'description': 'Verify NPK composition',
    'required_evidence': 'document',
    'parameters': ['nitrogen', 'phosphorus', 'potassium'],
    'test_method': 'IS 2430-1988',
  },
  {
    'name': 'Packaging Compliance',
    'category': 'compliance',
    'description': 'Check packaging labels and weight',
    'required_evidence': 'photo',
    'parameters': ['label_compliance', 'weight_accuracy'],
  },
];
```

## 2. Configuring Compliance Parameters

### Example: FCO Compliance for NPK 10:26:26

```dart
// Add to your compliance configuration:

final fcoCompliance = {
  'regulation': 'FCO Order 1985',
  'product': 'NPK 10:26:26',
  'parameters': [
    {
      'name': 'Total Nitrogen',
      'method': 'Kjeldahl Method',
      'specification': 10.0,
      'tolerance': 0.5, // ±0.5%
      'unit': '%',
    },
    {
      'name': 'Available P2O5',
      'method': 'Spectrophotometric',
      'specification': 26.0,
      'tolerance': 0.5,
      'unit': '%',
    },
    {
      'name': 'Water Soluble K2O',
      'method': 'Flame Photometric',
      'specification': 26.0,
      'tolerance': 0.5,
      'unit': '%',
    },
  ],
};
```

## 3. Setting Up Approval Matrix

### Example: Multi-Level Approval Configuration

```dart
// In rbac_config.dart, customize approval levels:

final approvalMatrix = {
  'routine_inspection': {
    'L1': {
      'role': 'QC_INSPECTOR',
      'can_approve': ['draft_to_submitted'],
    },
    'L2': {
      'role': 'QC_SUPERVISOR', 
      'can_approve': ['submitted_to_reviewed'],
    },
    'L3': {
      'role': 'QC_MANAGER',
      'can_approve': ['reviewed_to_approved'],
    },
  },
  'non_compliance': {
    'L1': {
      'role': 'QC_SUPERVISOR',
      'can_approve': ['open_to_investigation'],
    },
    'L2': {
      'role': 'QC_MANAGER',
      'can_approve': ['investigation_to_action'],
    },
    'L3': {
      'role': 'QC_HEAD',
      'can_approve': ['action_to_closed'],
    },
  },
};
```

## 4. Implementing Specific Test Methods

### Example: Adding Chemical Test Methods

```dart
// Create a new file: lib/utils/qc_test_methods.dart

class QCTestMethods {
  // Moisture Test
  static Map<String, dynamic> moistureTest(double sampleWeight, double dryWeight) {
    final moisture = ((sampleWeight - dryWeight) / sampleWeight) * 100;
    return {
      'parameter': 'Moisture Content',
      'value': moisture,
      'unit': '%',
      'method': 'Oven Drying at 105°C',
      'passed': moisture <= 1.5, // FCO limit
    };
  }

  // pH Test
  static Map<String, dynamic> phTest(double phValue) {
    return {
      'parameter': 'pH',
      'value': phValue,
      'unit': '',
      'method': 'pH Meter (1:2.5 soil:water)',
      'passed': phValue >= 6.5 && phValue <= 7.5,
    };
  }

  // Sieve Analysis
  static Map<String, dynamic> sieveAnalysis(Map<String, double> sieveData) {
    // Calculate particle size distribution
    return {
      'parameter': 'Particle Size',
      'distribution': sieveData,
      'unit': 'mm',
      'method': 'IS Sieve Analysis',
      'passed': true, // Based on specifications
    };
  }
}
```

## 5. Adding Business Rules

### Example: Inspection Frequency Rules

```dart
// In qc_service.dart, add business rules:

class QCBusinessRules {
  // Determine inspection frequency based on product risk
  static String getInspectionFrequency(String productCategory, String manufacturer) {
    if (productCategory == 'pesticides' && isHighRiskManufacturer(manufacturer)) {
      return 'weekly';
    } else if (productCategory == 'fertilizers') {
      return 'bi-weekly';
    } else if (productCategory == 'seeds') {
      return 'monthly';
    }
    return 'quarterly';
  }

  // Sampling rules
  static int getSampleSize(int batchSize) {
    if (batchSize <= 100) return 5;
    if (batchSize <= 500) return 10;
    if (batchSize <= 1000) return 15;
    return 20;
  }

  // Deviation handling
  static String getDeviationAction(double deviation, bool isCritical) {
    if (isCritical && deviation > 10) {
      return 'immediate_recall';
    } else if (deviation > 5) {
      return 'stop_sale';
    } else if (deviation > 2) {
      return 'retest';
    }
    return 'warning';
  }
}
```

## 6. Custom QC Reports

### Example: Inspection Report Template

```dart
// In lib/utils/qc_reports.dart

class QCReports {
  static Future<String> generateInspectionReport(QCInspection inspection) async {
    final html = '''
    <html>
      <head>
        <title>QC Inspection Report</title>
        <style>
          body { font-family: Arial; }
          .header { background: #10B981; color: white; padding: 20px; }
          .section { margin: 20px 0; }
          .pass { color: green; }
          .fail { color: red; }
        </style>
      </head>
      <body>
        <div class="header">
          <h1>Quality Control Inspection Report</h1>
          <p>Report No: ${inspection.inspectionCode}</p>
          <p>Date: ${DateFormat('dd/MM/yyyy').format(inspection.scheduledDate)}</p>
        </div>
        
        <div class="section">
          <h2>Inspection Details</h2>
          <table>
            <tr><td>Inspector:</td><td>${inspection.assignedOfficerName}</td></tr>
            <tr><td>Type:</td><td>${inspection.processType}</td></tr>
            <tr><td>Status:</td><td>${inspection.status}</td></tr>
          </table>
        </div>
        
        <div class="section">
          <h2>Checkpoint Results</h2>
          ${_generateCheckpointTable(inspection.checkpoints)}
        </div>
        
        <div class="section">
          <h2>Recommendations</h2>
          <p>${inspection.remarks ?? 'No additional remarks'}</p>
        </div>
      </body>
    </html>
    ''';
    
    return html;
  }
}
```

## 7. Integration with Your Existing Process

Based on your QC document, you'll need to:

### A. Map Your Process Steps
```dart
// Example mapping of your QC process
final qcProcessSteps = {
  'step1': 'Sample Receipt',
  'step2': 'Visual Inspection',
  'step3': 'Physical Testing',
  'step4': 'Chemical Analysis',
  'step5': 'Result Compilation',
  'step6': 'Review & Approval',
  'step7': 'Report Generation',
};
```

### B. Configure Department-Specific Settings
```dart
// In your QC configuration
final qcDepartmentConfig = {
  'working_hours': '9:00 AM - 6:00 PM',
  'sample_retention_days': 90,
  'report_format': 'ISO 17025',
  'accreditation': 'NABL',
  'test_categories': [
    'Physical',
    'Chemical',
    'Microbiological',
    'Heavy Metals',
  ],
};
```

### C. Add Specific Forms
```dart
// Create custom forms for your QC process
final qcForms = {
  'sample_receipt': {
    'fields': [
      {'name': 'sample_code', 'type': 'text', 'required': true},
      {'name': 'batch_no', 'type': 'text', 'required': true},
      {'name': 'mfg_date', 'type': 'date', 'required': true},
      {'name': 'exp_date', 'type': 'date', 'required': true},
      {'name': 'quantity', 'type': 'number', 'required': true},
      {'name': 'condition', 'type': 'select', 'options': ['Good', 'Damaged', 'Suspicious']},
    ],
  },
};
```

## 8. Next Steps

1. **Review Your QC Document**
   - Identify all checkpoints
   - List compliance parameters
   - Map approval workflows
   - Define test methods

2. **Update Configuration Files**
   - Add checkpoints to database
   - Configure compliance rules
   - Set up approval matrix
   - Define business rules

3. **Customize UI**
   - Add department-specific fields
   - Create custom forms
   - Design specific reports
   - Add validation rules

4. **Test the System**
   - Create test inspections
   - Verify compliance checks
   - Test approval workflows
   - Generate sample reports

## Support

If you need help implementing specific features from your QC document:
1. Share the relevant sections of your document
2. Describe the specific process steps
3. List any unique requirements

I can then provide exact code implementations for your needs.

---

**Remember**: The current implementation provides a solid foundation. You just need to add your specific business logic and configurations based on your QC department's actual processes.
