import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://myfertipal-backend.onrender.com';

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() {
    _initializeToken();
  }

  String? _accessToken;
  bool _tokenInitialized = false;

  // Initialize token from storage on startup
  Future<void> _initializeToken() async {
    if (_tokenInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString('access_token');
      _tokenInitialized = true;
      debugPrint(
          'Token initialized: ${_accessToken != null ? 'Token loaded' : 'No token found'}');
    } catch (e) {
      debugPrint('Error initializing token: $e');
      _tokenInitialized = true;
    }
  }

  // Set access token after login
  void setAccessToken(String token) {
    _accessToken = token;
  }

  // Get stored token
  Future<String?> getStoredToken() async {
    if (_accessToken != null) return _accessToken;
    try {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString('access_token');
      return _accessToken;
    } catch (e) {
      debugPrint('Error getting stored token: $e');
      return null;
    }
  }
Future<Map<String,dynamic>> get(String endpoint) async {

final headers = await getHeaders(
 includeAuth:true
);


final response = await http.get(
 Uri.parse('$baseUrl$endpoint'),
 headers: headers,
);


if(response.statusCode == 200){

return jsonDecode(response.body);

}


throw Exception(
"Failed loading data"
);

}
  // Save token to storage
  Future<void> saveToken(String token) async {
    _accessToken = token;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', token);
      debugPrint('Token saved successfully');
    } catch (e) {
      debugPrint('Error saving token: $e');
    }
  }
  Future<dynamic> post(
  String endpoint,
  Map<String, dynamic> body,
) async {

  final headers = await getHeaders(
    includeAuth: true,
  );


  final response = await http.post(
    Uri.parse('$baseUrl$endpoint'),
    headers: {
      ...headers,
      'Content-Type': 'application/json',
    },
    body: jsonEncode(body),
  );


  debugPrint(
    'POST $endpoint: ${response.statusCode}'
  );


  debugPrint(
    response.body
  );


  if(response.statusCode >= 200 &&
     response.statusCode < 300){

    return jsonDecode(response.body);

  }


  throw Exception(
    'POST failed: ${response.statusCode}: ${response.body}'
  );

}

  // Clear token
  Future<void> clearToken() async {
    _accessToken = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      debugPrint('Token cleared');
    } catch (e) {
      debugPrint('Error clearing token: $e');
    }
  }

  // Get headers - automatically loads token if needed
  Future<Map<String, String>> getHeaders({bool includeAuth = false}) async {
    final headers = {
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final token = await getStoredToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
        debugPrint(
            'Adding auth token to request: Bearer ${token.substring(0, 20)}...');
      } else {
        debugPrint(
            'Warning: No auth token available for authenticated request');
      }
    }

    return headers;
  }

  // Send OTP and Registration (with retry logic for server wake-up)
  Future<Map<String, dynamic>> sendOtp({
    required String email,
    required String username,
    required String firstName,
    required String lastName,
    required String password,
    required String phoneNumber,
    String? languagePreference,
    String? role,
    int retryCount = 0,
  }) async {
    try {
      final headers = await getHeaders();
      final url = Uri.parse('$baseUrl/auth/send-otp');

      final requestBody = {
        'email': email,
        'username': username,
        'first_name': firstName,
        'last_name': lastName,
        'password': password,
        'phone_number': phoneNumber,
        'language_preference': (languagePreference ?? 'en').toLowerCase(),
        'role': 'user',
      };

      debugPrint('Sending OTP request to: $url (attempt ${retryCount + 1})');
      debugPrint('Request body: ${jsonEncode(requestBody)}');

      final response = await http
          .post(
        url,
        headers: headers,
        body: jsonEncode(requestBody),
      )
          .timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw TimeoutException('OTP request timed out after 60 seconds');
        },
      );

      debugPrint('Send OTP Response: ${response.statusCode}');
      debugPrint('Send OTP Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode >= 500 && retryCount < 2) {
        // Backend might be waking up (Render free tier), retry after delay
        debugPrint('Server error, retrying in 5 seconds...');
        await Future.delayed(const Duration(seconds: 5));
        return sendOtp(
          email: email,
          username: username,
          firstName: firstName,
          lastName: lastName,
          password: password,
          phoneNumber: phoneNumber,
          languagePreference: languagePreference,
          role: role,
          retryCount: retryCount + 1,
        );
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: _extractErrorMessage(response),
        );
      }
    } on TimeoutException catch (e) {
      if (retryCount < 2) {
        debugPrint('Timeout, retrying in 5 seconds...');
        await Future.delayed(const Duration(seconds: 5));
        return sendOtp(
          email: email,
          username: username,
          firstName: firstName,
          lastName: lastName,
          password: password,
          phoneNumber: phoneNumber,
          languagePreference: languagePreference,
          role: role,
          retryCount: retryCount + 1,
        );
      }
      debugPrint('Send OTP timeout error: $e');
      rethrow;
    } catch (e) {
      debugPrint('Send OTP error: $e');
      rethrow;
    }
  }

  // Verify OTP and Complete Registration
  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
    required String verificationId,
    int retryCount = 0,
  }) async {
    try {
      final headers = await getHeaders();
      final url = Uri.parse('$baseUrl/auth/verify-otp');
      debugPrint('Verifying OTP request to: $url (attempt ${retryCount + 1})');

      final requestBody = {
        'verification_id': verificationId,
        'otp_code': otp,
      };

      debugPrint('Verify OTP request body: ${jsonEncode(requestBody)}');

      final response = await http
          .post(
        url,
        headers: headers,
        body: jsonEncode(requestBody),
      )
          .timeout(
        const Duration(seconds: 45),
        onTimeout: () {
          throw TimeoutException(
              'OTP verification request timed out after 45 seconds');
        },
      );

      debugPrint('Verify OTP Response: ${response.statusCode}');
      debugPrint('Verify OTP Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode >= 500 && retryCount < 2) {
        debugPrint('Server error, retrying in 5 seconds...');
        await Future.delayed(const Duration(seconds: 5));
        return verifyOtp(
          email: email,
          otp: otp,
          verificationId: verificationId,
          retryCount: retryCount + 1,
        );
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: _extractErrorMessage(response),
        );
      }
    } on TimeoutException catch (e) {
      if (retryCount < 2) {
        debugPrint('Verify OTP timeout, retrying in 5 seconds...');
        await Future.delayed(const Duration(seconds: 5));
        return verifyOtp(
          email: email,
          otp: otp,
          verificationId: verificationId,
          retryCount: retryCount + 1,
        );
      }
      debugPrint('Verify OTP timeout error: $e');
      rethrow;
    } catch (e) {
      debugPrint('Verify OTP error: $e');
      rethrow;
    }
  }

  // Login - Primary endpoint only
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('Login attempt for user: $email');

      final headers = await getHeaders();
      final body = {
        'email': email,
        'password': password,
      };

      debugPrint('Login headers: $headers');
      debugPrint('Login request body: ${jsonEncode(body)}');

      final url = Uri.parse('$baseUrl/auth/token');
      debugPrint('Login URL: $url');

      final response = await http
          .post(
            url,
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(
            const Duration(seconds: 45),
          );

      debugPrint('Login Response: ${response.statusCode}');
      debugPrint('Login Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['access_token'] != null) {
          await saveToken(data['access_token']);
        }
        return data;
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: _extractErrorMessage(response),
        );
      }
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    }
  }
  Future<void> saveSymptoms({
  required List<String> symptoms,
  required int severity,
  required String notes,
}) async {
  try {
    final response = await http.post(
      Uri.parse("$baseUrl/user/symptoms"),
      headers: await getHeaders(includeAuth: true),
      body: jsonEncode({
        "symptoms": symptoms,
        "severity": severity,
        "notes": notes,
      }),
    );

    debugPrint("Save Symptoms: ${response.statusCode}");
    debugPrint("Response: ${response.body}");

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      return;
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: _extractErrorMessage(response),
    );
  } catch (e) {
    debugPrint("Save symptoms error: $e");
    rethrow;
  }
}

  // Logout
  Future<void> logout() async {
    try {
      final headers = await getHeaders(includeAuth: true);

      final response = await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: headers,
      );

      debugPrint('Logout Response: ${response.statusCode}');

      await clearToken();

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ApiException(
          statusCode: response.statusCode,
          message: _extractErrorMessage(response),
        );
      }
    } catch (e) {
      debugPrint('Logout error: $e');
      await clearToken();
      rethrow;
    }
  }

  // Forgot Password
  Future<void> forgotPassword({
    required String email,
    String? redirectUrl,
  }) async {
    try {
      final headers = await getHeaders();
      final body = {'email': email};
      if (redirectUrl != null && redirectUrl.isNotEmpty) {
        body['redirect_url'] = redirectUrl;
      }
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot_password'),
        headers: headers,
        body: jsonEncode(body),
      );

      debugPrint('Forgot Password Response: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ApiException(
          statusCode: response.statusCode,
          message: _extractErrorMessage(response),
        );
      }
    } catch (e) {
      debugPrint('Forgot Password error: $e');
      rethrow;
    }
  }

  // Reset Password
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    if (newPassword.length < 8) {
      throw ApiException(
          statusCode: 400,
          message: 'Password must be at least 8 characters long');
    }

    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset_password'),
        headers: headers,
        body: jsonEncode({'token': token, 'new_password': newPassword}),
      );

      debugPrint('Reset Password Response: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ApiException(
          statusCode: response.statusCode,
          message: _extractErrorMessage(response),
        );
      }
    } catch (e) {
      debugPrint('Reset Password error: $e');
      rethrow;
    }
  }
 Future<Map<String, dynamic>> googleLogin(String idToken) async {
  final url = Uri.parse('$baseUrl/auth/google/mobile');

  final response = await http.post(
    url,
    headers: await getHeaders(),
    body: jsonEncode({
  'id_token': idToken,
}),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    final data = jsonDecode(response.body);

    if (data['access_token'] != null) {
      await saveToken(data['access_token']);
    }

    return data;
  } else {
    throw ApiException(
      statusCode: response.statusCode,
      message: _extractErrorMessage(response),
    );
  }
}

  // Get User
  Future<Map<String, dynamic>> getUser() async {
    try {
      final headers = await getHeaders(includeAuth: true);

      final response = await http.get(
        Uri.parse('$baseUrl/user/get_user'),
        headers: headers,
      );

      debugPrint('Get User Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('getUser Raw Response: $data');
        return data;
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: _extractErrorMessage(response),
        );
      }
    } catch (e) {
      debugPrint('Get User error: $e');
      rethrow;
    }
  }
  Future<List<dynamic>> getCyclePrediction() async {

 final response = await http.get(
   Uri.parse(
     "$baseUrl/insights/insights"
   ),
   headers: await getHeaders(),
 );


 if(response.statusCode == 200){

   return jsonDecode(response.body);

 }


 throw Exception(
   "Prediction failed"
 );

}


  Future<List<dynamic>> getInsights() async {
  try {
    final headers = await getHeaders(includeAuth: true);

    final response = await http.get(
      Uri.parse('$baseUrl/insights/insights'),
      headers: headers,
    );

    debugPrint(
      'Get Insights Response: ${response.statusCode}',
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      debugPrint(
        'Insights Raw Response: $data',
      );

      return List<dynamic>.from(data);
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: _extractErrorMessage(response),
      );
    }
  } catch (e) {
    debugPrint('Get Insights error: $e');
    rethrow;
  }
}

  // Get Profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final headers = await getHeaders(includeAuth: true);

      final response = await http.get(
        Uri.parse('$baseUrl/user/profile'),
        headers: headers,
      );

      debugPrint('Get Profile Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('getProfile Raw Response: $data');
        return data;
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: _extractErrorMessage(response),
        );
      }
    } catch (e) {
      debugPrint('Get Profile error: $e');
      rethrow;
    }
  }

  // Update Profile
  Future<Map<String, dynamic>> updateProfile({
    int? age,
    int? cycleLength,
    int? periodLength,
    String? lastPeriodDate,
    String? ttcHistory,
    String? faithPreference,
    bool? audioPreference,
  }) async {
    try {
      final headers = await getHeaders(includeAuth: true);
      final body = <String, dynamic>{};
      if (age != null) body['age'] = age;
      if (cycleLength != null) body['cycle_length'] = cycleLength;
      if (periodLength != null) body['period_length'] = periodLength;
      if (lastPeriodDate != null && lastPeriodDate.isNotEmpty) {
        body['last_period_date'] = lastPeriodDate;
      }
      if (ttcHistory != null && ttcHistory.isNotEmpty) {
        body['ttc_history'] = ttcHistory;
      }
      if (faithPreference != null && faithPreference.isNotEmpty) {
        body['faith_preference'] = faithPreference;
      }
      if (audioPreference != null) body['audio_preference'] = audioPreference;

      debugPrint('Updating Profile with body: $body');

      final response = await http.patch(
        Uri.parse('$baseUrl/user/profile'),
        headers: headers,
        body: jsonEncode(body),
      );

      debugPrint('Update Profile Response: ${response.statusCode}');
      debugPrint('Update Profile Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        debugPrint('Update Profile Success: $responseData');
        return responseData;
      } else {
        debugPrint(
            'Update Profile Failed with status ${response.statusCode}: ${response.body}');
        throw ApiException(
          statusCode: response.statusCode,
          message: _extractErrorMessage(response),
        );
      }
    } catch (e) {
      debugPrint('Update Profile error: $e');
      rethrow;
    }
  }

  /// Delete user account with built-in retry logic and timeout.
  ///
  /// Features:
  /// - 30-second timeout to prevent hanging requests
  /// - Automatic retry on server errors (5xx) and timeouts
  /// - Exponential backoff: 3s, then 6s between retries
  /// - Max 3 attempts (1 initial + 2 retries)
  /// - Clears local token on success or auth errors
  ///
  /// The timeout was added to fix: "ClientException: Failed to fetch" errors
  /// that occurred when the backend was slow or temporarily unavailable.
  ///
  /// Parameters:
  /// - retryCount: Internal parameter for tracking retry attempts (default: 0)
  /// - maxRetries: Maximum number of retries (default: 2, total attempts: 3)
  ///
  /// Example:
  /// ```dart
  /// await apiService.deleteUser();  // Basic usage - 3 total attempts
  /// await apiService.deleteUser(maxRetries: 1);  // 2 total attempts
  /// ```
  Future<void> deleteUser({int retryCount = 0, int maxRetries = 2}) async {
    try {
      final headers = await getHeaders(includeAuth: true);
      final url = Uri.parse('$baseUrl/user/delete_user');

      debugPrint(
          'Attempting to delete user at: $url (attempt ${retryCount + 1}/${maxRetries + 1})');
      debugPrint('Request headers: ${headers.keys.join(", ")}');

      try {
        final response = await http
            .delete(
          url,
          headers: headers,
        )
            .timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw TimeoutException('Delete request timed out after 30 seconds');
          },
        );

        debugPrint('Delete User Response Status: ${response.statusCode}');
        debugPrint('Delete User Response Body: ${response.body}');

        // Accept 200, 204, or even 404 (user already deleted) as success
        if (response.statusCode == 200 ||
            response.statusCode == 204 ||
            response.statusCode == 404) {
          debugPrint('Account deletion successful or user already deleted');
          await clearToken();
          return;
        }

        // For 5xx errors with retries available, attempt retry
        if (response.statusCode >= 500 && retryCount < maxRetries) {
          debugPrint(
              'Server error (${response.statusCode}), retrying in ${(retryCount + 1) * 3} seconds...');
          await Future.delayed(Duration(seconds: (retryCount + 1) * 3));
          return deleteUser(retryCount: retryCount + 1, maxRetries: maxRetries);
        }

        // For other error codes, throw with detailed message
        final errorMessage = _extractErrorMessage(response);
        debugPrint('Delete User Failed: $errorMessage');
        throw ApiException(
          statusCode: response.statusCode,
          message: errorMessage,
        );
      } on TimeoutException catch (e) {
        debugPrint('Delete User timeout: $e');
        if (retryCount < maxRetries) {
          debugPrint(
              'Timeout - retrying in ${(retryCount + 1) * 3} seconds...');
          await Future.delayed(Duration(seconds: (retryCount + 1) * 3));
          return deleteUser(retryCount: retryCount + 1, maxRetries: maxRetries);
        }
        rethrow;
      }
    } catch (e) {
      debugPrint('Delete User error: $e');
      debugPrint('Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  // Extract error message from response
  String _extractErrorMessage(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      if (data is Map && data['detail'] != null) {
        return data['detail'].toString();
      }
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
    } catch (e) {
      // Ignore parsing errors
    }

    // Handle specific status codes
    switch (response.statusCode) {
      case 404:
        return 'The requested resource was not found. Please check the backend configuration.';
      case 500:
        return 'The backend server encountered an error. It may be starting up - please try again.';
      case 503:
        return 'The backend server is temporarily unavailable. This may be because the server is starting up. Please wait a moment and try again.';
      default:
        return 'Request failed with status ${response.statusCode}';
    }
  }

  /// Support email information (no backend endpoint available)
  Future<String> getSupportEmail() async {
    return 'teamnexus@techlaunchpadi';
  }

  // Update Language Preference
  Future<Map<String, dynamic>> updateLanguagePreference(
      String languageCode) async {
    try {
      final headers = await getHeaders(includeAuth: true);
      final body = {'language_preference': languageCode};

      debugPrint('Updating language preference: $languageCode');

      final response = await http.patch(
        Uri.parse('$baseUrl/user/update_language_choice'),
        headers: headers,
        body: jsonEncode(body),
      );

      debugPrint('Update Language Response: ${response.statusCode}');
      debugPrint('Update Language Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        debugPrint('Update Language Success: $responseData');
        return responseData;
      } else {
        debugPrint(
            'Update Language Failed with status ${response.statusCode}: ${response.body}');
        throw ApiException(
          statusCode: response.statusCode,
          message: _extractErrorMessage(response),
        );
      }
    } catch (e) {
      debugPrint('Update Language error: $e');
      rethrow;
    }
  }
}

// Custom API Exception
class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({
    required this.statusCode,
    required this.message,
  });

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}
