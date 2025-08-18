# Fix for Field Execution ID Column Error

## Error
```
ERROR:  42703: column ls.field_execution_id does not exist
LINE 548: LEFT JOIN field_executions fe ON ls.field_execution_id = fe.id;
                                           ^
```

## Cause
This error occurs because the `field_execution_id` column doesn't exist in your existing `lab_samples` table. This column links lab samples to their corresponding field executions, creating a traceable connection between field inspections and laboratory testing.

## Solutions

### Option 1: Quick Fix All Issues (Recommended)
Run the comprehensive fix that handles all missing columns:
```sql
\i fix_all_column_errors.sql
```

### Option 2: Fix Only Field Execution ID
```sql
\i fix_field_execution_id.sql
```

### Option 3: Manual Fix
```sql
-- Add the missing column
ALTER TABLE lab_samples ADD COLUMN field_execution_id INTEGER REFERENCES field_executions(id);

-- If you also need other lab_samples columns
ALTER TABLE lab_samples ADD COLUMN priority VARCHAR(20) DEFAULT 'normal';
ALTER TABLE lab_samples ADD COLUMN test_parameters JSONB;
```

### Option 4: Run Full Migration
For existing databases with multiple issues:
```sql
\i 04_migration_from_existing.sql
```

## New Columns in lab_samples

The updated schema adds several columns to enhance lab sample tracking:

| Column | Type | Purpose |
|--------|------|---------|
| `field_execution_id` | INTEGER | Links sample to field execution |
| `priority` | VARCHAR(20) | Sample testing priority |
| `test_parameters` | JSONB | Flexible storage for test parameters |

## What Changed

1. Updated `01_master_schema.sql` to check for field_execution_id before using it
2. Created `fix_field_execution_id.sql` for targeted fix
3. Updated `fix_all_column_errors.sql` to include this column
4. Migration script already handles this column

## Relationship Structure

```
field_executions (inspection data)
    ↓
    └── field_execution_id (foreign key)
            ↓
        lab_samples (laboratory testing)
            ↓
            └── sample_id (foreign key)
                    ↓
                lab_test_results (test outcomes)
```

## Benefits

1. **Traceability**: Direct link from field inspection to lab testing
2. **Data Integrity**: Foreign key ensures valid references
3. **Reporting**: Easy to generate reports linking field and lab data
4. **Workflow**: Supports the inspection → sampling → testing workflow

## Verification

After fixing, verify the column exists and relationships are correct:
```sql
-- Check column exists
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'lab_samples' 
AND column_name IN ('field_execution_id', 'priority', 'test_parameters');

-- Check foreign key constraint
SELECT conname 
FROM pg_constraint 
WHERE conrelid = 'lab_samples'::regclass 
AND confrelid = 'field_executions'::regclass;

-- Test the view
SELECT * FROM lab_sample_status LIMIT 5;
```

## Related Tables

- **field_executions**: Contains field inspection execution data
- **lab_samples**: Laboratory sample information
- **lab_test_results**: Individual test results for samples
- **seizures**: Can also link to lab_samples via seizure_id
