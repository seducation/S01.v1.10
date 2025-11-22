import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final String id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});
}

class AuthService with ChangeNotifier {
  bool _isLoggedIn = false;
  User? _currentUser;

  bool get isLoggedIn => _isLoggedIn;
  User? get currentUser => _currentUser;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('loggedIn') ?? false;
    if (_isLoggedIn) {
      final email = prefs.getString('email') ?? '';
      // In a real app, you'd fetch the user details from your backend
      _currentUser = User(id: 'user-123', name: 'Test User', email: email);
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    // Simulate a login request.
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loggedIn', true);
    await prefs.setString('email', email);
    _isLoggedIn = true;
    _currentUser = User(id: 'user-123', name: 'Test User', email: email);
    notifyListeners();
  }

  Future<void> signOut() async {
    // Simulate a logout request.
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('loggedIn');
    await prefs.remove('email');
    _isLoggedIn = false;
    _currentUser = null;
    notifyListeners();
  }

    Future<void> signUp(String email, String password) async {
    // Simulate a signup request.
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loggedIn', true);
    await prefs.setString('email', email);
    _isLoggedIn = true;
     _currentUser = User(id: 'user-456', name: 'New User', email: email);
    notifyListeners();
  }

  Future<User?> getCurrentUser() async {
    return _currentUser;
  }

  Future<void> createPost(Map<String, dynamic> postData) async {
    // Simulate creating a post
    await Future.delayed(const Duration(seconds: 1));
  }
}
