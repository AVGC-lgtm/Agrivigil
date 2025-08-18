# AGRIVIGIL Flutter App - QC Department & Enhanced RBAC Implementation

## Overview

This document outlines the implementation of the Quality Control (QC) Department module and enhanced Role-Based Access Control (RBAC) with Activity-Based Access Control (ABAC) in the AGRIVIGIL Flutter application.

## 1. Enhanced RBAC System

### 1.1 Role Hierarchy

The system now includes a comprehensive role hierarchy with specific QC department roles:

```
Super Admin (Level 100)
    ├── QC Department Head (Level 90)
    │   ├── QC Manager (Level 80)
    │   │   ├── QC Supervisor (Level 70)
    │   │   │   └── QC Inspector (Level 60)
    │   │   └── Lab Analyst (Level 50)
    │   └── District Agricultural Officer (Level 70)
    ├── Legal Officer (Level 60)
    └── Field Officer (Level 40)
```

### 1.2 Permission Types

- **F (Full)**: Complete access - Create, Read, Update, Delete
- **R (Read)**: Read-only access
- **N (None)**: No access

### 1.3 ABAC Implementation

Activity-Based Access Control adds context-aware permissions:
- Time-based restrictions (e.g., edit within 24 hours)
- Status-based permissions (e.g., approve only if status is 'awaiting_approval')
- Hierarchical approval (e.g., can only approve if user level > creator level)
- Department-based access control

## 2. QC Department Module Features

### 2.1 QC Dashboard
- Real-time quality compliance statistics
- Pareto charts for trend analysis
- Pending approvals overview
- Department-specific KPIs

### 2.2 QC Inspection Management
- Create and schedule QC inspections
- Multi-step inspection workflow
- Checkpoint-based compliance tracking
- Photographic evidence collection
- Digital signatures for approvals

### 2.3 Compliance Management
- FCO (Fertilizer Control Order) compliance
- BIS (Bureau of Indian Standards) compliance
- State-specific regulations
- Parameter-based testing requirements
- Automatic deviation alerts

### 2.4 ABC Analysis
- Product-based analysis
- Manufacturer-based analysis
- Defect type analysis
- Pareto principle implementation (80/20 rule)
- Action recommendations based on categories

### 2.5 Approval Workflow
- Multi-level approval system (L1, L2, L3, L4)
- Department-specific approval chains
- Real-time status tracking
- Approval turnaround time (TAT) monitoring
- Conditional approvals with requirements

## 3. QC Process Implementation

### 3.1 Inspection Process Flow

```
1. Inspection Planning
   └── QC Inspector creates inspection
       └── QC Supervisor assigns resources
           └── Field execution
               └── Sample collection
                   └── Lab testing
                       └── Results review
                           └── Compliance check
                               └── Final approval
```

### 3.2 Sample Testing Workflow

```
1. Sample Receipt
   └── Lab registration
       └── Test assignment
           └── Analysis execution
               └── Result entry
                   └── Technical review
                       └── Report generation
                           └── Approval/Rejection
```

### 3.3 Non-Compliance Handling

```
1. Deviation Detection
   └── Root cause analysis
       └── Corrective action plan
           └── Implementation
               └── Verification
                   └── Closure
```

## 4. Data Access Rules

### 4.1 Hierarchical Access

- **QC Inspector**: District-level data only
- **QC Supervisor**: District-level data
- **QC Manager**: State-level data
- **QC Department Head**: National-level data

### 4.2 Cross-Department Access

- QC can view Field Execution data (Read)
- QC can access Lab Interface (Full/Read based on role)
- Legal can view QC reports for FIR cases
- DAO can oversee all district QC activities

## 5. Key Features by Role

### 5.1 QC Inspector
- Create routine inspections
- Collect samples
- Upload evidence
- Submit for approval

### 5.2 QC Supervisor
- Approve/reject inspections
- Assign inspectors
- Monitor compliance
- Generate basic reports

### 5.3 QC Manager
- Final approvals
- ABC analysis
- Compliance management
- Advanced reporting

### 5.4 QC Department Head
- Strategic oversight
- Policy implementation
- Cross-department coordination
- Executive dashboards

