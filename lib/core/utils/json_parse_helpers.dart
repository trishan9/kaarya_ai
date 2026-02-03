library;

String jsonString(dynamic value, {String fallback = ''}) {
  if (value is String && value.trim().isNotEmpty) return value;
  return fallback;
}

String? jsonNullableString(dynamic value) {
  if (value is String && value.trim().isNotEmpty) return value;
  return null;
}

int jsonInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

double jsonDouble(dynamic value, {double fallback = 0}) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

double? jsonDoubleOrNull(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

bool jsonBool(dynamic value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is String) return value.toLowerCase() == 'true';
  return fallback;
}

List<String> jsonStringList(dynamic value) {
  if (value is! List) return const <String>[];
  return value
      .map((item) => item is String ? item.trim() : '')
      .where((item) => item.isNotEmpty)
      .toList();
}

/// Parses techStack from API - supports both formats:
/// - ["React", "TypeScript"] (strings)
/// - [{"name": "React", "iconUrl": "https://..."}] (objects with iconUrl from backend)
/// Returns (techNames, iconUrls). When backend provides iconUrl, iconUrls is populated.
(List<String> techNames, List<String> iconUrls) jsonTechStack(dynamic value) {
  if (value is! List) return (const <String>[], const <String>[]);
  final names = <String>[];
  final urls = <String>[];
  for (final item in value) {
    if (item is String && item.trim().isNotEmpty) {
      names.add(item.trim());
    } else if (item is Map) {
      final map = jsonCastMap(item);
      final name = jsonNullableString(map['name']) ?? jsonString(map['name']);
      final iconUrl = jsonNullableString(map['iconUrl']) ??
          jsonNullableString(map['icon_url']);
      if (name.isNotEmpty) names.add(name);
      if (iconUrl != null && iconUrl.isNotEmpty) urls.add(iconUrl);
    }
  }
  return (names, urls);
}

Map<String, dynamic>? jsonAsMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return jsonCastMap(value);
  return null;
}

List<Map<String, dynamic>> jsonAsList(dynamic value) {
  if (value is! List) return const <Map<String, dynamic>>[];
  return value.whereType<Map>().map(jsonCastMap).toList();
}

Map<String, dynamic> jsonCastMap(Map value) {
  return value.map((key, item) => MapEntry(key.toString(), item));
}
