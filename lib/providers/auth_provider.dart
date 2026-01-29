import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  
  AuthProvider() {
    _loadCurrentUser();
  }
  
  void _loadCurrentUser() {
    _currentUser = _authService.getCurrentUser();
    notifyListeners();
  }
  
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    int? age,
    String? gender,
    List<String>? mentalHealthGoals,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final user = await _authService.signUp(
        email: email,
        password: password,
        name: name,
        age: age,
        gender: gender,
        mentalHealthGoals: mentalHealthGoals,
      );
      
      if (user != null) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to create account';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final user = await _authService.login(
        email: email,
        password: password,
      );
      
      if (user != null) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Invalid email or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }
  
  Future<bool> updateProfile(UserModel user) async {
    final success = await _authService.updateProfile(user);
    if (success) {
      _currentUser = user;
      notifyListeners();
    }
    return success;
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
