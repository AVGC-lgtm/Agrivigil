import 'package:supabase_flutter/supabase_flutter.dart';

class SearchService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Search across all modules
  Future<Map<String, List<Map<String, dynamic>>>> globalSearch({
    required String query,
    List<String>? modules,
    Map<String, dynamic>? filters,
    int limit = 10,
  }) async {
    if (query.isEmpty) return {};

    final results = <String, List<Map<String, dynamic>>>{};
    final searchModules = modules ??
        [
          'inspections',
          'seizures',
          'lab_samples',
          'fir_cases',
          'form_submissions',
          'users',
          'products',
        ];

    // Search in parallel
    final futures = <Future>[];

    for (final module in searchModules) {
      futures.add(_searchModule(module, query, filters, limit));
    }

    final searchResults = await Future.wait(futures);

    // Combine results
    for (int i = 0; i < searchModules.length; i++) {
      if (searchResults[i] != null && (searchResults[i] as List).isNotEmpty) {
        results[searchModules[i]] =
            List<Map<String, dynamic>>.from(searchResults[i]);
      }
    }

    return results;
  }

  // Search specific module
  Future<List<Map<String, dynamic>>> _searchModule(
    String module,
    String query,
    Map<String, dynamic>? filters,
    int limit,
  ) async {
    try {
      switch (module) {
        case 'inspections':
          return await _searchInspections(query, filters, limit);
        case 'seizures':
          return await _searchSeizures(query, filters, limit);
        case 'lab_samples':
          return await _searchLabSamples(query, filters, limit);
        case 'fir_cases':
          return await _searchFIRCases(query, filters, limit);
        case 'form_submissions':
          return await _searchFormSubmissions(query, filters, limit);
        case 'users':
          return await _searchUsers(query, filters, limit);
        case 'products':
          return await _searchProducts(query, filters, limit);
        default:
          return [];
      }
    } catch (e) {
      print('Error searching $module: $e');
      return [];
    }
  }

  // Search inspections
  Future<List<Map<String, dynamic>>> _searchInspections(
    String query,
    Map<String, dynamic>? filters,
    int limit,
  ) async {
    var request = _supabase
        .from('field_executions')
        .select('*, users!created_by(full_name), products(*)')
        .or('inspection_code.ilike.%$query%,location.ilike.%$query%,dealer_name.ilike.%$query%');

    // Apply filters
    if (filters != null) {
      if (filters['status'] != null) {
        request = request.eq('status', filters['status']);
      }
      if (filters['district_id'] != null) {
        request = request.eq('district_id', filters['district_id']);
      }
      if (filters['date_from'] != null) {
        request = request.gte('execution_date', filters['date_from']);
      }
      if (filters['date_to'] != null) {
        request = request.lte('execution_date', filters['date_to']);
      }
    }

    final response = await request.limit(limit);
    return List<Map<String, dynamic>>.from(response).map((item) {
      item['_type'] = 'inspection';
      item['_title'] = item['inspection_code'] ?? 'Inspection';
      item['_subtitle'] = '${item['location']} - ${item['dealer_name']}';
      return item;
    }).toList();
  }

  // Search seizures
  Future<List<Map<String, dynamic>>> _searchSeizures(
    String query,
    Map<String, dynamic>? filters,
    int limit,
  ) async {
    var request = _supabase
        .from('seizures')
        .select('*, field_executions(*), users!created_by(full_name)')
        .or('seizure_code.ilike.%$query%,location.ilike.%$query%,dealer_name.ilike.%$query%,reason.ilike.%$query%');

    // Apply filters
    if (filters != null) {
      if (filters['status'] != null) {
        request = request.eq('status', filters['status']);
      }
      if (filters['date_from'] != null) {
        request = request.gte('seizure_date', filters['date_from']);
      }
      if (filters['date_to'] != null) {
        request = request.lte('seizure_date', filters['date_to']);
      }
    }

    final response = await request.limit(limit);
    return List<Map<String, dynamic>>.from(response).map((item) {
      item['_type'] = 'seizure';
      item['_title'] = item['seizure_code'] ?? 'Seizure';
      item['_subtitle'] = '${item['location']} - ${item['reason']}';
      return item;
    }).toList();
  }

  // Search lab samples
  Future<List<Map<String, dynamic>>> _searchLabSamples(
    String query,
    Map<String, dynamic>? filters,
    int limit,
  ) async {
    var request = _supabase
        .from('lab_samples')
        .select('*, seizures(*), users!assigned_to(full_name)')
        .or('sample_code.ilike.%$query%,sample_type.ilike.%$query%');

    // Apply filters
    if (filters != null) {
      if (filters['status'] != null) {
        request = request.eq('status', filters['status']);
      }
      if (filters['lab_id'] != null) {
        request = request.eq('lab_id', filters['lab_id']);
      }
    }

    final response = await request.limit(limit);
    return List<Map<String, dynamic>>.from(response).map((item) {
      item['_type'] = 'lab_sample';
      item['_title'] = item['sample_code'] ?? 'Lab Sample';
      item['_subtitle'] = '${item['sample_type']} - ${item['status']}';
      return item;
    }).toList();
  }

  // Search FIR cases
  Future<List<Map<String, dynamic>>> _searchFIRCases(
    String query,
    Map<String, dynamic>? filters,
    int limit,
  ) async {
    var request = _supabase
        .from('fir_cases')
        .select('*, seizures(*), users!filed_by(full_name)')
        .or('fir_number.ilike.%$query%,case_title.ilike.%$query%,accused_name.ilike.%$query%,police_station.ilike.%$query%');

    // Apply filters
    if (filters != null) {
      if (filters['status'] != null) {
        request = request.eq('status', filters['status']);
      }
      if (filters['case_type'] != null) {
        request = request.eq('case_type', filters['case_type']);
      }
      if (filters['date_from'] != null) {
        request = request.gte('filed_date', filters['date_from']);
      }
      if (filters['date_to'] != null) {
        request = request.lte('filed_date', filters['date_to']);
      }
    }

    final response = await request.limit(limit);
    return List<Map<String, dynamic>>.from(response).map((item) {
      item['_type'] = 'fir_case';
      item['_title'] = item['fir_number'] ?? 'FIR Case';
      item['_subtitle'] = '${item['case_title']} - ${item['accused_name']}';
      return item;
    }).toList();
  }

  // Search form submissions
  Future<List<Map<String, dynamic>>> _searchFormSubmissions(
    String query,
    Map<String, dynamic>? filters,
    int limit,
  ) async {
    var request = _supabase
        .from('form_submissions')
        .select('*, agri_forms(*), users!submitted_by(full_name)')
        .or('farmer_name.ilike.%$query%,farmer_contact.ilike.%$query%,submission_code.ilike.%$query%');

    // Apply filters
    if (filters != null) {
      if (filters['status'] != null) {
        request = request.eq('status', filters['status']);
      }
      if (filters['form_id'] != null) {
        request = request.eq('form_id', filters['form_id']);
      }
    }

    final response = await request.limit(limit);
    return List<Map<String, dynamic>>.from(response).map((item) {
      item['_type'] = 'form_submission';
      item['_title'] = item['submission_code'] ?? 'Form Submission';
      item['_subtitle'] = '${item['farmer_name']} - ${item['farmer_contact']}';
      return item;
    }).toList();
  }

  // Search users
  Future<List<Map<String, dynamic>>> _searchUsers(
    String query,
    Map<String, dynamic>? filters,
    int limit,
  ) async {
    var request = _supabase.from('users').select('*').or(
        'full_name.ilike.%$query%,email.ilike.%$query%,phone.ilike.%$query%,employee_id.ilike.%$query%');

    // Apply filters
    if (filters != null) {
      if (filters['role'] != null) {
        request = request.eq('role', filters['role']);
      }
      if (filters['department'] != null) {
        request = request.eq('department', filters['department']);
      }
      if (filters['is_active'] != null) {
        request = request.eq('is_active', filters['is_active']);
      }
    }

    final response = await request.limit(limit);
    return List<Map<String, dynamic>>.from(response).map((item) {
      item['_type'] = 'user';
      item['_title'] = item['full_name'] ?? 'User';
      item['_subtitle'] = '${item['email']} - ${item['role']}';
      return item;
    }).toList();
  }

  // Search products
  Future<List<Map<String, dynamic>>> _searchProducts(
    String query,
    Map<String, dynamic>? filters,
    int limit,
  ) async {
    var request = _supabase.from('products').select('*').or(
        'name.ilike.%$query%,brand.ilike.%$query%,category.ilike.%$query%,manufacturer.ilike.%$query%');

    // Apply filters
    if (filters != null) {
      if (filters['category'] != null) {
        request = request.eq('category', filters['category']);
      }
      if (filters['is_active'] != null) {
        request = request.eq('is_active', filters['is_active']);
      }
    }

    final response = await request.limit(limit);
    return List<Map<String, dynamic>>.from(response).map((item) {
      item['_type'] = 'product';
      item['_title'] = item['name'] ?? 'Product';
      item['_subtitle'] = '${item['brand']} - ${item['category']}';
      return item;
    }).toList();
  }

  // Get search suggestions
  Future<List<String>> getSearchSuggestions(String query) async {
    if (query.length < 2) return [];

    try {
      // Get recent searches for the user
      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        final recentSearches = await _supabase
            .from('search_history')
            .select('query')
            .eq('user_id', userId)
            .ilike('query', '$query%')
            .order('searched_at', ascending: false)
            .limit(5);

        final suggestions = (recentSearches as List)
            .map((item) => item['query'] as String)
            .toList();

        // Add popular searches
        final popularSearches = await _supabase
            .from('popular_searches')
            .select('query')
            .ilike('query', '$query%')
            .order('count', ascending: false)
            .limit(5);

        suggestions.addAll(
            (popularSearches as List).map((item) => item['query'] as String));

        // Remove duplicates and return
        return suggestions.toSet().toList();
      }

      return [];
    } catch (e) {
      print('Error getting search suggestions: $e');
      return [];
    }
  }

  // Save search history
  Future<void> saveSearchHistory(String query) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        await _supabase.from('search_history').insert({
          'user_id': userId,
          'query': query,
          'searched_at': DateTime.now().toIso8601String(),
        });

        // Update popular searches count
        await _supabase
            .rpc('increment_search_count', params: {'search_query': query});
      }
    } catch (e) {
      print('Error saving search history: $e');
    }
  }

  // Clear search history
  Future<void> clearSearchHistory() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        await _supabase.from('search_history').delete().eq('user_id', userId);
      }
    } catch (e) {
      print('Error clearing search history: $e');
    }
  }

  // Get recent searches
  Future<List<String>> getRecentSearches({int limit = 10}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        final searches = await _supabase
            .from('search_history')
            .select('query')
            .eq('user_id', userId)
            .order('searched_at', ascending: false)
            .limit(limit);

        return (searches as List)
            .map((item) => item['query'] as String)
            .toList();
      }
      return [];
    } catch (e) {
      print('Error getting recent searches: $e');
      return [];
    }
  }
}