## 6. Security Features

### 6.1 Data Protection
- Role-based data filtering
- Audit trails for all actions
- Encrypted sensitive data
- Session-based access control

### 6.2 Compliance
- Digital signatures
- Time-stamped approvals
- Immutable audit logs
- Chain of custody tracking

## 7. Mobile-Specific Features

### 7.1 Offline Capability
- Queue inspections for sync
- Local data caching
- Conflict resolution
- Background synchronization

### 7.2 Field Features
- GPS location capture
- Camera integration
- Barcode/QR scanning
- Digital signatures

## 8. Integration Points

### 8.1 With Other Modules
- Field Execution → QC Inspection
- QC Inspection → Lab Sample
- Lab Results → Legal Action
- All modules → Reports & Audit

### 8.2 External Systems
- Government compliance databases
- Laboratory information systems
- Legal case management
- ERP integration ready

## 9. Implementation Checklist

### Completed ✅
- [x] Enhanced RBAC system with levels
- [x] ABAC implementation
- [x] QC Department module UI
- [x] Inspection management
- [x] Compliance tracking
- [x] ABC analysis
- [x] Approval workflow
- [x] Role-specific permissions
- [x] Database schema updates

### Pending Tasks
- [ ] Connect to actual QC process document
- [ ] Implement specific business rules
- [ ] Add custom compliance parameters
- [ ] Integrate with lab equipment
- [ ] Mobile offline sync
- [ ] Push notifications
- [ ] Advanced analytics
- [ ] Export functionality

## 10. Usage Guide

### 10.1 For QC Personnel

1. **Login** with QC role credentials
2. **Navigate** to QC Department module
3. **Create** inspection based on plan
4. **Execute** field inspection
5. **Submit** for approval
6. **Track** status in dashboard

### 10.2 For Administrators

1. **Assign** QC roles via Administration
2. **Configure** compliance parameters
3. **Monitor** QC performance metrics
4. **Review** ABC analysis results
5. **Take** corrective actions

## 11. API Endpoints (Supabase)

### QC Specific Tables (To be created)
```sql
-- QC Inspections
CREATE TABLE qc_inspections (
    id UUID PRIMARY KEY,
    inspection_code VARCHAR(50) UNIQUE,
    process_type VARCHAR(50),
    scheduled_date TIMESTAMPTZ,
    assigned_officer_id UUID REFERENCES users(id),
    status VARCHAR(50),
    checkpoints JSONB,
    remarks TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- QC Compliance Rules
CREATE TABLE qc_compliance_rules (
    id UUID PRIMARY KEY,
    regulation_type VARCHAR(50),
    regulation_code VARCHAR(100),
    description TEXT,
    applicable_products TEXT[],
    parameters JSONB,
    is_mandatory BOOLEAN,
    effective_from DATE,
    effective_to DATE
);

-- ABC Analysis Results
CREATE TABLE qc_abc_analysis (
    id UUID PRIMARY KEY,
    analysis_type VARCHAR(50),
    analysis_date DATE,
    analyzed_by UUID REFERENCES users(id),
    categories JSONB,
    recommendations TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Approval Workflow
CREATE TABLE qc_approvals (
    id UUID PRIMARY KEY,
    item_type VARCHAR(50),
    item_id UUID,
    approval_level VARCHAR(10),
    approver_id UUID REFERENCES users(id),
    decision VARCHAR(20),
    comments TEXT,
    conditions TEXT[],
    approval_date TIMESTAMPTZ
);
```

## 12. Future Enhancements

1. **AI/ML Integration**
   - Predictive quality analysis
   - Anomaly detection
   - Automated compliance checking

2. **IoT Integration**
   - Real-time sensor data
   - Automated sampling
   - Environmental monitoring

3. **Blockchain**
   - Immutable quality records
   - Supply chain traceability
   - Smart contracts for compliance

4. **Advanced Analytics**
   - Predictive maintenance
   - Quality forecasting
   - Supplier performance scoring

---

**Note**: This implementation provides a comprehensive QC department module with enhanced RBAC. The actual QC processes should be customized based on the specific requirements in your "Actual Process Of QC department" document.
