import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/resource.dart';
import '../data/resource_data.dart';

class ResourceProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Resource> _resources = staticResources;
  bool _isLoading = false;
  String? _error;

  List<Resource> get resources => _resources;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchResources({String? category}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final resourcesData = await _apiService.getResources(category: category);
      _resources = resourcesData.map((data) => Resource.fromJson(data)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
