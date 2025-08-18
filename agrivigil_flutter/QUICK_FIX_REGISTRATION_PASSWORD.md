# Quick Fix for Registration Password Error

## Problem
Registration was failing with: `null value in column "password" of relation "users" violates not-null constraint`

## Solution Applied

### Fixed in `lib/screens/auth/register_screen.dart`:

1. **Added password field** to the user profile insert (line 432):
   ```dart
   'password': _passwordController.text, // Added password field
   ```

2. **Fixed column names** to match database:
   - Changed `'role'` to `'role_id'` 
   - This expects the UUID of the role, not the role name

3. **Added metadata field** as expected by the database schema

## IMPORTANT: Before Testing Registration

### 1. Run the Roles Setup SQL
You MUST run this in your Supabase SQL Editor first:
```sql
-- Create roles if they don't exist
INSERT INTO roles (name, description) VALUES
    ('Field Officer', 'Field inspection and execution officer'),
    ('District Agriculture Officer', 'District level agriculture officer'),
    ('Legal Officer', 'Legal and compliance officer'),
    ('Lab Coordinator', 'Laboratory coordination and management'),
    ('HQ Monitoring', 'Headquarters monitoring team'),
    ('District Admin', 'District administration'),
    ('QC Inspector', 'Quality Control inspector'),
    ('Lab Analyst', 'Laboratory analyst')
ON CONFLICT (name) DO NOTHING;
```

### 2. The Registration Form
When the form loads, it will:
- Fetch roles from the database
- Show actual role names in dropdown
- Use role UUIDs (not names) when submitting

### 3. Test Registration
Now you can register with:
- Email: gaffffffff@gmail.com (or any email)
- Name: Ganesh
- Officer Code: 1233 (or any unique code)
- Password: Your password
- Select role from dropdown
- Fill other fields

## Note on Security
⚠️ Currently storing plain text passwords for development. In production, implement proper password hashing!
