# AGRIVIGIL Database Schema Documentation

## Overview

This directory contains the complete database schema for the AGRIVIGIL application. The schema is modularized into different files for better organization and maintenance.

## Schema Files

### 1. `01_master_schema.sql`
Complete database schema including all tables, views, functions, and triggers.

**Contains:**
- Core tables (users, roles, permissions)
- Inspection and field execution tables
- Product and scan results tables
- Seizure and legal tables
- Lab sample management tables
- QC department tables
- Audit and system tables
- Views for common queries
- Functions and triggers

### 2. `02_indexes_and_policies.sql`
Performance indexes and Row Level Security (RLS) policies.

**Contains:**
- All database indexes for optimal query performance
- Row Level Security policies for data access control
- Composite indexes for common query patterns

### 3. `03_seed_data.sql`
Initial data for roles, permissions, and test users.

**Contains:**
- All system roles with permissions
- Test users for each role
- Master data (products, QC checkpoints, test parameters)
- System settings
- Sample inspection data

**Test Users:**
| Role | Email | Password |
|------|-------|----------|
| Super Admin | super.admin@agrivigil.com | Test@123 |
| Field Officer | field.officer@agrivigil.com | Test@123 |
| Lab Analyst | lab.analyst@agrivigil.com | Test@123 |
| QC Inspector | qc.inspector@agrivigil.com | Test@123 |
| District Agriculture Officer | dao.mumbai@agrivigil.com | Test@123 |

### 4. `04_migration_from_existing.sql`
Migration script for upgrading existing databases.

**Features:**
- Safe migration with transaction support
- Migration logging
- Automatic rollback on errors
- Data quality fixes
- Progress tracking

### 5. `05_quick_setup.sql`
Quick setup script that runs all necessary files in sequence.

## Installation Instructions

### Fresh Installation

1. Connect to your Supabase SQL Editor or PostgreSQL database
2. Run the quick setup script:
   ```sql
   \i 05_quick_setup.sql
   ```
   Or run files individually:
   ```sql
   \i 01_master_schema.sql
   \i 02_indexes_and_policies.sql
   \i 03_seed_data.sql
   ```

### Migrating Existing Database

1. **BACKUP YOUR DATABASE FIRST!**
2. Run the migration script:
   ```sql
   \i 04_migration_from_existing.sql
   ```
3. Review migration log:
   ```sql
   SELECT * FROM migration_log ORDER BY executed_at;
   ```
4. Fix any data issues identified

### Quick Fix for State Column Error

If you get an error about `state` column not existing:
```sql
\i fix_state_column.sql
```

### Quick Fix for View Column Error

If you get an error about changing view column names:
```sql
\i fix_view_column_error.sql
```

### Quick Fix for Priority Column Error

If you get an error about `priority` column not existing in inspection_tasks:
```sql
\i fix_priority_column.sql
```

### Fix Field Execution ID Error

If you get an error about `field_execution_id` column not existing in lab_samples:
```sql
\i fix_field_execution_id.sql
```

### Fix Module Column Error

If you get an error about `module` column not existing in role_permissions:
```sql
\i fix_module_column.sql
```

### Fix is_active Column Error

If you get an error about `is_active` column not existing:
```sql
\i fix_is_active_column.sql
```

### Fix scanned_by Column Error

If you get an error about `scanned_by` column not existing in scan_results:
```sql
\i fix_scanned_by_column.sql
```

### Fix All Column Errors at Once

For a comprehensive fix of all missing columns (recommended):
```sql
\i fix_all_column_errors.sql
```

## Database Structure

### Core Modules

1. **User Management**
   - Users with role-based access
   - Session management
   - Notification system

2. **Field Operations**
   - Inspection planning and execution
   - Field data collection
   - Evidence management

3. **Quality Control**
   - QC inspections
   - Compliance management
   - ABC analysis
   - Approval workflows

4. **Laboratory**
   - Sample management
   - Test results
   - Report generation

5. **Legal & Compliance**
   - Seizure management
   - FIR case tracking
   - Court proceedings

6. **Product Management**
   - Product master data
   - Authenticity scanning
   - Counterfeit detection

## Security Features

- Row Level Security (RLS) enabled on all tables
- Role-based access control
- Audit logging for all critical operations
- Secure password hashing (using pgcrypto)

## Performance Optimization

- Comprehensive indexing strategy
- Optimized views for common queries
- Composite indexes for complex queries
- Updated statistics for query planning

## Maintenance

### Regular Tasks

1. **Update Statistics**
   ```sql
   ANALYZE;
   ```

2. **Check Index Usage**
   ```sql
   SELECT schemaname, tablename, indexname, idx_scan
   FROM pg_stat_user_indexes
   ORDER BY idx_scan;
   ```

3. **Monitor Table Sizes**
   ```sql
   SELECT schemaname, tablename, 
          pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
   FROM pg_tables
   WHERE schemaname = 'public'
   ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
   ```

## Troubleshooting

### Common Issues

1. **Migration Fails**
   - Check migration_log table for errors
   - Ensure all foreign key references are valid
   - Verify user has sufficient privileges

2. **RLS Policies Blocking Access**
   - Check current user role
   - Verify RLS policies for the table
   - Use BYPASSRLS role for admin operations

3. **Performance Issues**
   - Run EXPLAIN ANALYZE on slow queries
   - Check for missing indexes
   - Update table statistics

## Development Guidelines

1. **Adding New Tables**
   - Add to 01_master_schema.sql
   - Create appropriate indexes in 02_indexes_and_policies.sql
   - Add RLS policies for security
   - Update migration script if needed

2. **Modifying Existing Tables**
   - Create migration script
   - Test on development database first
   - Update documentation

3. **Adding New Roles**
   - Add to seed data
   - Define appropriate permissions
   - Create RLS policies

## Support

For issues or questions:
1. Check the troubleshooting section
2. Review migration logs
3. Contact the development team

## Version History

- v2.0 - Complete schema redesign with enhanced security and performance
- v1.0 - Initial schema design
