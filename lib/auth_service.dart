import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'appwrite_service.dart';

class User {
  final String id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});
}

class AuthService with ChangeNotifier {
  Client client = Client();
  late Account account;
  late AppwriteService _appwriteService; // Added this line

  bool _isLoggedIn = false;
  User? _currentUser;

  bool get isLoggedIn => _isLoggedIn;
  User? get currentUser => _currentUser;

  AuthService() {
    client
        .setEndpoint('https://sgp.cloud.appwrite.io/v1') 
        .setProject('691948bf001eb3eccd77');
    account = Account(client);
    _appwriteService = AppwriteService(); // Added this line
    init();
  }

  Future<void> init() async {
    try {
      final user = await account.get();
      _isLoggedIn = true;
      _currentUser = User(id: user.$id, name: user.name, email: user.email);
    } on AppwriteException {
      _isLoggedIn = false;
      _currentUser = null;
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    await account.createEmailPasswordSession(email: email, password: password);
    final user = await account.get();
    _isLoggedIn = true;
    _currentUser = User(id: user.$id, name: user.name, email: user.email);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loggedIn', true);
    await prefs.setString('email', email);

    notifyListeners();
  }

  Future<void> signOut() async {
    await account.deleteSession(sessionId: 'current');
    _isLoggedIn = false;
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  Future<void> signUp(String name, String email, String password) async {
    // Create the user account
    await account.create(userId: ID.unique(), name: name, email: email, password: password);
    
    // Immediately log the user in to create a session
    await login(email, password);

    // After login, the user state is updated, and the router will redirect.
    // The profile creation should happen on the screen the user is redirected to.
  }

  Future<User?> getCurrentUser() async {
    return _currentUser;
  }

  Future<void> createPost(Map<String, dynamic> postData) async {
    await _appwriteService.createPost(postData);
  }
}
