import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../config/supabase_config.dart';

class SupabaseManager {
  static SupabaseClient? _client;
  static bool _initialized = false;

  // Initialize Supabase with your existing configuration
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
        debug: kDebugMode,
      );

      _client = Supabase.instance.client;
      _initialized = true;

      // Setup auth state listener
      _setupAuthListener();

      if (kDebugMode) {
        print('✅ Supabase initialized successfully');
        print('URL: ${SupabaseConfig.url}');
      }
    } catch (e) {
      print('❌ Error initializing Supabase: $e');
      rethrow;
    }
  }

  // Get Supabase client instance
  static SupabaseClient get client {
    if (_client == null) {
      throw Exception(
          'Supabase not initialized. Call SupabaseManager.initialize() first.');
    }
    return _client!;
  }

  // Setup auth state listener
  static void _setupAuthListener() {
    client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (kDebugMode) {
        print('Auth state changed: $event');
      }

      switch (event) {
        case AuthChangeEvent.signedIn:
          _onUserSignedIn(session);
          break;
        case AuthChangeEvent.signedOut:
          _onUserSignedOut();
          break;
        case AuthChangeEvent.userUpdated:
          _onUserUpdated(session);
          break;
        case AuthChangeEvent.tokenRefreshed:
          _onTokenRefreshed(session);
          break;
        default:
          break;
      }
    });
  }

  static void _onUserSignedIn(Session? session) {
    if (session != null) {
      print('User signed in: ${session.user.email}');
      // You can trigger additional actions here like loading user profile
    }
  }

  static void _onUserSignedOut() {
    print('User signed out');
    // Clear any cached data or perform cleanup
  }

  static void _onUserUpdated(Session? session) {
    if (session != null) {
      print('User updated: ${session.user.email}');
    }
  }

  static void _onTokenRefreshed(Session? session) {
    if (session != null) {
      print('Token refreshed');
    }
  }

  // Get current user
  static User? get currentUser => client.auth.currentUser;

  // Get current session
  static Session? get currentSession => client.auth.currentSession;

  // Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  // Storage Buckets Configuration
  static const Map<String, String> storageBuckets = {
    'inspections': 'inspection-images',
    'seizures': 'seizure-images',
    'lab_reports': 'lab-reports',
    'fir_documents': 'fir-documents',
    'profiles': 'profile-images',
    'forms': 'form-attachments',
  };

  // Table Names Configuration
  static const Map<String, String> tables = {
    'users': 'users',
    'inspections': 'field_executions',
    'seizures': 'seizures',
    'lab_samples': 'lab_samples',
    'fir_cases': 'fir_cases',
    'form_submissions': 'form_submissions',
    'products': 'products',
    'notifications': 'notifications',
    'districts': 'districts',
    'agri_forms': 'agri_forms',
    'search_history': 'search_history',
    'popular_searches': 'popular_searches',
  };

  // Realtime Channels
  static const Map<String, String> channels = {
    'dashboard': 'dashboard-updates',
    'notifications': 'user-notifications',
    'presence': 'user-presence',
    'inspections': 'inspection-updates',
    'seizures': 'seizure-updates',
    'lab_samples': 'lab-updates',
  };
}

// Authentication Service
class SupabaseAuthService {
  static final SupabaseClient _client = SupabaseManager.client;

