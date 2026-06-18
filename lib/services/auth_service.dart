import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_service.dart';
import 'analytics_service.dart';

abstract class AuthServiceInterface {
  Future<User?> signIn(String email, String password);
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String username,
  });
  Future<User?> signUpWithPhone({
    required String phoneNumber,
    String? email,
    String? username,
    String? firstName,
    String? lastName,
    String? password,
    String? preferredLanguage,
  });
  Future<void> forgotPassword({required String email, String? redirectUrl});
  Future<void> signOut();
  User? getCurrentUser();
  Stream<User?> authStateChanges();
  Future<void> resendEmailOTP(String email);
  Future<void> resendPhoneOTP(String phoneNumber);
  Future<User?> verifyEmailOTP(String email, String otp);
  Future<User?> verifyPhoneOTP(String phoneNumber, String otp);
  Future<void> updateUserProfile(Map<String, dynamic> updates);
}

class AuthService extends ChangeNotifier implements AuthServiceInterface {
  User? _currentUser;
  StreamController<User?> _authStateController =
      StreamController<User?>.broadcast();

  final String _prefsKey = 'currentUser';

  AuthService() {
    _loadUserFromPrefs();
  }

  Future<void> _loadUserFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_prefsKey);
      if (userJson != null && userJson.isNotEmpty) {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        _currentUser = User.fromJson(userMap);
        _authStateController.add(_currentUser);
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user from prefs: $e');
      }
    }
  }
  
  Future<void> refreshCurrentUser() async {
  try {
    final apiService = ApiService();

    final userJson = await apiService.getUser();
    final user = User.fromJson(userJson);

    _currentUser = user;

    await _saveUserToPrefs(user);

    _authStateController.add(_currentUser);
    notifyListeners();
  } catch (e) {
    if (kDebugMode) {
      print('Error refreshing user: $e');
    }
  }
}
  Future<void> _saveUserToPrefs(User? user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (user != null) {
        await prefs.setString(_prefsKey, json.encode(user.toJson()));
      } else {
        await prefs.remove(_prefsKey);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving user to prefs: $e');
      }
    }
  }

  @override
  Future<User?> signIn(String email, String password) async {
    try {
      // Call the actual API login endpoint
      final apiService = ApiService();
      await apiService.login(email: email, password: password);

      // Login response only contains access_token and token_type
      // Token is already saved by ApiService.login()
      // Now fetch the user data using the token
      final userJson = await apiService.getUser();
      final user = User.fromJson(userJson);

      // Save user to preferences
      await _saveUserToPrefs(user);

      _currentUser = user;
      _authStateController.add(_currentUser);
      notifyListeners();

      await AnalyticsService.logLogin(method: 'email');

      return _currentUser;
    } catch (e) {
      if (kDebugMode) {
        print('SignIn error: $e');
      }
      rethrow;
    }
  }

Future<void> googleLogin(String idToken) async {
  try {
    final apiService = ApiService();

    final response = await apiService.googleLogin(idToken);

    // Save token returned by backend
    if (response.containsKey('access_token')) {
      await apiService.saveToken(response['access_token']);

      final userJson = await apiService.getUser();
      final user = User.fromJson(userJson);

      _currentUser = user;
      await _saveUserToPrefs(user);

      _authStateController.add(_currentUser);
      notifyListeners();
    }
  } catch (e) {
    if (kDebugMode) {
      print('Google login error: $e');
    }
    rethrow;
  }
}
  @override
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String username,
  }) async {
    // Mock implementation
    await Future.delayed(Duration(seconds: 1));
    _currentUser = User(
      id: '2',
      email: email,
      firstName: firstName,
      lastName: lastName,
    );
    await _saveUserToPrefs(_currentUser);
    _authStateController.add(_currentUser);
    notifyListeners();

    await AnalyticsService.logSignUp(method: 'email');

    return _currentUser;
  }

  // Store verification_id temporarily
  String? _verificationId;

  String? get verificationId => _verificationId;

  @override
  Future<User?> signUpWithPhone({
    required String phoneNumber,
    String? email,
    String? username,
    String? firstName,
    String? lastName,
    String? password,
    String? preferredLanguage,
  }) async {
    try {
      final apiService = ApiService();

      // Call sendOtp API endpoint
      final response = await apiService.sendOtp(
        email: email ?? '$phoneNumber@example.com',
        username: username ?? phoneNumber,
        firstName: firstName ?? 'User',
        lastName: lastName ?? '',
        password: password ?? '',
        phoneNumber: phoneNumber,
        languagePreference: preferredLanguage ?? 'en',
      );

      if (kDebugMode) {
        print('OTP sent successfully: $response');
      }

      // Store verification_id for later use
      if (response.containsKey('verification_id')) {
        _verificationId = response['verification_id'];
      } else if (response.containsKey('verificationId')) {
        _verificationId = response['verificationId'];
      }

      // Don't set current user yet - wait for OTP verification
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error in signUpWithPhone: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> forgotPassword(
      {required String email, String? redirectUrl}) async {
    // Mock implementation
    await Future.delayed(Duration(seconds: 1));
    print('Password reset email sent to $email');
  }

  @override
  Future<void> signOut() async {
    try {
      // Clear API token
      await ApiService().clearToken();
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing API token on signOut: $e');
      }
    }

    _currentUser = null;
    await _saveUserToPrefs(null);
    _authStateController.add(null);
    notifyListeners();
  }

  @override
  User? getCurrentUser() {
    return _currentUser;
  }

  // Getter for convenience
  User? get currentUser => _currentUser;

  @override
  Stream<User?> authStateChanges() {
    return _authStateController.stream;
  }

  @override
  Future<void> resendEmailOTP(String email) async {
    await Future.delayed(Duration(seconds: 1));
  }

  @override
  Future<void> resendPhoneOTP(String phoneNumber) async {
    await Future.delayed(Duration(seconds: 1));
  }

  @override
  Future<User?> verifyEmailOTP(String email, String otp) async {
    await Future.delayed(Duration(seconds: 1));
    return _currentUser;
  }

  @override
  Future<User?> verifyPhoneOTP(String phoneNumber, String otp) async {
    try {
      final apiService = ApiService();

      // Use stored verification_id
      final verificationId = _verificationId ?? '';

      if (verificationId.isEmpty) {
        throw Exception('No verification ID found. Please request OTP again.');
      }

      // Call verify OTP endpoint
      final response = await apiService.verifyOtp(
        email: phoneNumber,
        otp: otp,
        verificationId: verificationId,
      );

      if (kDebugMode) {
        print('OTP verified successfully: $response');
      }

      // After successful verification, get user data
      if (response.containsKey('access_token')) {
        await apiService.saveToken(response['access_token']);

        // Fetch user data
        final userJson = await apiService.getUser();
        final user = User.fromJson(userJson);

        await _saveUserToPrefs(user);
        _currentUser = user;
        _authStateController.add(_currentUser);
        notifyListeners();

        await AnalyticsService.logSignUp(method: 'phone_otp');

        // Clear verification_id after successful verification
        _verificationId = null;

        return user;
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error in verifyPhoneOTP: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    if (_currentUser != null) {
      // Update user properties
      if (updates.containsKey('firstName')) {
        // Note: User class is immutable, so we need to create a new instance
        // For simplicity, we'll just update the mock user
      }
      await _saveUserToPrefs(_currentUser);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authStateController.close();
    super.dispose();
  }
}
