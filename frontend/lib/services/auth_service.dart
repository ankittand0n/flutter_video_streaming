import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Login with email/phone and password
  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
    required bool isEmail,
  }) async {
    try {
      final url = Uri.parse('${AppConfig.apiBaseUrl}/auth/login');

      final body = {
        isEmail ? 'email' : 'username': identifier,
        'password': password,
      };

      final response = await http
          .post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      )
          .timeout(
        const Duration(seconds: AppConfig.apiTimeout),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        // Save token and user data
        await _saveAuthData(data['token'], data['user']);
        return {
          'success': true,
          'message': data['message'] ?? 'Login successful',
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Register new user
  Future<Map<String, dynamic>> register({
    required String name,
    required String identifier,
    required String password,
    required bool isEmail,
  }) async {
    try {
      final url = Uri.parse('${AppConfig.apiBaseUrl}/auth/register');

      // Generate username from UUID: remove dashes and take first 12 chars
      // name parameter is actually a UUID (e.g., "550e8400-e29b-41d4-a716-446655440000")
      String username = name.replaceAll('-', '').substring(0, 12);

      final body = {
        'username': username,
        'email': isEmail
            ? identifier
            : '$identifier@phone.temp', // Temporary email for phone users
        'password': password,
        'profilename': name, // Use full UUID as profile name
      };

      print('Registration request body: ${json.encode(body)}');

      final response = await http
          .post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      )
          .timeout(
        const Duration(seconds: AppConfig.apiTimeout),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        // Save token and user data
        await _saveAuthData(data['token'], data['user']);
        return {
          'success': true,
          'message': data['message'] ?? 'Registration successful',
          'user': data['user'],
        };
      } else {
        // Format validation error details if present
        String errorMessage = data['error'] ?? 'Registration failed';
        if (data['details'] != null && data['details'] is List) {
          final details = (data['details'] as List)
              .map((d) => '${d['field']}: ${d['message']}')
              .join('\n');
          errorMessage = '$errorMessage\n$details';
        }
        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      print('Registration error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Save authentication data
  Future<void> _saveAuthData(String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, json.encode(user));
  }

  // Get saved token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Get saved user data
  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      return json.decode(userData);
    }
    return null;
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  // Get current user profile from API
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Not authenticated',
        };
      }

      final url = Uri.parse('${AppConfig.apiBaseUrl}/auth/me');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: AppConfig.apiTimeout),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        // Update saved user data
        await _saveAuthData(token, data['user']);
        return {
          'success': true,
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to get user profile',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Make authenticated API request
  Future<http.Response> authenticatedRequest({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
  }) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final url = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    switch (method.toUpperCase()) {
      case 'GET':
        return await http.get(url, headers: headers);
      case 'POST':
        return await http.post(url, headers: headers, body: json.encode(body));
      case 'PUT':
        return await http.put(url, headers: headers, body: json.encode(body));
      case 'DELETE':
        return await http.delete(url, headers: headers);
      default:
        throw Exception('Unsupported HTTP method: $method');
    }
  }
}
