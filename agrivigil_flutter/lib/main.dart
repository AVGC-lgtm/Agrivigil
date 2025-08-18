import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'config/supabase_config.dart';
import 'providers/auth_provider.dart';
import 'providers/permission_provider.dart';
import 'providers/enhanced_permission_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'utils/theme.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, PermissionProvider>(
          create: (_) => PermissionProvider(),
          update: (_, authProvider, permissionProvider) =>
              permissionProvider!..updateAuth(authProvider),
        ),
        ChangeNotifierProxyProvider<AuthProvider, EnhancedPermissionProvider>(
          create: (_) => EnhancedPermissionProvider(),
          update: (_, authProvider, enhancedPermissionProvider) =>
              enhancedPermissionProvider!..updateAuth(authProvider),
        ),
      ],
      child: MaterialApp(
        title: 'AGRIVIGIL',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.getRoutes(),
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          return const SplashScreen();
        }
        
        if (authProvider.user != null) {
          return const DashboardScreen();
        }
        
        return const LoginScreen();
      },
    );
  }
}
