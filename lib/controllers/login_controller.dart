import '../services/auth_service.dart';

class LoginController {
  final AuthService _auth = AuthService.instance;

  AuthUser? login(String username, String password) {
    final normalized = username.trim().toLowerCase();
    final userMap = {
      'owner': const AuthUser(
        username: 'owner',
        role: 'owner',
        displayName: 'Chủ',
      ),
      'ketoan1': const AuthUser(
        username: 'ketoan1',
        role: 'accountant',
        displayName: 'Kế toán 1',
      ),
      'ketoan2': const AuthUser(
        username: 'ketoan2',
        role: 'accountant',
        displayName: 'Kế toán 2',
      ),
      'user1': const AuthUser(
        username: 'user1',
        role: 'user',
        displayName: 'User 1',
      ),
      'user2': const AuthUser(
        username: 'user2',
        role: 'user',
        displayName: 'User 2',
      ),
    };

    final passwordMap = {
      'owner': '123',
      'ketoan1': '123',
      'ketoan2': '123',
      'user1': '123',
      'user2': '123',
    };

    final user = userMap[normalized];
    if (user == null) return null;
    if (passwordMap[normalized] != password) return null;

    _auth.login(user);
    return user;
  }
}
