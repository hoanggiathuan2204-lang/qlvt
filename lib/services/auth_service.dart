class AuthUser {
  final String username;
  final String role;
  final String displayName;

  const AuthUser({
    required this.username,
    required this.role,
    required this.displayName,
  });

  bool get isFullAccess => role == 'owner' || role == 'accountant';
  bool get canViewUnitPrice => isFullAccess;
}

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  AuthUser? currentUser;

  bool get isLoggedIn => currentUser != null;
  bool get canViewUnitPrice => currentUser?.canViewUnitPrice ?? false;
  bool get canFullAccess => currentUser?.isFullAccess ?? false;

  void login(AuthUser user) {
    currentUser = user;
  }

  void logout() {
    currentUser = null;
  }
}
