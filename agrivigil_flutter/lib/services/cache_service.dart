import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const String _userCacheKey = 'user_cache';
  static const String _settingsBoxName = 'settings';
  static const String _cacheBoxName = 'app_cache';

  static Box? _settingsBox;
  static Box? _cacheBox;

  // Initialize cache service
  static Future<void> initialize() async {
    try {
      // Initialize Hive
      await Hive.initFlutter();

      // Open boxes
      _settingsBox = await Hive.openBox(_settingsBoxName);
      _cacheBox = await Hive.openBox(_cacheBoxName);
    } catch (e) {
      print('Error initializing cache service: $e');
      // Fallback to SharedPreferences if Hive fails
    }
  }

  // User cache methods
  static Future<void> saveUserProfile(Map<String, dynamic> userProfile) async {
    try {
      if (_cacheBox != null) {
        await _cacheBox!.put(_userCacheKey, userProfile);
      } else {
        // Fallback to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userCacheKey, jsonEncode(userProfile));
      }
    } catch (e) {
      print('Error saving user profile: $e');
    }
  }

  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      if (_cacheBox != null) {
        final data = _cacheBox!.get(_userCacheKey);
        return data != null ? Map<String, dynamic>.from(data) : null;
      } else {
        // Fallback to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final jsonString = prefs.getString(_userCacheKey);
        return jsonString != null ? jsonDecode(jsonString) : null;
      }
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  static Future<void> clearUserCache() async {
    try {
      if (_cacheBox != null) {
        await _cacheBox!.delete(_userCacheKey);
      } else {
        // Fallback to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_userCacheKey);
      }
    } catch (e) {
      print('Error clearing user cache: $e');
    }
  }

  // Settings methods
  static Future<void> savePreference(String key, dynamic value) async {
    try {
      if (_settingsBox != null) {
        await _settingsBox!.put(key, value);
      } else {
        // Fallback to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        if (value is String) {
          await prefs.setString(key, value);
        } else if (value is int) {
          await prefs.setInt(key, value);
        } else if (value is double) {
          await prefs.setDouble(key, value);
        } else if (value is bool) {
          await prefs.setBool(key, value);
        } else if (value is List<String>) {
          await prefs.setStringList(key, value);
        } else {
          await prefs.setString(key, jsonEncode(value));
        }
      }
    } catch (e) {
      print('Error saving preference: $e');
    }
  }

  static Future<T?> getPreference<T>(String key, {T? defaultValue}) async {
    try {
      if (_settingsBox != null) {
        return _settingsBox!.get(key, defaultValue: defaultValue) as T?;
      } else {
        // Fallback to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        if (T == String) {
          return (prefs.getString(key) ?? defaultValue) as T?;
        } else if (T == int) {
          return (prefs.getInt(key) ?? defaultValue) as T?;
        } else if (T == double) {
          return (prefs.getDouble(key) ?? defaultValue) as T?;
        } else if (T == bool) {
          return (prefs.getBool(key) ?? defaultValue) as T?;
        } else if (T == List<String>) {
          return (prefs.getStringList(key) ?? defaultValue) as T?;
        } else {
          final jsonString = prefs.getString(key);
          if (jsonString != null) {
            return jsonDecode(jsonString) as T?;
          }
          return defaultValue;
        }
      }
    } catch (e) {
      print('Error getting preference: $e');
      return defaultValue;
    }
  }

  // General cache methods
  static Future<void> cacheData(String key, dynamic data,
      {Duration? expiry}) async {
    try {
      final cacheEntry = {
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'expiry': expiry?.inMilliseconds,
      };

      if (_cacheBox != null) {
        await _cacheBox!.put(key, cacheEntry);
      } else {
        // Fallback to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(key, jsonEncode(cacheEntry));
      }
    } catch (e) {
      print('Error caching data: $e');
    }
  }

  static Future<T?> getCachedData<T>(String key) async {
    try {
      Map<String, dynamic>? cacheEntry;

      if (_cacheBox != null) {
        final data = _cacheBox!.get(key);
        if (data != null) {
          cacheEntry = Map<String, dynamic>.from(data);
        }
      } else {
        // Fallback to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final jsonString = prefs.getString(key);
        if (jsonString != null) {
          cacheEntry = jsonDecode(jsonString);
        }
      }

      if (cacheEntry == null) return null;

      // Check if cache has expired
      final timestamp = cacheEntry['timestamp'] as int;
      final expiry = cacheEntry['expiry'] as int?;

      if (expiry != null) {
        final age = DateTime.now().millisecondsSinceEpoch - timestamp;
        if (age > expiry) {
          await removeCachedData(key);
          return null;
        }
      }

      return cacheEntry['data'] as T?;
    } catch (e) {
      print('Error getting cached data: $e');
      return null;
    }
  }

  static Future<void> removeCachedData(String key) async {
    try {
      if (_cacheBox != null) {
        await _cacheBox!.delete(key);
      } else {
        // Fallback to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(key);
      }
    } catch (e) {
      print('Error removing cached data: $e');
    }
  }

  static Future<void> clearAllCache() async {
    try {
      if (_cacheBox != null) {
        await _cacheBox!.clear();
      } else {
        // Fallback to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final keys = prefs.getKeys();
        for (final key in keys) {
          if (!key.startsWith('flutter.')) {
            await prefs.remove(key);
          }
        }
      }
    } catch (e) {
      print('Error clearing all cache: $e');
    }
  }

  // Close boxes when app terminates
  static Future<void> close() async {
    try {
      await _settingsBox?.close();
      await _cacheBox?.close();
    } catch (e) {
      print('Error closing cache boxes: $e');
    }
  }
}
