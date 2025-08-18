# Fix for Priority Column Error

## Error
```
ERROR:  42703: column it.priority does not exist
LINE 510:     it.priority,
              ^
```

## Cause
This error occurs because the `priority` column doesn't exist in your existing `inspection_tasks` table. The priority column is a new addition that allows categorizing inspections by urgency (low, normal, high, urgent).

## Solutions

### Option 1: Quick Fix All Issues (Recommended)
Run this comprehensive fix that handles all missing columns:
```sql
\i fix_all_column_errors.sql
```

### Option 2: Fix Only Priority Column
```sql
\i fix_priority_column.sql
```

### Option 3: Manual Fix
```sql
ALTER TABLE inspection_tasks ADD COLUMN priority VARCHAR(20) DEFAULT 'normal';
ALTER TABLE inspection_tasks ADD CONSTRAINT inspection_tasks_priority_check 
    CHECK (priority IN ('low', 'normal', 'high', 'urgent'));
```

### Option 4: Run Full Migration
For existing databases with multiple issues:
```sql
\i 04_migration_from_existing.sql
```

## New Columns Added

The schema adds several new columns to enhance functionality:

### inspection_tasks table:
- `priority` - Task priority level
- `assigned_team` - Array of user IDs for team assignments
- `metadata` - JSONB field for flexible additional data

### users table:
- `state` - User's state (default: Maharashtra)
- `phone` - Contact number
- `district` - User's district
- `last_login` - Track last login time

## What Changed

1. Updated `01_master_schema.sql` to check for priority column before using it in views
2. Created `fix_priority_column.sql` for targeted fix
3. Created `fix_all_column_errors.sql` for comprehensive fixes
4. Migration script already handles these columns

## Prevention

Always use the appropriate script based on your situation:
- **New installation**: Use `05_quick_setup.sql`
- **Existing database**: Use `04_migration_from_existing.sql`
- **Quick fixes**: Use `fix_all_column_errors.sql`

## Verification

After fixing, verify the columns exist:
```sql
-- Check inspection_tasks columns
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'inspection_tasks' 
AND column_name IN ('priority', 'assigned_team', 'metadata');

-- Check users columns
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'users' 
AND column_name IN ('state', 'phone', 'district', 'last_login');
```

## Benefits of New Columns

1. **Priority**: Better task management and sorting
2. **Assigned Team**: Support for team-based assignments
3. **Metadata**: Flexible storage for additional data without schema changes
4. **State/District**: Better geographical organization
5. **Phone**: Complete user contact information
6. **Last Login**: User activity tracking