  // Sign in with email and password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw Exception(_handleAuthError(e));
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  // Sign up new user
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String? role,
    String? department,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone': phone,
          'role': role,
          'department': department,
        },
      );
      return response;
    } on AuthException catch (e) {
      throw Exception(_handleAuthError(e));
    } catch (e) {
      throw Exception('Sign up failed: ${e.toString()}');
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  // Reset password
  static Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'com.agrivigil.app://reset-password',
      );
    } on AuthException catch (e) {
      throw Exception(_handleAuthError(e));
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  // Update user password
  static Future<UserResponse> updatePassword(String newPassword) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return response;
    } on AuthException catch (e) {
      throw Exception(_handleAuthError(e));
    } catch (e) {
      throw Exception('Password update failed: ${e.toString()}');
    }
  }

  // Update user profile
  static Future<UserResponse> updateProfile({
    String? fullName,
    String? phone,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (phone != null) updates['phone'] = phone;
      if (metadata != null) updates.addAll(metadata);

      final response = await _client.auth.updateUser(
        UserAttributes(data: updates),
      );
      return response;
    } on AuthException catch (e) {
      throw Exception(_handleAuthError(e));
    } catch (e) {
      throw Exception('Profile update failed: ${e.toString()}');
    }
  }

  // Handle auth errors
  static String _handleAuthError(AuthException error) {
    switch (error.statusCode) {
      case '400':
        if (error.message.contains('email')) {
          return 'Invalid email address';
        } else if (error.message.contains('password')) {
          return 'Password should be at least 6 characters';
        }
        return 'Invalid credentials';
      case '401':
        return 'Invalid email or password';
      case '422':
        return 'Email already registered';
      case '429':
        return 'Too many attempts. Please try again later';
      default:
        return error.message;
    }
  }
}

// Database Service
class SupabaseDataService {
  static final SupabaseClient _client = SupabaseManager.client;

  // Generic fetch method
  static Future<List<Map<String, dynamic>>> fetch({
    required String table,
    String select = '*',
    Map<String, dynamic>? filters,
    String? orderBy,
    bool ascending = true,
    int? limit,
    int? offset,
  }) async {
    try {
      dynamic query = _client.from(table).select(select);

      // Apply filters
      if (filters != null) {
        filters.forEach((key, value) {
          if (value != null) {
            if (value is List) {
              query = query.inFilter(key, value);
            } else {
              query = query.eq(key, value);
            }
          }
        });
      }

      // Apply ordering
      if (orderBy != null) {
        query = query.order(orderBy, ascending: ascending);
      }

      // Apply pagination
      if (limit != null) {
        query = query.limit(limit);
      }
      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 10) - 1);
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      throw Exception('Fetch failed: ${e.message}');
    } catch (e) {
      throw Exception('Fetch failed: ${e.toString()}');
    }
  }

  // Insert single record
  static Future<Map<String, dynamic>> insert({
    required String table,
    required Map<String, dynamic> data,
    String select = '*',
  }) async {
    try {
      // Add metadata
      data['created_at'] = DateTime.now().toIso8601String();
      data['created_by'] = SupabaseManager.currentUser?.id;

      final response =
          await _client.from(table).insert(data).select(select).single();

      return response;
    } on PostgrestException catch (e) {
      throw Exception('Insert failed: ${e.message}');
    } catch (e) {
      throw Exception('Insert failed: ${e.toString()}');
    }
  }

  // Insert multiple records
  static Future<List<Map<String, dynamic>>> insertMany({
    required String table,
    required List<Map<String, dynamic>> data,
    String select = '*',
  }) async {
    try {
      // Add metadata to all records
      final userId = SupabaseManager.currentUser?.id;
      final timestamp = DateTime.now().toIso8601String();

      for (var record in data) {
        record['created_at'] = timestamp;
        record['created_by'] = userId;
      }

      final response = await _client.from(table).insert(data).select(select);

      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      throw Exception('Bulk insert failed: ${e.message}');
    } catch (e) {
      throw Exception('Bulk insert failed: ${e.toString()}');
    }
  }

  // Update record
  static Future<Map<String, dynamic>> update({
    required String table,
    required Map<String, dynamic> data,
    required Map<String, dynamic> match,
    String select = '*',
  }) async {
    try {
      // Add metadata
      data['updated_at'] = DateTime.now().toIso8601String();
      data['updated_by'] = SupabaseManager.currentUser?.id;

      var query = _client.from(table).update(data);

      // Apply match conditions
      match.forEach((key, value) {
        query = query.eq(key, value);
      });

      final response = await query.select(select).single();
      return response;
    } on PostgrestException catch (e) {
      throw Exception('Update failed: ${e.message}');
    } catch (e) {
      throw Exception('Update failed: ${e.toString()}');
    }
  }

  // Delete record
  static Future<void> delete({
    required String table,
    required Map<String, dynamic> match,
  }) async {
    try {
      var query = _client.from(table).delete();

      // Apply match conditions
      match.forEach((key, value) {
        query = query.eq(key, value);
      });

      await query;
    } on PostgrestException catch (e) {
      throw Exception('Delete failed: ${e.message}');
    } catch (e) {
      throw Exception('Delete failed: ${e.toString()}');
    }
  }

  // Call RPC function
  static Future<dynamic> rpc({
    required String functionName,
    Map<String, dynamic>? params,
  }) async {
    try {
      final response = await _client.rpc(
        functionName,
        params: params ?? {},
      );
      return response;
    } on PostgrestException catch (e) {
      throw Exception('RPC call failed: ${e.message}');
    } catch (e) {
      throw Exception('RPC call failed: ${e.toString()}');
    }
  }
}

