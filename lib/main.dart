import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'controllers/login_controller.dart';
import 'screens/app_shell.dart';
import 'services/auth_service.dart';
import 'services/firebase_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbFolder = await getDatabasesPath();
    final dbPath = p.join(dbFolder, "qlvt.db");

    developer.log("================================");
    developer.log("Database Folder : $dbFolder");
    developer.log("Database File   : $dbPath");
    developer.log("Database Exists : ${await File(dbPath).exists()}");
    developer.log("================================");
  }

  await FirebaseService.initialize();

  runApp(const AnhDuongERP());
}

class AnhDuongERP extends StatelessWidget {
  const AnhDuongERP({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "ERP Ánh Dương",
      theme: AppTheme.lightTheme,
      home: const LoginPage(),
      routes: {'/login': (context) => const LoginPage()},
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginController controller = LoginController();

  final usernameController = TextEditingController();

  final passwordController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tên đăng nhập và mật khẩu.'),
        ),
      );
      return;
    }

    final localUser = controller.login(username, password);
    if (localUser != null) {
      if (!mounted) return;
      try {
        await FirebaseService.signInAnonymously();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi đăng nhập Firebase: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const AppShell()));
      return;
    }

    try {
      final email = username.contains('@')
          ? username
          : '$username@company.local';
      await FirebaseService.signIn(email, password);

      String role = 'user';
      if (email.toLowerCase() == 'owner@qlvt.app') {
        role = 'owner';
      } else if (email.toLowerCase() == 'accountant@qlvt.app' ||
          email.toLowerCase() == 'ketoan@qlvt.app') {
        role = 'accountant';
      }

      AuthService.instance.login(
        AuthUser(username: email, role: role, displayName: email),
      );
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const AppShell()));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Đăng nhập thất bại: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F7FC),

      body: Center(
        child: Container(
          width: 430,

          padding: const EdgeInsets.all(35),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 25,
                offset: Offset(0, 10),
              ),
            ],
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              Image.asset("assets/images/logo.png", height: 110),

              const SizedBox(height: 20),

              const Text(
                "CÔNG TY CỔ PHẦN",
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),

              const SizedBox(height: 5),

              const Text(
                "ÁNH DƯƠNG",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff0D4F8B),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "ERP - Hệ thống Quản lý vật tư",
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),

              const SizedBox(height: 35),

              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: "Email đăng nhập",
                  prefixIcon: Icon(Icons.person),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: passwordController,
                obscureText: true,
                onSubmitted: (_) => login(),
                decoration: const InputDecoration(
                  labelText: "Mật khẩu",
                  prefixIcon: Icon(Icons.lock),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 52,

                child: ElevatedButton(
                  onPressed: login,

                  child: const Text(
                    "ĐĂNG NHẬP",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "© 2025 Công ty Cổ phần Ánh Dương",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
