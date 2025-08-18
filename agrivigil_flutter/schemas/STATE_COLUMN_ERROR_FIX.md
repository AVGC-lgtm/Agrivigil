# Fix for State Column Error

## Error
```
ERROR:  42703: column u.state does not exist
LINE 476:     u.state,
              ^
HINT:  Perhaps you meant to reference the column "u.status".
```

## Cause
This error occurs when the schema is being applied to an existing database that doesn't have the `state` column in the `users` table. The `state` column is a new addition to track which state (e.g., Maharashtra) the user belongs to.

## Solutions

### Option 1: Quick Fix (Recommended)
Run this before running the main schema:
```sql
\i fix_state_column.sql
```

### Option 2: Run Full Migration
If you have an existing database, run the complete migration:
```sql
\i 04_migration_from_existing.sql
```

### Option 3: Manual Fix
Run this SQL directly:
```sql
ALTER TABLE users ADD COLUMN state VARCHAR(100) DEFAULT 'Maharashtra';
```

### Option 4: Fresh Installation
If this is a new database, ensure you run the files in order:
```sql
\i 01_master_schema.sql
\i 02_indexes_and_policies.sql
\i 03_seed_data.sql
```

## What Changed

1. Updated `01_master_schema.sql` to automatically add the state column if missing
2. Created `fix_state_column.sql` for quick fixes
3. The migration script (`04_migration_from_existing.sql`) already handles this

## Prevention

Always run the migration script when upgrading an existing database:
- For existing databases: Use `04_migration_from_existing.sql`
- For new databases: Use `05_quick_setup.sql`

## Verification

After fixing, verify the column exists:
```sql
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'users' 
AND column_name = 'state';
```

You should now be able to run the schema files without errors.
