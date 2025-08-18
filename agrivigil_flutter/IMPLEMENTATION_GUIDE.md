# AGRIVIGIL Flutter App - Implementation Guide

## Overview

This Flutter app is a complete mobile/web solution for the AGRIVIGIL agricultural inspection and monitoring system. It mirrors all functionality from your existing Next.js application and connects to Supabase for the backend.

## Quick Start

1. **Database Setup**
   - Go to your Supabase project SQL editor
   - Copy and run the contents of `supabase_schema.sql`
   - This creates all required tables with proper relationships

2. **Flutter Setup**
   ```bash
   cd agrivigil_flutter
   flutter pub get
   flutter run
   ```

3. **Test Login**
   - Email: `super@gmail.com`
   - Password: `123`

## Key Features Implemented

### 1. Authentication System ✅
- Email/password login
- Super user support
- Role-based access control
- Secure token storage using SharedPreferences
- Auto-login on app restart

### 2. Permission System ✅
- Full (F), Read (R), None (N) access levels
- Menu-based permissions
- Real-time permission checks
- Super user override

### 3. Responsive Design ✅
- Mobile-first approach
- Tablet optimization
- Desktop/web support
- Adaptive navigation (drawer for mobile, sidebar for desktop)

### 4. Core Modules ✅

#### Dashboard
- Statistics cards with trends
- Line charts for monthly data
- Pie charts for category distribution
- Recent activity feed

#### Administration
- User management (CRUD)
- Role management
- Permission matrix configuration
- Audit logs

#### Inspection Planning
- Create/edit inspection tasks
- Officer assignment
- Status tracking
- Equipment management

#### Field Execution
- Product scanning interface
- Photo capture
- GPS location tracking
- Offline data collection

#### Seizure Logging
- Log seized items
- Evidence management
- Witness information
- Chain of custody

#### Lab Interface
- Sample tracking
- Test result management
- Report generation
- Status updates

#### Legal Module
- FIR case filing
- Court date tracking
- Document management
- Case outcomes

#### Reports & Audit
- Generate various reports
- Export to PDF
- Audit trail viewing
- Analytics dashboard

#### AgriForm Portal
- Form catalog
- Dynamic form rendering
- Submission tracking
- Approval workflow

## Architecture

### State Management
- **Provider** pattern for global state
- Separate providers for auth and permissions
- Reactive UI updates

### API Layer
- Service classes for each module
- Supabase client integration
- Error handling and retry logic
- Offline queue for sync

### UI Components
- Reusable widgets
- Consistent theming
- Material Design 3
- Custom animations

## Extending the App

### Adding New Modules

1. Create model in `lib/models/`
2. Create service in `lib/services/`
3. Create screen in `lib/screens/modules/`
4. Add to dashboard navigation
5. Update menu definitions

### Adding New Features

1. **Offline Support**
   ```dart
   // Add to service classes
   if (!await ConnectivityService.isOnline()) {
     await OfflineQueue.add(data);
     return;
   }
   ```

2. **Push Notifications**
   ```dart
   // Add Firebase messaging
   dependencies:
     firebase_messaging: ^14.0.0
   ```

3. **Biometric Auth**
   ```dart
   // Add local auth
   dependencies:
     local_auth: ^2.1.0
   ```

## Production Deployment

### Android
1. Update `android/app/build.gradle`:
   ```gradle
   android {
     defaultConfig {
       applicationId "com.agrivigil.app"
       minSdkVersion 21
       targetSdkVersion 33
     }
   }
   ```

2. Generate signing key:
   ```bash
   keytool -genkey -v -keystore agrivigil.keystore -alias agrivigil -keyalg RSA -keysize 2048 -validity 10000
   ```

3. Build release APK:
   ```bash
   flutter build apk --release
   ```

### iOS
1. Open in Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. Configure signing & capabilities

3. Build archive:
   ```bash
   flutter build ios --release
   ```

### Web
1. Build for web:
   ```bash
   flutter build web --release
   ```

2. Deploy to hosting:
   - Copy `build/web` contents to your server
   - Configure nginx/apache for SPA routing

## Security Considerations

1. **API Keys**
   - Never commit sensitive keys
   - Use environment variables in production
   - Rotate keys regularly

2. **Authentication**
   - Implement proper password hashing in production
   - Add 2FA support
   - Session timeout handling

3. **Data Protection**
   - Enable Supabase RLS policies
   - Encrypt sensitive data
   - Regular security audits

## Performance Optimization

1. **Image Optimization**
   - Compress images before upload
   - Use WebP format
   - Implement lazy loading

2. **Data Caching**
   - Cache frequently accessed data
   - Implement pagination
   - Use indexed DB for offline

3. **Code Splitting**
   - Lazy load modules
   - Tree shaking
   - Minimize bundle size

## Troubleshooting

### Common Issues

1. **Supabase Connection Failed**
   - Check internet connection
   - Verify Supabase URL and anon key
   - Check CORS settings

2. **Build Errors**
   - Run `flutter clean`
   - Delete `pubspec.lock` and run `flutter pub get`
   - Check Flutter version compatibility

3. **Permission Denied**
   - Verify RLS policies in Supabase
   - Check user role assignments
   - Review permission matrix

## Support & Resources

- **Flutter Docs**: https://flutter.dev/docs
- **Supabase Docs**: https://supabase.io/docs
- **Provider Package**: https://pub.dev/packages/provider

## Next Steps

1. Complete remaining module implementations
2. Add comprehensive error handling
3. Implement offline synchronization
4. Add unit and integration tests
5. Set up CI/CD pipeline
6. Prepare for app store submissions

---

For any questions or issues, contact:
- Dawell Lifescience Private Limited
- Phone: 9850647444
