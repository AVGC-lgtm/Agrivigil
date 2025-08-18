# Fix for scanned_by Column Error

## Error
```
ERROR:  42703: column "scanned_by" does not exist
```

## Cause
This error occurs because the `scanned_by` column doesn't exist in your existing `scan_results` table. This column tracks which user performed the product scan, enabling audit trails and user-specific scan history.

## Solutions

### Option 1: Quick Fix All Issues (Recommended)
Run the comprehensive fix that handles all missing columns:
```sql
\i fix_all_column_errors.sql
```

### Option 2: Fix Only Scan Results Columns
```sql
\i fix_scanned_by_column.sql
```

### Option 3: Manual Fix
```sql
-- Add the missing columns
ALTER TABLE scan_results ADD COLUMN scanned_by UUID REFERENCES users(id);
ALTER TABLE scan_results ADD COLUMN device_info JSONB;
ALTER TABLE scan_results ADD COLUMN updated_at TIMESTAMPTZ DEFAULT NOW();
```

### Option 4: Run Full Migration
For existing databases with multiple issues:
```sql
\i 04_migration_from_existing.sql
```

## New Columns in scan_results

The updated schema adds several columns to enhance scan tracking:

| Column | Type | Purpose |
|--------|------|---------|
| `scanned_by` | UUID | Links scan to user who performed it |
| `device_info` | JSONB | Stores device metadata (OS, app version, etc.) |
| `updated_at` | TIMESTAMPTZ | Tracks when scan record was last modified |

## What Changed

1. **Updated `02_indexes_and_policies.sql`** 
   - Added conditional index creation for scanned_by
   - Made RLS policy conditional on column existence
   - Added pre-check warnings

2. **Created `fix_scanned_by_column.sql`** for targeted fix
3. **Updated `fix_all_column_errors.sql`** to include all scan_results columns
4. **Updated `04_migration_from_existing.sql`** to handle these columns

## Benefits

1. **User Tracking**: Know who performed each scan
2. **Device Analytics**: Track scan patterns by device type
3. **Audit Trail**: Complete history of scan activities
4. **Performance**: Indexed for fast user-specific queries

## Security Implications

The `scanned_by` column enables Row Level Security policies:
- Users can only view their own scan results
- Admins can view all scans
- Prevents unauthorized access to scan data

## Verification

After fixing, verify the columns and relationships:
```sql
-- Check columns exist
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'scan_results' 
AND column_name IN ('scanned_by', 'device_info', 'updated_at')
ORDER BY ordinal_position;

-- Check foreign key constraint
SELECT conname 
FROM pg_constraint 
WHERE conrelid = 'scan_results'::regclass 
AND confrelid = 'users'::regclass;

-- Check index
SELECT indexname 
FROM pg_indexes 
WHERE tablename = 'scan_results' 
AND indexname LIKE '%scanned_by%';

-- Test the RLS policy
SELECT policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename = 'scan_results';
```

## Sample Query

After adding the column, you can query user-specific scans:
```sql
-- Get all scans by a specific user
SELECT sr.*, u.name as scanned_by_name, p.name as product_name
FROM scan_results sr
JOIN users u ON sr.scanned_by = u.id
LEFT JOIN products p ON sr.product_id = p.id
WHERE u.email = 'user@example.com'
ORDER BY sr.timestamp DESC;
```

## Migration Note

If you have existing scan_results data without the scanned_by column, you may want to:
1. Set a default user for existing records
2. Or leave them NULL (allowed by the schema)
3. Or delete old records if not needed

Example to set a default user:
```sql
-- Set all existing scans to a system user (optional)
UPDATE scan_results 
SET scanned_by = (SELECT id FROM users WHERE email = 'system@agrivigil.com')
WHERE scanned_by IS NULL;
```
