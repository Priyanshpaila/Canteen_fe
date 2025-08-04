// ignore_for_file: use_build_context_synchronously

import 'package:canteen_fe/controllers/auth_controller.dart';
import 'package:canteen_fe/providers/user_provider.dart';
import 'package:canteen_fe/views/home/admin_home_screen.dart';
import 'package:canteen_fe/views/home/super_admin_home_screen.dart';
import 'package:canteen_fe/views/home/user_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final phoneController = TextEditingController();
  final pinController = TextEditingController();
  bool isLoading = false;

  void _login() async {
    setState(() => isLoading = true);
    final authController = ref.read(authControllerProvider);
    final error = await authController.login(
      phoneController.text.trim(),
      pinController.text.trim(),
      context,
    );
    setState(() => isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    final role = ref.read(userProvider)?.canteenRole;
    if (role == 'user') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UserHomeScreen()),
      );
    } else if (role == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
      );
    } else if (role == 'superadmin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SuperAdminHomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Unknown role")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone Number'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'PIN'),
            ),
            const SizedBox(height: 24),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(onPressed: _login, child: const Text('Login')),
          ],
        ),
      ),
    );
  }
}
