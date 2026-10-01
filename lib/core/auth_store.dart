class AuthStore {
  AuthStore._();

  static Map<String, String>? _currentUser;

  static Map<String, String>? get currentUser => _currentUser;

  static String get currentUserName => _currentUser?['fullName'] ?? 'there';

  static String get currentUserEmail => _currentUser?['email'] ?? '';

  static void setCurrentUser(Map<String, String> user) {
    _currentUser = Map<String, String>.from(user);
  }

  static void clear() {
    _currentUser = null;
  }
}