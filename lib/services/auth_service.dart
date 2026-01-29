import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user_model.dart';
import 'storage_service.dart';
import 'package:uuid/uuid.dart';

class AuthService {
  final StorageService _storage = StorageService();
  final _uuid = const Uuid();
  
  // Hash password
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  // Sign up
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String name,
    int? age,
    String? gender,
    List<String>? mentalHealthGoals,
  }) async {
    try {
      // Check if user already exists
      final existingPassword = _storage.getPassword(email);
      if (existingPassword != null) {
        throw Exception('User already exists with this email');
      }
      
      // Create new user
      final user = UserModel(
        id: _uuid.v4(),
        email: email,
        name: name,
        age: age,
        gender: gender,
        mentalHealthGoals: mentalHealthGoals ?? [],
      );
      
      // Save user and password
      await _storage.saveUser(user);
      await _storage.savePassword(email, _hashPassword(password));
      
      return user;
    } catch (e) {
      print('Sign up error: $e');
      return null;
    }
  }
  
  // Login
  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    try {
      // Get stored password
      final storedPassword = _storage.getPassword(email);
      if (storedPassword == null) {
        throw Exception('User not found');
      }
      
      // Verify password
      final hashedPassword = _hashPassword(password);
      if (hashedPassword != storedPassword) {
        throw Exception('Invalid password');
      }
      
      // Get user
      final user = _storage.getCurrentUser();
      if (user == null || user.email != email) {
        throw Exception('User data not found');
      }
      
      // Update last login
      final updatedUser = user.copyWith(lastLoginAt: DateTime.now());
      await _storage.saveUser(updatedUser);
      
      return updatedUser;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }
  
  // Logout
  Future<void> logout() async {
    // Note: We keep the user data but just mark as logged out
    // In a real app, you might want to clear session tokens
  }
  
  // Get current user
  UserModel? getCurrentUser() {
    return _storage.getCurrentUser();
  }
  
  // Update user profile
  Future<bool> updateProfile(UserModel user) async {
    try {
      await _storage.saveUser(user);
      return true;
    } catch (e) {
      print('Update profile error: $e');
      return false;
    }
  }
  
  // Change password
  Future<bool> changePassword({
    required String email,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final storedPassword = _storage.getPassword(email);
      if (storedPassword == null) {
        throw Exception('User not found');
      }
      
      // Verify old password
      if (_hashPassword(oldPassword) != storedPassword) {
        throw Exception('Invalid old password');
      }
      
      // Save new password
      await _storage.savePassword(email, _hashPassword(newPassword));
      return true;
    } catch (e) {
      print('Change password error: $e');
      return false;
    }
  }
  
  // Reset password (simplified - in real app would send email)
  Future<bool> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      final storedPassword = _storage.getPassword(email);
      if (storedPassword == null) {
        throw Exception('User not found');
      }
      
      await _storage.savePassword(email, _hashPassword(newPassword));
      return true;
    } catch (e) {
      print('Reset password error: $e');
      return false;
    }
  }
  
  // Delete account
  Future<bool> deleteAccount(String email, String password) async {
    try {
      final storedPassword = _storage.getPassword(email);
      if (storedPassword == null) {
        throw Exception('User not found');
      }
      
      // Verify password
      if (_hashPassword(password) != storedPassword) {
        throw Exception('Invalid password');
      }
      
      // Delete all user data
      await _storage.clearAllData();
      return true;
    } catch (e) {
      print('Delete account error: $e');
      return false;
    }
  }
  
  // Check if user is logged in
  bool isLoggedIn() {
    return _storage.getCurrentUser() != null;
  }
}
