import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../locator.dart';

class AuthProvider extends ChangeNotifier {
  final SharedPreferences _prefs = getIt<SharedPreferences>();
  
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _isLoggedInKey = 'is_logged_in';
  
  String? _userName;
  String? _userEmail;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _error;

  // Dummy credentials for demo
  static const String _dummyEmail = 'user@company.com';
  static const String _dummyPassword = 'password123';

  String? get userName => _userName;
  String? get userEmail => _userEmail;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthProvider() {
    _loadUserData();
  }

  void _loadUserData() {
    _userName = _prefs.getString(_userNameKey);
    _userEmail = _prefs.getString(_userEmailKey);
    _isLoggedIn = _prefs.getBool(_isLoggedInKey) ?? false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));
      
      if (email == _dummyEmail && password == _dummyPassword) {
        // Extract name from email for demo
        String userName = email.split('@')[0];
        userName = userName
            .replaceAll('.', ' ')
            .split(' ')
            .map((word) => word.isNotEmpty
                ? '${word[0].toUpperCase()}${word.substring(1)}'
                : '')
            .join(' ');

        await _saveUserData(userName, email);
        _error = null;
        return true;
      } else {
        _error = 'Invalid email or password';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _prefs.remove(_userNameKey);
      await _prefs.remove(_userEmailKey);
      await _prefs.setBool(_isLoggedInKey, false);
      
      _userName = null;
      _userEmail = null;
      _isLoggedIn = false;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _saveUserData(String userName, String email) async {
    await _prefs.setString(_userNameKey, userName);
    await _prefs.setString(_userEmailKey, email);
    await _prefs.setBool(_isLoggedInKey, true);
    
    _userName = userName;
    _userEmail = email;
    _isLoggedIn = true;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> checkLoginStatus() async {
    _setLoading(true);
    
    try {
      // Simulate checking authentication status
      await Future.delayed(const Duration(milliseconds: 1500));
      
      // Reload user data from SharedPreferences
      _loadUserData();
      
      return _isLoggedIn;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  String getDisplayName() {
    return _userName ?? 'User';
  }

  String getInitials() {
    if (_userName == null || _userName!.isEmpty) return 'U';
    
    List<String> nameParts = _userName!.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else {
      return _userName![0].toUpperCase();
    }
  }
}
