/// Helper utilities for JSON parsing

/// Converts various types to boolean
bool parseBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is String) {
    final lowered = value.toLowerCase();
    return lowered == 'true' ||
        lowered == 't' ||
        lowered == 'yes' ||
        lowered == 'y' ||
        value == '1';
  }
  if (value is num) return value != 0;
  return false;
}

/// Converts various types to boolean with custom default
bool parseBoolWithDefault(dynamic value, bool defaultValue) {
  if (value == null) return defaultValue;
  if (value is bool) return value;
  if (value is String) {
    final lowered = value.toLowerCase();
    return lowered == 'true' ||
        lowered == 't' ||
        lowered == 'yes' ||
        lowered == 'y' ||
        value == '1';
  }
  if (value is num) return value != 0;
  return defaultValue;
}

/// Safely parses integer from various types
int parseInt(dynamic value, {int defaultValue = 0}) {
  if (value == null) return defaultValue;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) {
    final parsed = int.tryParse(value);
    return parsed ?? defaultValue;
  }
  return defaultValue;
}

/// Safely parses double from various types
double parseDouble(dynamic value, {double defaultValue = 0.0}) {
  if (value == null) return defaultValue;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    final parsed = double.tryParse(value);
    return parsed ?? defaultValue;
  }
  return defaultValue;
}

/// Safely parses DateTime
DateTime? parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) {
    try {
      return DateTime.parse(value);
    } catch (e) {
      return null;
    }
  }
  return null;
}
