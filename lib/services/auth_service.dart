import '../models/user_model.dart';
import 'storage_service.dart';
import 'api_service.dart';

class AuthService {
  final StorageService _storage = StorageService();
  final ApiService _apiService = ApiService();

  // Sign up via backend API
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String name,
    int? age,
    String? gender,
    List<String>? mentalHealthGoals,
  }) async {
    try {
      final data = await _apiService.register(
        fullName: name,
        email: email,
        password: password,
      );

      // Build user model from response
      final userData = data['user'];
      final user = UserModel(
        id: userData['id'].toString(),
        email: userData['email'] ?? email,
        name: userData['fullName'] ?? name,
        age: age,
        gender: gender,
        mentalHealthGoals: mentalHealthGoals ?? [],
      );

      // Save locally for offline access
      await _storage.saveUser(user);

      return user;
    } catch (e) {
      print('Sign up error: $e');
      rethrow;
    }
  }

  // Login via backend API
  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    try {
      final data = await _apiService.login(email, password);

      // Build user model from response
      final userData = data['user'];
      final user = UserModel(
        id: userData['id'].toString(),
        email: userData['email'] ?? email,
        name: userData['fullName'] ?? '',
        lastLoginAt: DateTime.now(),
      );

      // Save locally for offline access
      await _storage.saveUser(user);

      return user;
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  // Logout via backend API
  Future<void> logout() async {
    try {
      await _apiService.logout();
    } catch (_) {
      // Still clear local data even if API fails
    }
    // Clear ALL local data (user, mood, journal, chat, etc.)
    await _storage.clearAllData();
  }

  // Get current user (from local storage for quick access)
  UserModel? getCurrentUser() {
    return _storage.getCurrentUser();
  }

  // Update user profile via backend API
  Future<bool> updateProfile(UserModel user) async {
    try {
      await _apiService.updateProfile(fullName: user.name);
      
      // Also update goals if present
      if (user.mentalHealthGoals.isNotEmpty) {
        await _apiService.setGoals(user.mentalHealthGoals);
      }

      await _storage.saveUser(user);
      return true;
    } catch (e) {
      print('Update profile error: $e');
      return false;
    }
  }

  // Fetch profile from backend and update local storage
  Future<UserModel?> fetchProfile() async {
    try {
      final user = await _apiService.getProfile();
      await _storage.saveUser(user);
      return user;
    } catch (e) {
      print('Fetch profile error: $e');
      return null;
    }
  }

  // Forgot password
  Future<bool> forgotPassword(String email) async {
    try {
      await _apiService.forgotPassword(email);
      return true;
    } catch (e) {
      print('Forgot password error: $e');
      return false;
    }
  }

  // Reset password
  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await _apiService.resetPassword(
        token: token,
        newPassword: newPassword,
      );
      return true;
    } catch (e) {
      print('Reset password error: $e');
      return false;
    }
  }

  // Delete account
  Future<bool> deleteAccount() async {
    try {
      await _apiService.deleteAccount();
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

  // Check if authenticated with backend
  Future<bool> isAuthenticated() async {
    return await _apiService.isAuthenticated();
  }
}
