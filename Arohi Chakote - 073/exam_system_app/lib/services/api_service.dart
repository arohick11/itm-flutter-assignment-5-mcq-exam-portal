import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Auto-discover backend URL
  static const List<String> _baseUrls = [
    'http://localhost:3000/api',
    'http://127.0.0.1:3000/api',
    'http://10.0.2.2:3000/api', // Android emulator
  ];

  static String _activeBaseUrl = 'http://localhost:3000/api';

  static Future<void> discoverServer() async {
    for (final url in _baseUrls) {
      try {
        final response = await http
            .get(Uri.parse(url.replaceAll('/api', '')))
            .timeout(const Duration(seconds: 2));
        if (response.statusCode == 200) {
          _activeBaseUrl = url;
          return;
        }
      } catch (_) {}
    }
  }

  static String get baseUrl => _activeBaseUrl;

  // Generic GET
  static Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$_activeBaseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
    );
    return jsonDecode(response.body);
  }

  // Generic POST
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final response = await http.post(
      Uri.parse('$_activeBaseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return jsonDecode(response.body);
  }

  // Generic PUT
  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final response = await http.put(
      Uri.parse('$_activeBaseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return jsonDecode(response.body);
  }

  // Generic DELETE
  static Future<Map<String, dynamic>> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$_activeBaseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
    );
    return jsonDecode(response.body);
  }
}