// Storage Service
class SupabaseStorageService {
  static final SupabaseClient _client = SupabaseManager.client;

  // Upload file
  static Future<String> uploadFile({
    required String bucket,
    required String path,
    required dynamic file,
    FileOptions? fileOptions,
  }) async {
    try {
      final String filePath = await _client.storage.from(bucket).upload(
            path,
            file,
            fileOptions: fileOptions ?? const FileOptions(),
          );

      return filePath;
    } on StorageException catch (e) {
      throw Exception('Upload failed: ${e.message}');
    } catch (e) {
      throw Exception('Upload failed: ${e.toString()}');
    }
  }

  // Update/Replace file
  static Future<String> updateFile({
    required String bucket,
    required String path,
    required dynamic file,
    FileOptions? fileOptions,
  }) async {
    try {
      final String filePath = await _client.storage.from(bucket).update(
            path,
            file,
            fileOptions: fileOptions ?? const FileOptions(),
          );

      return filePath;
    } on StorageException catch (e) {
      throw Exception('Update failed: ${e.message}');
    } catch (e) {
      throw Exception('Update failed: ${e.toString()}');
    }
  }

  // Download file
  static Future<Uint8List> downloadFile({
    required String bucket,
    required String path,
  }) async {
    try {
      final Uint8List file = await _client.storage.from(bucket).download(path);

      return file;
    } on StorageException catch (e) {
      throw Exception('Download failed: ${e.message}');
    } catch (e) {
      throw Exception('Download failed: ${e.toString()}');
    }
  }

  // Get public URL
  static String getPublicUrl({
    required String bucket,
    required String path,
  }) {
    return _client.storage.from(bucket).getPublicUrl(path);
  }

  // Delete file(s)
  static Future<void> deleteFiles({
    required String bucket,
    required List<String> paths,
  }) async {
    try {
      await _client.storage.from(bucket).remove(paths);
    } on StorageException catch (e) {
      throw Exception('Delete failed: ${e.message}');
    } catch (e) {
      throw Exception('Delete failed: ${e.toString()}');
    }
  }

  // List files
  static Future<List<FileObject>> listFiles({
    required String bucket,
    String? path,
    SearchOptions? searchOptions,
  }) async {
    try {
      final List<FileObject> files = await _client.storage.from(bucket).list(
            path: path,
            searchOptions: searchOptions ?? const SearchOptions(),
          );

      return files;
    } on StorageException catch (e) {
      throw Exception('List failed: ${e.message}');
    } catch (e) {
      throw Exception('List failed: ${e.toString()}');
    }
  }

  // Create signed URL
  static Future<String> createSignedUrl({
    required String bucket,
    required String path,
    required int expiresIn,
  }) async {
    try {
      final String signedUrl =
          await _client.storage.from(bucket).createSignedUrl(path, expiresIn);

      return signedUrl;
    } on StorageException catch (e) {
      throw Exception('Signed URL creation failed: ${e.message}');
    } catch (e) {
      throw Exception('Signed URL creation failed: ${e.toString()}');
    }
  }
}
