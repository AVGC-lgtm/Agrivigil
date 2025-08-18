# Fix for View Column Name Error

## Error
```
ERROR:  42P16: cannot change name of view column "status" to "state"
HINT:  Use ALTER VIEW ... RENAME COLUMN ... to change name of view column instead.
```

## Cause
This error occurs when trying to use `CREATE OR REPLACE VIEW` on an existing view where:
1. The column names are different
2. The column order has changed
3. The number of columns is different

PostgreSQL doesn't allow changing the structure of a view with `CREATE OR REPLACE`. You must drop and recreate the view.

## Solution

### Quick Fix
Run this before the main schema:
```sql
\i fix_view_column_error.sql
```

### Manual Fix
```sql
-- Drop the existing views
DROP VIEW IF EXISTS user_details CASCADE;
DROP VIEW IF EXISTS active_inspections CASCADE;
DROP VIEW IF EXISTS lab_sample_status CASCADE;

-- Then run your schema files
\i 01_master_schema.sql
```

## What Changed

1. **Updated all schema files** to use `DROP VIEW IF EXISTS` before creating views
2. **Created fix script** `fix_view_column_error.sql` for quick resolution
3. **Migration script** now handles view recreation properly

## Prevention

The updated schema files now:
- Drop views before recreating them
- Handle column structure changes gracefully
- Avoid the CREATE OR REPLACE VIEW limitation

## Technical Details

PostgreSQL's `CREATE OR REPLACE VIEW` can only:
- Change the view definition (the SELECT statement)
- Keep the same column names, types, and order

It cannot:
- Add, remove, or rename columns
- Change column order
- Change column data types

That's why we use `DROP VIEW IF EXISTS CASCADE` before creating views.

## Verification

After fixing, verify the view structure:
```sql
\d user_details
```

You should see all columns including the `state` column.
