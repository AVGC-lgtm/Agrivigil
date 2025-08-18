# Fix for Module Column Error

## Error
```
ERROR:  42703: column "module" does not exist
```

## Cause
This error occurs because the `module` column doesn't exist in your existing `role_permissions` table. This column is used to organize permissions by module (e.g., 'field_operations', 'laboratory', 'quality_control') for better role-based access control.

## Solutions

### Option 1: Quick Fix All Issues (Recommended)
Run the comprehensive fix that handles all missing columns:
```sql
\i fix_all_column_errors.sql
```

### Option 2: Fix Only Module Column
```sql
\i fix_module_column.sql
```

### Option 3: Manual Fix
```sql
-- Add the missing column
ALTER TABLE role_permissions ADD COLUMN module VARCHAR(50);

-- Set default value for existing rows
UPDATE role_permissions SET module = 'all' WHERE module IS NULL;

-- Make it NOT NULL
ALTER TABLE role_permissions ALTER COLUMN module SET NOT NULL;

-- Add unique constraint
ALTER TABLE role_permissions ADD CONSTRAINT role_permissions_role_id_module_key 
    UNIQUE(role_id, module);
```

### Option 4: Run Full Migration
For existing databases with multiple issues:
```sql
\i 04_migration_from_existing.sql
```

## Role Permissions Structure

The updated `role_permissions` table structure:
```sql
CREATE TABLE role_permissions (
    id UUID PRIMARY KEY,
    role_id UUID REFERENCES roles(id),
    module VARCHAR(50) NOT NULL,        -- Module name
    menu_id TEXT[],                     -- Array of menu IDs
    auth_type TEXT[],                   -- Array of permissions (R,W,D,F)
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    UNIQUE(role_id, module)             -- One permission set per role per module
);
```

## Module Examples

Common modules in the system:
- `all` - Full system access (Super Admin)
- `field_operations` - Field inspection and execution
- `laboratory` - Lab sample management
- `quality_control` - QC inspections and compliance
- `legal` - Legal cases and FIR management
- `district_management` - District-level operations

## What Changed

1. **Updated `02_indexes_and_policies.sql`** to check for column before creating index
2. **Created `fix_module_column.sql`** for targeted fix
3. **Updated `fix_all_column_errors.sql`** to include this column
4. **Updated `04_migration_from_existing.sql`** to handle this column

## Benefits

1. **Modular Permissions**: Organize permissions by functional modules
2. **Granular Control**: Different permission sets for different modules
3. **Scalability**: Easy to add new modules without changing schema
4. **Audit Trail**: Track which modules users have access to

## Verification

After fixing, verify the column and constraint:
```sql
-- Check column exists
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'role_permissions' 
AND column_name = 'module';

-- Check unique constraint
SELECT conname 
FROM pg_constraint 
WHERE conrelid = 'role_permissions'::regclass 
AND contype = 'u';

-- View existing permissions
SELECT r.name as role, rp.module, rp.menu_id, rp.auth_type
FROM role_permissions rp
JOIN roles r ON rp.role_id = r.id
ORDER BY r.name, rp.module;
```

## Index Considerations

The `02_indexes_and_policies.sql` file now includes checks before creating indexes on columns that might not exist yet. This prevents errors when running the indexes script on existing databases.
