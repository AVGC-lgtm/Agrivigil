# Registration UUID Error Fix

## Problem
The registration was failing with error: `invalid input syntax for type uuid: "field-officer"` because the system was trying to use role names instead of role UUIDs.

## Solution Applied

### 1. Database Changes
Run the contents of `fix_roles_for_registration.sql` in your Supabase SQL Editor:
```sql
-- This will create all the required roles with proper UUIDs
-- The script is safe to run multiple times
```

### 2. Code Changes

#### Created `lib/services/role_service.dart`
- Service to fetch roles from database
- Gets actual UUID values for roles

#### Updated `lib/screens/auth/register_screen.dart`
- Now fetches roles from database on screen load
- Uses actual role IDs (UUIDs) instead of hardcoded strings
- Shows loading spinner while fetching roles

## To Fix Your Registration:

1. **Run the SQL Fix** (Most Important!)
   - Open Supabase SQL Editor
   - Copy and run the contents of `fix_roles_for_registration.sql`
   - This creates all roles with proper UUIDs

2. **Hot Restart Your App**
   - The registration screen will now fetch roles from database
   - Role dropdown will use actual UUIDs

3. **Register Successfully**
   - Fill the form as before
   - Select any role from dropdown
   - Registration will now work!

## What Changed:

### Before (Error):
- Role dropdown used hardcoded strings like "field-officer"
- Database expected UUID values

### After (Fixed):
- Role dropdown fetches actual roles from database
- Uses real UUID values like "123e4567-e89b-12d3-a456-426614174000"

## Test Registration:
- Email: test@example.com
- Officer Code: TEST001
- Role: Select any from dropdown
- Password: Test@123

The registration should now complete successfully! 🎉
