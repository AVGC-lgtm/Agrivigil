# AGRIVIGIL Flutter App

A comprehensive Flutter application for agricultural inspection and monitoring system with Supabase integration.

## Features

- 🔐 **Authentication System** with role-based permissions
- 📊 **Dashboard** with real-time statistics and charts
- 👥 **User & Role Management** 
- 📋 **Inspection Planning** and scheduling
- 📸 **Field Execution** with product scanning
- 📦 **Seizure Logging** and tracking
- 🔬 **Lab Interface** for sample management
- ⚖️ **Legal Module** for FIR cases
- 📈 **Reports & Audit** system
- 📝 **AgriForm Portal** for form management

## Setup Instructions

### Prerequisites

1. Install Flutter SDK (3.0.0 or higher)
2. Install Android Studio / Xcode for mobile development
3. Install VS Code or Android Studio with Flutter plugins

### Installation

1. Navigate to the Flutter app directory:
```bash
cd agrivigil_flutter
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
# For Android
flutter run

# For iOS
flutter run

# For Web
flutter run -d chrome
```

## Supabase Configuration

The app is pre-configured with your Supabase instance:
- **URL**: https://nfimezdvvbohfryzllem.supabase.co
- **Anon Key**: Already configured in `lib/config/supabase_config.dart`

### Database Schema Setup

The app expects the following tables in your Supabase database:

1. **users** - User accounts
2. **roles** - User roles
3. **role_permissions** - Role-based permissions
4. **inspection_tasks** - Inspection planning
5. **field_executions** - Field inspection data
6. **seizures** - Seized items
7. **lab_samples** - Lab sample tracking
8. **fir_cases** - Legal cases
9. **products** - Product database
10. **scan_results** - Product scan results

Run the Prisma migrations from your server folder to set up the database:
```bash
cd ../server
npx prisma migrate deploy
```

## Project Structure

```
agrivigil_flutter/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── config/
│   │   └── supabase_config.dart  # Supabase configuration
│   ├── models/                   # Data models
│   │   ├── user_model.dart
│   │   ├── inspection_model.dart
│   │   ├── seizure_model.dart
│   │   └── ...
│   ├── providers/                # State management
│   │   ├── auth_provider.dart
│   │   └── permission_provider.dart
│   ├── screens/                  # UI screens
│   │   ├── auth/
│   │   ├── dashboard/
│   │   └── modules/
│   ├── services/                 # API services
│   │   ├── user_service.dart
│   │   ├── inspection_service.dart
│   │   └── ...
│   ├── widgets/                  # Reusable widgets
│   └── utils/                    # Utilities
│       └── theme.dart
├── assets/                       # Images, fonts, etc.
└── pubspec.yaml                  # Dependencies
```

## Key Features Implementation

### Authentication
- Email/Password login
- Super User access (super@gmail.com / 123)
- Role-based permissions (Full/Read/None)
- Secure token storage

### Dashboard
- Real-time statistics cards
- Interactive charts (Line, Pie)
- Recent activity feed
- Responsive design

### User Management
- Create/Edit/Delete users
- Role assignment
- Permission matrix
- Officer code management

### Inspection Planning
- Create inspection tasks
- Assign officers
- Track progress
- Multi-step workflow

### Field Execution
- Product scanning
- Photo capture
- GPS location tracking
- Offline capability

### Seizure Logging
- Log seized items
- Evidence photos/videos
- Witness information
- Chain of custody

### Lab Interface
- Sample tracking
- Test results
- Report generation
- Status updates

### Legal Module
- FIR case filing
- Court date tracking
- Document management
- Case outcomes

## Super User Access

For testing, use the Super User credentials:
- **Email**: super@gmail.com
- **Password**: 123

Super User has full access to all modules.

## Development

### Adding New Features

1. Create model in `lib/models/`
2. Add service in `lib/services/`
3. Create UI in `lib/screens/`
4. Update navigation in dashboard

### State Management

The app uses Provider for state management:
- `AuthProvider` - Authentication state
- `PermissionProvider` - Role permissions

### API Integration

All API calls go through Supabase client:
```dart
final response = await _supabase
    .from('table_name')
    .select()
    .eq('column', value);
```

## Building for Production

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## Troubleshooting

1. **Flutter not found**: Ensure Flutter is in your PATH
2. **Dependencies error**: Run `flutter clean` then `flutter pub get`
3. **Build errors**: Check minimum SDK versions in `android/app/build.gradle`
4. **iOS issues**: Run `cd ios && pod install`

## Support

For issues or questions:
- Company: Dawell Lifescience Private Limited
- Contact: 9850647444

## License

© 2025 Agrivigil - All rights reserved.
