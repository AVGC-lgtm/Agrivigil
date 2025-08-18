# Database Migration Guide - AGRIVIGIL Flutter App

## Database Column Name Fixes

The registration error was caused by mismatched column names between the Flutter code (camelCase) and the PostgreSQL database (snake_case). 

### Changes Required:

## 1. Update Your Supabase Database

Run the following SQL commands in your Supabase SQL Editor to fix the database:

```sql
-- Add metadata column to users table if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT column_name 
                   FROM information_schema.columns 
                   WHERE table_name='users' AND column_name='metadata') THEN
        ALTER TABLE users ADD COLUMN metadata JSONB;
    END IF;
END $$;

-- Add unique constraint to officer_code if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT constraint_name 
                   FROM information_schema.table_constraints 
                   WHERE table_name = 'users' 
                   AND constraint_type = 'UNIQUE' 
                   AND constraint_name = 'users_officer_code_key') THEN
        ALTER TABLE users ADD CONSTRAINT users_officer_code_key UNIQUE (officer_code);
    END IF;
END $$;
```

## 2. Code Changes Applied

The following files have been updated to use the correct database column names:

### **lib/providers/auth_provider.dart**
- Changed `officerCode` → `officer_code`
- Changed `roleId` → `role_id`
- Changed `userId` → `user_id`

### **lib/models/user_model.dart**
- Updated `UserModel.fromJson()` to use snake_case column names:
  - `officer_code` instead of `officerCode`
  - `role_id` instead of `roleId`
  - `created_at` instead of `createdAt`
  - `updated_at` instead of `updatedAt`
- Updated `RoleModel.fromJson()` with correct column names
- Updated `RolePermissionModel.fromJson()` with correct column names

### **supabase_schema.sql**
- Added `metadata JSONB` column to users table
- Made `officer_code` column UNIQUE
- Added migration scripts at the end for existing databases

## 3. Column Name Reference

### Users Table
| Flutter Property | Database Column |
|-----------------|-----------------|
| id | id |
| email | email |
| name | name |
| officerCode | officer_code |
| password | password |
| roleId | role_id |
| metadata | metadata |
| createdAt | created_at |
| updatedAt | updated_at |

### Common Database Naming Convention
PostgreSQL uses snake_case for column names:
- `user_id` not `userId`
- `officer_code` not `officerCode`
- `created_at` not `createdAt`

## 4. Testing the Fix

1. **Hot Restart** your Flutter app
2. Try registering a new user
3. The registration should now work without database errors

## 5. Important Notes

- PostgreSQL is case-sensitive for quoted identifiers
- Always use snake_case for database column names
- Use camelCase in Flutter/Dart code
- The models handle the conversion between naming conventions

## 6. If You Still Get Errors

If you encounter any remaining database errors:

1. Check the exact error message for the column name
2. Verify the column exists in your database:
   ```sql
   SELECT column_name 
   FROM information_schema.columns 
   WHERE table_name = 'users';
   ```
3. Make sure all column names match the snake_case convention
4. Run the migration SQL commands above if needed
