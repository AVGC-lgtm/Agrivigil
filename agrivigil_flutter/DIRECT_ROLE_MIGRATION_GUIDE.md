# Direct Role Migration Guide

## Overview
This guide explains the migration from using `role_id` (foreign key) to storing roles directly in the `users` table.

## Current Structure vs New Structure

### Current (Foreign Key Approach)
```sql
users table:
- id
- name
- email
- role_id (references roles.id)
- ...other fields

roles table:
- id
- name
- code
- dashboard_route
- priority
```

### New (Direct Role Approach)
```sql
users table:
- id
- name
- email
- role (VARCHAR - stores role name directly)
- ...other fields

roles table: (optional - can be kept for reference or removed)
```

## Migration Steps

1. **Run the migration script**:
   ```sql
   -- This adds the role column and populates it
   \i migrate_to_direct_role.sql
   ```

2. **Update your application code**:
   - Change queries from `JOIN roles` to direct `role` access
   - Update registration/user creation to set `role` instead of `role_id`

3. **After testing, optionally remove role_id**:
   ```sql
   -- Only after confirming everything works
   ALTER TABLE users DROP CONSTRAINT IF EXISTS users_role_id_fkey;
   ALTER TABLE users DROP COLUMN role_id;
   ```

## Benefits of Direct Role Approach

1. **Simpler Queries**:
   ```sql
   -- Before (with join)
   SELECT u.*, r.name as role_name 
   FROM users u 
   JOIN roles r ON u.role_id = r.id;
   
   -- After (direct)
   SELECT * FROM users;
   ```

2. **Better Performance**: No joins needed for basic user queries

3. **Easier Development**: No need to look up role IDs

## Considerations

1. **Data Integrity**: 
   - Uses CHECK constraint to ensure valid roles
   - Less flexible than foreign key constraint

2. **Role Changes**:
   - Changing role names requires updating all user records
   - With foreign key, only need to update roles table

3. **Storage**:
   - Slightly more storage (storing strings vs UUIDs)
   - Negligible for most applications

## Code Updates Required

### Registration Screen
```dart
// Before
user['role_id'] = selectedRoleId;

// After
user['role'] = selectedRoleName;
```

### Login Screen
```dart
// Before
final dashboardRoute = userData['roles']['dashboard_route'];

// After
final dashboardRoute = getDashboardRoute(userData['role']);
```

### Dashboard Route Mapping
```dart
String getDashboardRoute(String role) {
  switch (role) {
    case 'Field Officer':
      return '/field-officer-dashboard';
    case 'Lab Analyst':
      return '/lab-analyst-dashboard';
    case 'QC Inspector':
      return '/qc-inspector-dashboard';
    case 'District Agriculture Officer':
      return '/dao-dashboard';
    case 'Super Admin':
      return '/admin-dashboard';
    // ... other roles
    default:
      return '/dashboard';
  }
}
```

## Valid Roles
The system now enforces these exact role names:
- Field Officer
- Lab Analyst
- QC Inspector
- District Agriculture Officer
- Legal Officer
- Lab Coordinator
- HQ Monitoring
- District Admin
- Super Admin

## Rollback Plan
If you need to revert to the foreign key approach:
1. Re-add the `role_id` column
2. Populate it from role names
3. Re-establish the foreign key constraint
4. Remove the `role` column

See the rollback section in `migrate_to_direct_role.sql` for exact commands.
