# Role-Based Dashboards Guide - AGRIVIGIL

## Overview
AGRIVIGIL now supports role-based dashboards where users are automatically redirected to their specific dashboard after login based on their assigned role.

## Database Schema

### 1. Roles Table
```sql
CREATE TABLE roles (
    id UUID PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    code VARCHAR(20) UNIQUE NOT NULL,
    description TEXT,
    dashboard_route VARCHAR(100) NOT NULL,
    priority INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 2. Users Table
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    officer_code VARCHAR(50) UNIQUE NOT NULL,
    role_id UUID REFERENCES roles(id),
    district VARCHAR(100) NOT NULL,
    status VARCHAR(20) DEFAULT 'active',
    metadata JSONB DEFAULT '{}',
    last_login TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

## Available Roles and Dashboards

| Role | Code | Dashboard Route | Dashboard Features |
|------|------|----------------|-------------------|
| Field Officer | FO | /field-officer-dashboard | Inspections, Product Scanning, Seizures |
| Lab Analyst | LA | /lab-analyst-dashboard | Lab Tests, Sample Management, Reports |
| QC Inspector | QC | /qc-inspector-dashboard | Quality Control, Compliance, ABC Analysis |
| District Agriculture Officer | DAO | /dao-dashboard | Team Management, District Overview, Analytics |
| Legal Officer | LO | /legal-officer-dashboard | Legal Cases, FIR Management |
| Lab Coordinator | LC | /lab-coordinator-dashboard | Lab Operations, Resource Management |
| HQ Monitoring | HQ | /hq-monitoring-dashboard | System Monitoring, Reports |
| District Admin | DA | /district-admin-dashboard | District Administration |
| Super Admin | SA | /admin-dashboard | Full System Access |

## Role Dashboard Features

### 1. Field Officer Dashboard
- **Quick Stats**: Today's inspections, pending tasks, samples collected, seizures
- **Quick Actions**: New inspection, scan product, log seizure, view tasks
- **Recent Activities**: Latest inspection activities with timestamps

### 2. Lab Analyst Dashboard
- **Lab Overview**: Pending tests, in-progress, completed, failed samples
- **Lab Actions**: New test, view samples, test reports, equipment
- **Test Progress Chart**: Visual representation of test status
- **Recent Test Results**: Pass/fail status with sample numbers

### 3. QC Inspector Dashboard
- **QC Overview**: Daily inspections, non-compliance, approved, pending review
- **Compliance Rate**: Monthly compliance percentage with progress bar
- **QC Actions**: New inspection, compliance check, review reports, ABC analysis
- **Recent Inspections**: Status tracking (Approved/Rejected/Pending)

### 4. District Agriculture Officer Dashboard
- **District Overview**: Total inspections, field officers, active cases, compliance rate
- **Monthly Performance**: Bar chart showing weekly performance metrics
- **Management Actions**: View reports, assign tasks, team overview, analytics
- **Team Performance**: Individual officer performance tracking

## Implementation Details

### 1. Role Dashboard Mapper
```dart
// lib/utils/role_dashboard_mapper.dart
class RoleDashboardMapper {
  static String getDashboardRoute(String? roleName) {
    // Maps role names to their dashboard routes
  }
}
```

### 2. Login Flow
```dart
// After successful login
final userRole = authProvider.user?.role?.name;
final dashboardRoute = RoleDashboardMapper.getDashboardRoute(userRole);
Navigator.pushReplacementNamed(context, dashboardRoute);
```

### 3. Registration Flow
```dart
// After successful registration and auto-login
final dashboardRoute = RoleDashboardMapper.getDashboardRoute(_selectedRole);
Navigator.pushReplacementNamed(context, dashboardRoute);
```

## Setup Instructions

### 1. Database Setup
Run the `supabase_perfect_schema.sql` file in your Supabase SQL editor to:
- Create roles and users tables
- Insert default roles with dashboard routes
- Set up indexes and triggers
- Enable Row Level Security

### 2. Testing Different Roles
1. Create test users with different roles:
```sql
-- Example: Create a Field Officer
INSERT INTO users (email, name, password, phone, officer_code, role_id, district)
SELECT 
  'field.officer@test.com',
  'Test Field Officer',
  'password123',
  '9876543210',
  'FO-TEST-001',
  id,
  'Mumbai'
FROM roles WHERE code = 'FO';
```

### 3. Adding New Roles
1. Insert new role in database:
```sql
INSERT INTO roles (name, code, description, dashboard_route, priority)
VALUES ('New Role', 'NR', 'Description', '/new-role-dashboard', 10);
```

2. Update `RoleDashboardMapper` to include the new role
3. Create the dashboard screen for the new role
4. Add route in `AppRoutes`

## Security Considerations

1. **Role Validation**: Always validate user roles on the backend
2. **Route Guards**: Implement route guards to prevent unauthorized access
3. **API Security**: Ensure API endpoints check user roles before returning data
4. **RLS Policies**: Use Supabase Row Level Security for data access control

## Customization

### Modifying Dashboard Content
Each dashboard is in `lib/screens/dashboards/[role]_dashboard.dart`. You can:
- Add new stat cards
- Modify quick actions
- Change chart types
- Update color schemes

### Adding Role-Specific Features
1. Create new modules in `lib/screens/modules/[role]/`
2. Add navigation to the role's dashboard
3. Update permissions in the backend

## Troubleshooting

### User Redirected to Wrong Dashboard
1. Check the role name in the database
2. Verify `RoleDashboardMapper` has the correct mapping
3. Ensure the user's role is properly loaded in `AuthProvider`

### Dashboard Not Loading
1. Verify the route is registered in `AppRoutes`
2. Check if the dashboard widget is properly imported
3. Look for any console errors

### Permission Issues
1. Check RLS policies in Supabase
2. Verify the user's role has proper permissions
3. Check API endpoint security

## Next Steps

1. **Implement Route Guards**: Add middleware to check permissions before accessing routes
2. **Add More Dashboards**: Create dashboards for remaining roles
3. **Enhance Features**: Add more role-specific features to each dashboard
4. **Analytics Integration**: Add real data visualization to dashboards
5. **Notification System**: Implement role-based notifications
