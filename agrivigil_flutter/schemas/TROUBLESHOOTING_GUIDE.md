# AGRIVIGIL Schema Troubleshooting Guide

## Quick Solutions

### 🚀 Recommended: Fix Everything at Once
```sql
\i fix_all_column_errors.sql
```
This comprehensive script fixes all common column issues.

### Individual Fixes

1. **State column missing** (`column u.state does not exist`)
   ```sql
   \i fix_state_column.sql
   ```

2. **Cannot change view column names** (`cannot change name of view column`)
   ```sql
   \i fix_view_column_error.sql
   ```

3. **Priority column missing** (`column it.priority does not exist`)
   ```sql
   \i fix_priority_column.sql
   ```

4. **Field execution ID missing** (`column ls.field_execution_id does not exist`)
   ```sql
   \i fix_field_execution_id.sql
   ```

5. **Module column missing** (`column "module" does not exist`)
   ```sql
   \i fix_module_column.sql
   ```

6. **is_active column missing** (`column "is_active" does not exist`)
   ```sql
   \i fix_is_active_column.sql
   ```

7. **scanned_by column missing** (`column "scanned_by" does not exist`)
   ```sql
   \i fix_scanned_by_column.sql
   ```

## Common Errors and Solutions

### Error: Column does not exist
**Symptoms:**
- `ERROR: 42703: column X does not exist`

**Solution:**
Run the comprehensive fix:
```sql
\i fix_all_column_errors.sql
```

### Error: Cannot change view structure
**Symptoms:**
- `ERROR: 42P16: cannot change name of view column`
- `HINT: Use ALTER VIEW ... RENAME COLUMN`

**Solution:**
Views need to be dropped and recreated:
```sql
\i fix_view_column_error.sql
```

### Error: Check constraint violation
**Symptoms:**
- `ERROR: new row for relation "X" violates check constraint`

**Solution:**
Ensure data matches constraints before inserting. Check valid values in schema.

## Installation Order

### For New Database
```sql
\i 05_quick_setup.sql
```

### For Existing Database
```sql
-- Step 1: Fix all column issues
\i fix_all_column_errors.sql

-- Step 2: Run migration
\i 04_migration_from_existing.sql
```

### Manual Installation
```sql
-- Step 1: Fix columns
\i fix_all_column_errors.sql

-- Step 2: Create schema
\i 01_master_schema.sql

-- Step 3: Add indexes and policies
\i 02_indexes_and_policies.sql

-- Step 4: Load seed data (optional)
\i 03_seed_data.sql
```

## Verification Commands

### Check if columns exist
```sql
-- Check users table
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'users' 
ORDER BY ordinal_position;

-- Check inspection_tasks table
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'inspection_tasks' 
ORDER BY ordinal_position;
```

### Check views
```sql
-- List all views
SELECT viewname FROM pg_views 
WHERE schemaname = 'public';

-- Check view structure
\d user_details
\d active_inspections
```

### Check constraints
```sql
SELECT conname, contype, consrc 
FROM pg_constraint 
WHERE conrelid = 'inspection_tasks'::regclass;
```

## Prevention Tips

1. **Always backup** before running migrations
2. **Use migration script** for existing databases
3. **Run fix_all_column_errors.sql** before main schema
4. **Check logs** for any warnings or errors

## Still Having Issues?

1. Check the migration log:
   ```sql
   SELECT * FROM migration_log ORDER BY executed_at DESC;
   ```

2. Review PostgreSQL version compatibility:
   ```sql
   SELECT version();
   ```

3. Ensure proper permissions:
   ```sql
   SELECT current_user, current_database();
   ```

## File Descriptions

- `01_master_schema.sql` - Complete schema definition
- `02_indexes_and_policies.sql` - Performance and security
- `03_seed_data.sql` - Test data and initial setup
- `04_migration_from_existing.sql` - Safe migration script
- `05_quick_setup.sql` - Fresh installation helper
- `fix_all_column_errors.sql` - Comprehensive column fixes (recommended)
- `fix_state_column.sql` - Fix missing state column
- `fix_view_column_error.sql` - Fix view structure issues
- `fix_priority_column.sql` - Fix missing priority column
- `fix_field_execution_id.sql` - Fix missing field_execution_id column
- `fix_module_column.sql` - Fix missing module column in role_permissions
- `fix_is_active_column.sql` - Fix missing is_active column in roles and products
- `fix_scanned_by_column.sql` - Fix missing scanned_by column in scan_results
