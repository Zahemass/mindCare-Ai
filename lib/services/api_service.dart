import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../config/app_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Uses the centralized config — update API_BASE_URL in .env to change
  // Automatically adjusts localhost → 10.0.2.2 for Android emulator
  static String get baseUrl {
    String url = AppConfig.apiBaseUrl;
    if (Platform.isAndroid && url.contains('localhost')) {
      url = url.replaceFirst('localhost', '10.0.2.2');
    }
    print('🔗 ApiService baseUrl: $url');
    return url;
  }

  // --- Token Management ---

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // --- Headers ---

  Future<Map<String, String>> _getHeaders({bool withAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (withAuth) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // --- Response Processing ---

  dynamic _processResponse(http.Response response) {
    print('API Response [${response.statusCode}]: ${response.body}');
    final body = json.decode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      final errorMessage = body['error'] ?? body['message'] ?? 'Something went wrong';
      throw ApiException(errorMessage, response.statusCode);
    }
  }

  // =============================================
  //  AUTHENTICATION APIs
  //  Backend: POST /api/auth/register
  //           POST /api/auth/login
  //           POST /api/auth/forgot-password
  //           POST /api/auth/reset-password
  //           POST /api/auth/logout
  //           GET  /api/auth/profile
  //           PUT  /api/auth/profile
  // =============================================

  /// POST /api/auth/register
  /// Body: { email, password, fullName }
  /// Response: { message, token, user: { id, email, fullName } }
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final url = '$baseUrl/auth/register';
    print('📡 POST $url');
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: await _getHeaders(withAuth: false),
        body: json.encode({
          'email': email,
          'password': password,
          'fullName': fullName,
        }),
      ).timeout(const Duration(seconds: 15));

      final data = _processResponse(response);

      // Save token
      if (data['token'] != null) {
        await _saveToken(data['token']);
      }

      return data;
    } catch (e) {
      print('❌ Register failed: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Cannot connect to server. Check if backend is running and URL is correct ($url)', 0);
    }
  }

  /// POST /api/auth/login
  /// Body: { email, password }
  /// Response: { message, token, user: { id, email, fullName } }
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = '$baseUrl/auth/login';
    print('📡 POST $url');
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: await _getHeaders(withAuth: false),
        body: json.encode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 15));

      final data = _processResponse(response);

      // Save token
      if (data['token'] != null) {
        await _saveToken(data['token']);
      }

      return data;
    } catch (e) {
      print('❌ Login failed: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Cannot connect to server. Check if backend is running and URL is correct ($url)', 0);
    }
  }

  /// POST /api/auth/forgot-password
  /// Body: { email }
  /// Response: { message, resetToken }
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: await _getHeaders(withAuth: false),
      body: json.encode({'email': email}),
    );

    return _processResponse(response);
  }

  /// POST /api/auth/reset-password
  /// Body: { token, newPassword }
  /// Response: { message }
  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: await _getHeaders(withAuth: false),
      body: json.encode({
        'token': token,
        'newPassword': newPassword,
      }),
    );

    return _processResponse(response);
  }

  /// POST /api/auth/logout
  /// Response: { message }
  Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: await _getHeaders(),
      );
    } catch (_) {
      // Even if the API call fails, we still clear the token locally
    }
    await _removeToken();
  }

  /// GET /api/auth/profile
  /// Response: { user: { id, email, full_name, created_at } }
  Future<UserModel> getProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/profile'),
      headers: await _getHeaders(),
    );

    final data = _processResponse(response);
    final userData = data['user'];

    return UserModel(
      id: userData['id'].toString(),
      email: userData['email'] ?? '',
      name: userData['full_name'] ?? '',
      createdAt: userData['created_at'] != null
          ? DateTime.parse(userData['created_at'])
          : DateTime.now(),
    );
  }

  /// PUT /api/auth/profile
  /// Body: { fullName }
  /// Response: { message, user }
  Future<Map<String, dynamic>> updateProfile({required String fullName}) async {
    final response = await http.put(
      Uri.parse('$baseUrl/auth/profile'),
      headers: await _getHeaders(),
      body: json.encode({'fullName': fullName}),
    );

    return _processResponse(response);
  }

  // =============================================
  //  MOOD APIs
  //  Backend: POST /api/mood
  //           GET  /api/mood/history?days=30
  // =============================================

  /// POST /api/mood
  /// Body: { mood, intensity, note }
  /// Response: { message, data: { id, user_id, mood, intensity, note, created_at } }
  Future<Map<String, dynamic>> logMood({
    required String mood,
    required int intensity,
    String? note,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/mood'),
      headers: await _getHeaders(),
      body: json.encode({
        'mood': mood,
        'intensity': intensity,
        'note': note,
      }),
    );

    return _processResponse(response);
  }

  /// GET /api/mood/history?days=30
  /// Response: { moods: [ { id, user_id, mood, intensity, note, created_at } ] }
  Future<List<Map<String, dynamic>>> getMoodHistory({int days = 30}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/mood/history?days=$days'),
      headers: await _getHeaders(),
    );

    final data = _processResponse(response);
    return List<Map<String, dynamic>>.from(data['moods'] ?? []);
  }

  // =============================================
  //  JOURNAL APIs
  //  Backend: POST /api/journal
  //           POST /api/journal/ai-insight
  //           GET  /api/journal/history
  // =============================================

  /// POST /api/journal
  /// Body: { title, content }
  /// Response: { message, data: { id, user_id, title, content, created_at } }
  Future<Map<String, dynamic>> createJournalEntry({
    required String title,
    required String content,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/journal'),
      headers: await _getHeaders(),
      body: json.encode({
        'title': title,
        'content': content,
      }),
    );

    return _processResponse(response);
  }

  /// POST /api/journal/ai-insight
  /// Body: { content }
  /// Response: { emotion, insight }
  Future<Map<String, dynamic>> getJournalAIInsight(String content) async {
    final response = await http.post(
      Uri.parse('$baseUrl/journal/ai-insight'),
      headers: await _getHeaders(),
      body: json.encode({'content': content}),
    );

    return _processResponse(response);
  }

  /// GET /api/journal/history
  /// Response: { journals: [ { id, user_id, title, content, created_at } ] }
  Future<List<Map<String, dynamic>>> getJournalHistory() async {
    final response = await http.get(
      Uri.parse('$baseUrl/journal/history'),
      headers: await _getHeaders(),
    );

    final data = _processResponse(response);
    return List<Map<String, dynamic>>.from(data['journals'] ?? []);
  }

  // =============================================
  //  CHAT APIs
  //  Backend: POST /api/chat/text
  //           POST /api/chat/voice  (multipart)
  //           GET  /api/chat/history?limit=50
  // =============================================

  /// POST /api/chat/text
  /// Body: { message }
  /// Response: { message (ai response), emotion, riskLevel }
  Future<Map<String, dynamic>> sendTextMessage(String message) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat/text'),
      headers: await _getHeaders(),
      body: json.encode({'message': message}),
    );

    return _processResponse(response);
  }

  /// POST /api/chat/voice (multipart/form-data)
  /// Field: audio (file)
  /// Response: { transcription, message, emotion, riskLevel }
  Future<Map<String, dynamic>> sendVoiceMessage(File audioFile) async {
    final token = await _getToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/chat/voice'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(
      await http.MultipartFile.fromPath('audio', audioFile.path),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return _processResponse(response);
  }

  /// GET /api/chat/history?limit=50
  /// Response: { chats: [ { id, user_id, user_message, ai_response, emotion, risk_level, is_voice, created_at } ] }
  Future<List<Map<String, dynamic>>> getChatHistory({int limit = 50}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/chat/history?limit=$limit'),
      headers: await _getHeaders(),
    );

    final data = _processResponse(response);
    return List<Map<String, dynamic>>.from(data['chats'] ?? []);
  }

  // =============================================
  //  MEDITATION APIs
  //  Backend: GET  /api/meditation/sessions
  //           POST /api/meditation/complete
  // =============================================

  /// GET /api/meditation/sessions
  /// Response: { sessions: [ { id, title, description, duration, category, ... } ] }
  Future<List<Map<String, dynamic>>> getMeditationSessions() async {
    final response = await http.get(
      Uri.parse('$baseUrl/meditation/sessions'),
      headers: await _getHeaders(),
    );

    final data = _processResponse(response);
    return List<Map<String, dynamic>>.from(data['sessions'] ?? []);
  }

  /// POST /api/meditation/complete
  /// Body: { activityId, duration }
  /// Response: { message, data }
  Future<Map<String, dynamic>> completeActivity({
    required String activityId,
    required int duration,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/meditation/complete'),
      headers: await _getHeaders(),
      body: json.encode({
        'activityId': activityId,
        'duration': duration,
      }),
    );

    return _processResponse(response);
  }

  // =============================================
  //  INSIGHTS APIs
  //  Backend: GET /api/insights/mood?days=30
  //           GET /api/insights/activity
  // =============================================

  /// GET /api/insights/mood?days=30
  /// Response: { data, summary: { totalEntries, moodDistribution } }
  Future<Map<String, dynamic>> getMoodInsights({int days = 30}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/insights/mood?days=$days'),
      headers: await _getHeaders(),
    );

    return _processResponse(response);
  }

  /// GET /api/insights/activity
  /// Response: { totalActivities, activities: [...] }
  Future<Map<String, dynamic>> getActivityInsights() async {
    final response = await http.get(
      Uri.parse('$baseUrl/insights/activity'),
      headers: await _getHeaders(),
    );

    return _processResponse(response);
  }

  // =============================================
  //  RESOURCES APIs
  //  Backend: GET /api/resources?category=...
  // =============================================

  /// GET /api/resources?category=...
  /// Response: { resources: [...] }
  Future<List<Map<String, dynamic>>> getResources({String? category}) async {
    String url = '$baseUrl/resources';
    if (category != null) {
      url += '?category=$category';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: await _getHeaders(),
    );

    final data = _processResponse(response);
    return List<Map<String, dynamic>>.from(data['resources'] ?? []);
  }

  // =============================================
  //  ASSESSMENT APIs
  //  Backend: POST /api/assessment/submit
  //           GET  /api/assessment/result
  // =============================================

  /// POST /api/assessment/submit
  /// Body: { answers: [ { question, score } ] }
  /// Response: { message, score, riskLevel }
  Future<Map<String, dynamic>> submitAssessment(
      List<Map<String, dynamic>> answers) async {
    final response = await http.post(
      Uri.parse('$baseUrl/assessment/submit'),
      headers: await _getHeaders(),
      body: json.encode({'answers': answers}),
    );

    return _processResponse(response);
  }

  /// GET /api/assessment/result
  /// Response: { assessment: { id, user_id, answers, score, risk_level, created_at } }
  Future<Map<String, dynamic>> getAssessmentResult() async {
    final response = await http.get(
      Uri.parse('$baseUrl/assessment/result'),
      headers: await _getHeaders(),
    );

    return _processResponse(response);
  }

  // =============================================
  //  USER APIs
  //  Backend: POST /api/user/goals
  //           GET  /api/user/preferences
  //           PUT  /api/user/preferences
  // =============================================

  /// POST /api/user/goals
  /// Body: { goals: [...] }
  /// Response: { message, data }
  Future<Map<String, dynamic>> setGoals(List<String> goals) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/goals'),
      headers: await _getHeaders(),
      body: json.encode({'goals': goals}),
    );

    return _processResponse(response);
  }

  /// GET /api/user/preferences
  /// Response: { preferences: { ... } }
  Future<Map<String, dynamic>> getPreferences() async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/preferences'),
      headers: await _getHeaders(),
    );

    return _processResponse(response);
  }

  /// PUT /api/user/preferences
  /// Body: { key: value, ... }
  /// Response: { message, data }
  Future<Map<String, dynamic>> updatePreferences(
      Map<String, dynamic> preferences) async {
    final response = await http.put(
      Uri.parse('$baseUrl/user/preferences'),
      headers: await _getHeaders(),
      body: json.encode(preferences),
    );

    return _processResponse(response);
  }

  // =============================================
  //  NOTIFICATIONS APIs
  //  Backend: POST /api/notifications/register
  //           GET  /api/notifications/settings
  //           PUT  /api/notifications/settings
  // =============================================

  /// POST /api/notifications/register
  /// Body: { deviceToken, platform }
  /// Response: { message, data }
  Future<Map<String, dynamic>> registerDevice({
    required String deviceToken,
    required String platform,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/notifications/register'),
      headers: await _getHeaders(),
      body: json.encode({
        'deviceToken': deviceToken,
        'platform': platform,
      }),
    );

    return _processResponse(response);
  }

  /// GET /api/notifications/settings
  /// Response: { settings: { ... } }
  Future<Map<String, dynamic>> getNotificationSettings() async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications/settings'),
      headers: await _getHeaders(),
    );

    return _processResponse(response);
  }

  /// PUT /api/notifications/settings
  /// Body: { key: value, ... }
  /// Response: { message, data }
  Future<Map<String, dynamic>> updateNotificationSettings(
      Map<String, dynamic> settings) async {
    final response = await http.put(
      Uri.parse('$baseUrl/notifications/settings'),
      headers: await _getHeaders(),
      body: json.encode(settings),
    );

    return _processResponse(response);
  }

  // =============================================
  //  FEEDBACK APIs
  //  Backend: POST /api/feedback
  //           POST /api/feedback/delete-account
  // =============================================

  /// POST /api/feedback
  /// Body: { feedback, rating }
  /// Response: { message, data }
  Future<Map<String, dynamic>> submitFeedback({
    required String feedback,
    required int rating,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/feedback'),
      headers: await _getHeaders(),
      body: json.encode({
        'feedback': feedback,
        'rating': rating,
      }),
    );

    return _processResponse(response);
  }

  /// POST /api/feedback/delete-account
  /// Response: { message }
  Future<Map<String, dynamic>> deleteAccount() async {
    final response = await http.post(
      Uri.parse('$baseUrl/feedback/delete-account'),
      headers: await _getHeaders(),
    );

    final data = _processResponse(response);
    await _removeToken();
    return data;
  }

  // =============================================
  //  UTILITY: Check if user is authenticated
  // =============================================

  Future<bool> isAuthenticated() async {
    final token = await _getToken();
    return token != null;
  }

  /// Health check
  Future<bool> healthCheck() async {
    try {
      // baseUrl ends with /api, health is at root
      final rootUrl = baseUrl.replaceAll('/api', '');
      final response = await http
          .get(Uri.parse('$rootUrl/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

// Custom exception class for API errors
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;

  bool get isUnauthorized => statusCode == 401 || statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isServerError => statusCode >= 500;
}
