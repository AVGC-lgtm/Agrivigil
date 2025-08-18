# User Registration Guide - AGRIVIGIL Flutter App

## Overview

The user registration feature allows new users to create accounts in the AGRIVIGIL system. This guide covers the registration flow, implementation details, and configuration options.

## Features

### Registration Form Fields

1. **Full Name** (Required)
   - User's complete name
   - Minimum 3 characters
   - Text capitalization enabled

2. **Email Address** (Required)
   - Valid email format
   - Unique in the system
   - Used for login

3. **Officer Code** (Required)
   - Unique identifier for officers
   - Uppercase alphanumeric only
   - Minimum 4 characters

4. **Role Selection** (Required)
   - Dropdown with available roles
   - Excludes Super Admin role
   - Available roles:
     - Field Officer
     - District Agriculture Officer
     - Legal Officer
     - Lab Coordinator
     - HQ Monitoring
     - District Admin
     - QC Inspector
     - Lab Analyst

5. **Department** (Required, shown after role selection)
   - User's department/division

6. **Phone Number** (Required)
   - Contact number with country code
   - Minimum 10 digits

7. **District** (Required)
   - User's assigned district

8. **Password** (Required)
   - Minimum 8 characters
   - Must contain:
     - At least one uppercase letter
     - At least one lowercase letter
     - At least one number
     - At least one special character

9. **Confirm Password** (Required)
   - Must match the password field

10. **Terms and Conditions** (Required)
    - Checkbox to accept terms
    - Links to Terms and Privacy Policy

## Implementation Details

### Files Created/Modified

1. **`lib/screens/auth/register_screen.dart`**
   - Complete registration UI
   - Form validation
   - Integration with auth provider

2. **`lib/providers/auth_provider.dart`**
   - Added `register()` method
   - Validates unique email and officer code
   - Creates user with metadata
   - Logs registration in audit

3. **`lib/models/user_model.dart`**
   - Added `metadata` field for additional user info
   - Helper getters for metadata fields:
     - `phone`
     - `department`
     - `district`
     - `registeredAt`

4. **`lib/routes/app_routes.dart`**
   - Added `/register` route
   - Imported RegisterScreen

5. **`lib/screens/auth/login_screen.dart`**
   - Added "Register" link below login button

## Database Schema

The registration process creates entries in the following tables:

### Users Table
```sql
{
  id: string (auto-generated),
  email: string (unique),
  password: string (hashed in production),
  name: string,
  officerCode: string (unique),
  roleId: string (foreign key),
  metadata: {
    phone: string,
    department: string,
    district: string,
    registeredAt: string (ISO timestamp)
  },
  createdAt: timestamp,
  updatedAt: timestamp
}
```

### Audit Log Entry
```sql
{
  userId: string,
  action: 'USER_REGISTERED',
  module: 'AUTH',
  details: {
    name: string,
    email: string,
    roleId: string,
    district: string
  },
  createdAt: timestamp
}
```

## Security Considerations

### Current Implementation (Development)
- Passwords stored as plain text (for development only)
- Email and officer code uniqueness validation
- Client-side validation

### Production Recommendations
1. **Password Hashing**
   - Use bcrypt or similar for password hashing
   - Never store plain text passwords

2. **Email Verification**
   - Implement email verification flow
   - Send confirmation emails

3. **Rate Limiting**
   - Prevent registration spam
   - Implement CAPTCHA for public registration

4. **Additional Validations**
   - Officer code format validation against organization standards
   - District validation against approved list
   - Role approval workflow for sensitive roles

## Usage Flow

1. User clicks "Register" link on login page
2. Fills out registration form
3. System validates:
   - All required fields
   - Email uniqueness
   - Officer code uniqueness
   - Password strength
4. On success:
   - User account created
   - Audit log entry created
   - Success message shown
   - Redirected to login page
5. On failure:
   - Error message displayed
   - Form remains populated

## Customization Options

### Adding New Roles
Edit the `_availableRoles` list in `register_screen.dart`:
```dart
final List<Map<String, String>> _availableRoles = [
  {'id': 'new-role-id', 'name': 'New Role Name'},
  // ... existing roles
];
```

### Custom Validation Rules
Add validators in the form fields:
```dart
validator: FormBuilderValidators.compose([
  FormBuilderValidators.required(),
  // Add custom validators here
]),
```

### Additional Metadata Fields
1. Add fields to the registration form
2. Update the `register()` method in auth provider
3. Add to metadata object:
```dart
'metadata': {
  'phone': phone,
  'department': department,
  'district': district,
  'customField': customValue, // New field
  'registeredAt': DateTime.now().toIso8601String(),
},
```

## Testing

### Test Cases
1. **Valid Registration**
   - All fields filled correctly
   - Unique email and officer code
   - Strong password

2. **Duplicate Email**
   - Try registering with existing email
   - Should show error

3. **Duplicate Officer Code**
   - Try registering with existing officer code
   - Should show error

4. **Weak Password**
   - Test various weak passwords
   - Should show specific error messages

5. **Form Validation**
   - Leave required fields empty
   - Enter invalid formats
   - Password mismatch

### Test Credentials
For testing, you can use:
- Email: test.user@example.com
- Officer Code: TEST001
- Password: Test@123

## API Integration

The registration integrates with Supabase:
```dart
await _supabase
    .from('users')
    .insert({
      'email': email,
      'password': password,
      'name': name,
      'officerCode': officerCode,
      'roleId': roleId,
      'metadata': metadata,
    })
    .select()
    .single();
```

## Next Steps

1. **Production Setup**
   - Implement proper password hashing
   - Add email verification
   - Set up role approval workflow

2. **Enhanced Features**
   - Profile photo upload
   - Multi-factor authentication
   - Social login options

3. **Admin Features**
   - User approval dashboard
   - Bulk user import
   - Registration analytics

## Troubleshooting

### Common Issues

1. **Registration Fails**
   - Check Supabase connection
   - Verify table permissions
   - Check for unique constraint violations

2. **Form Not Submitting**
   - Verify all required fields are filled
   - Check browser console for errors
   - Ensure terms are accepted

3. **Role Not Available**
   - Verify role exists in database
   - Check role permissions
   - Update available roles list

For additional support, check the main documentation or contact the development team.
