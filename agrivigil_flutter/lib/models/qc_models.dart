// QC Department specific models

class QCProcess {
  final String id;
  final String name;
  final String description;
  final List<QCStep> steps;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  QCProcess({
    required this.id,
    required this.name,
    required this.description,
    required this.steps,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
}

class QCStep {
  final int stepNumber;
  final String name;
  final String description;
  final List<String> requiredDocuments;
  final List<String> checkpoints;
  final bool isMandatory;
  final String approvalLevel; // 'officer', 'supervisor', 'manager'
  final bool requiresPhotographicEvidence;
  final bool requiresLabTest;

  QCStep({
    required this.stepNumber,
    required this.name,
    required this.description,
    required this.requiredDocuments,
    required this.checkpoints,
    required this.isMandatory,
    required this.approvalLevel,
    required this.requiresPhotographicEvidence,
    required this.requiresLabTest,
  });
}

class QCInspection {
  final String id;
  final String inspectionCode;
  final String processType; // 'routine', 'complaint-based', 'special'
  final DateTime scheduledDate;
  final String assignedOfficerId;
  final String assignedOfficerName;
  final QCStatus status;
  final List<QCCheckpoint> checkpoints;
  final String? remarks;
  final DateTime createdAt;
  final DateTime updatedAt;

  QCInspection({
    required this.id,
    required this.inspectionCode,
    required this.processType,
    required this.scheduledDate,
    required this.assignedOfficerId,
    required this.assignedOfficerName,
    required this.status,
    required this.checkpoints,
    this.remarks,
    required this.createdAt,
    required this.updatedAt,
  });
}

enum QCStatus {
  pending,
  inProgress,
  awaitingApproval,
  approved,
  rejected,
  completed,
  cancelled
}

class QCCheckpoint {
  final String id;
  final String name;
  final String category; // 'documentation', 'physical', 'chemical', 'compliance'
  final bool isCompliant;
  final String? nonComplianceReason;
  final List<String> evidencePhotos;
  final String? inspectorNotes;
  final DateTime? checkedAt;
  final String? checkedBy;

  QCCheckpoint({
    required this.id,
    required this.name,
    required this.category,
    required this.isCompliant,
    this.nonComplianceReason,
    required this.evidencePhotos,
    this.inspectorNotes,
    this.checkedAt,
    this.checkedBy,
  });
}

class QCSample {
  final String id;
  final String sampleCode;
  final String batchNumber;
  final String productName;
  final String manufacturer;
  final DateTime collectionDate;
  final String collectedBy;
  final String sampleType; // 'fertilizer', 'pesticide', 'seed'
  final double quantity;
  final String unit;
  final String storageCondition;
  final List<QCTest> tests;
  final String overallResult; // 'pass', 'fail', 'pending'
  final DateTime createdAt;

  QCSample({
    required this.id,
    required this.sampleCode,
    required this.batchNumber,
    required this.productName,
    required this.manufacturer,
    required this.collectionDate,
    required this.collectedBy,
    required this.sampleType,
    required this.quantity,
    required this.unit,
    required this.storageCondition,
    required this.tests,
    required this.overallResult,
    required this.createdAt,
  });
}

class QCTest {
  final String testName;
  final String testMethod;
  final String parameter;
  final double? specificationMin;
  final double? specificationMax;
  final double actualValue;
  final String unit;
  final bool isPassed;
  final String? remarks;
  final DateTime testedDate;
  final String testedBy;

  QCTest({
    required this.testName,
    required this.testMethod,
    required this.parameter,
    this.specificationMin,
    this.specificationMax,
    required this.actualValue,
    required this.unit,
    required this.isPassed,
    this.remarks,
    required this.testedDate,
    required this.testedBy,
  });
}

class QCApproval {
  final String id;
  final String inspectionId;
  final String approvalLevel; // 'L1', 'L2', 'L3'
  final String approverId;
  final String approverName;
  final String approverRole;
  final String decision; // 'approved', 'rejected', 'conditional'
  final String? comments;
  final List<String> conditions; // For conditional approval
  final DateTime approvalDate;

  QCApproval({
    required this.id,
    required this.inspectionId,
    required this.approvalLevel,
    required this.approverId,
    required this.approverName,
    required this.approverRole,
    required this.decision,
    this.comments,
    required this.conditions,
    required this.approvalDate,
  });
}

class QCCompliance {
  final String id;
  final String regulationType; // 'FCO', 'BIS', 'State Regulation'
  final String regulationCode;
  final String description;
  final List<String> applicableProducts;
  final List<ComplianceParameter> parameters;
  final bool isMandatory;
  final DateTime effectiveFrom;
  final DateTime? effectiveTo;

  QCCompliance({
    required this.id,
    required this.regulationType,
    required this.regulationCode,
    required this.description,
    required this.applicableProducts,
    required this.parameters,
    required this.isMandatory,
    required this.effectiveFrom,
    this.effectiveTo,
  });
}

class ComplianceParameter {
  final String name;
  final String testMethod;
  final double minValue;
  final double maxValue;
  final String unit;
  final String frequency; // 'batch-wise', 'monthly', 'quarterly'

  ComplianceParameter({
    required this.name,
    required this.testMethod,
    required this.minValue,
    required this.maxValue,
    required this.unit,
    required this.frequency,
  });
}

// ABC Analysis Model for QC
class ABCAnalysis {
  final String id;
  final String analysisType; // 'product', 'manufacturer', 'defect'
  final DateTime analysisDate;
  final String analyzedBy;
  final List<ABCCategory> categories;
  final String recommendations;
  final DateTime createdAt;

  ABCAnalysis({
    required this.id,
    required this.analysisType,
    required this.analysisDate,
    required this.analyzedBy,
    required this.categories,
    required this.recommendations,
    required this.createdAt,
  });
}

class ABCCategory {
  final String category; // 'A', 'B', 'C'
  final String description;
  final List<ABCItem> items;
  final double percentage; // Percentage of total
  final String actionRequired;

  ABCCategory({
    required this.category,
    required this.description,
    required this.items,
    required this.percentage,
    required this.actionRequired,
  });
}

class ABCItem {
  final String itemId;
  final String itemName;
  final double value; // Could be frequency, cost, or impact
  final double cumulativePercentage;
  final String priority;

  ABCItem({
    required this.itemId,
    required this.itemName,
    required this.value,
    required this.cumulativePercentage,
    required this.priority,
  });
}
