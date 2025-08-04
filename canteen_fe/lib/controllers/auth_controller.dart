import 'dart:developer';
import 'package:canteen_fe/models/user_model.dart';
import 'package:canteen_fe/providers/token_provider.dart';
import 'package:canteen_fe/providers/user_provider.dart';
import 'package:canteen_fe/services/auth_service.dart';
import 'package:canteen_fe/views/home/admin_home_screen.dart';
import 'package:canteen_fe/views/home/super_admin_home_screen.dart';
import 'package:canteen_fe/views/home/user_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authControllerProvider = Provider((ref) => AuthController(ref));

class AuthController {
  final Ref ref;
  AuthController(this.ref);

  final AuthService _authService = AuthService();

  /// ✅ Login and persist token/user + navigate by role
  Future<String?> login(String phone, String pin, BuildContext context) async {
    try {
      final result = await _authService.login(phone, pin);
      final token = result['token'];
      final user = result['user'];

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      // Update state
      final userModel = UserModel.fromJson(user);
      ref.read(tokenProvider.notifier).state = token;
      ref.read(userProvider.notifier).state = userModel;

      _navigateBasedOnRole(userModel.canteenRole, context);

      return null; // success
    } catch (e) {
      log('Login error: $e');
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  /// ✅ Signup then auto-login + navigate by role
  Future<String?> signupAndLogin({
    required String phoneNumber,
    required String pin,
    required String empid,
    required String fullName,
    required String division,
    required String department,
    required String designation,
    required BuildContext context,
  }) async {
    try {
      final result = await _authService.signup(
        phoneNumber: phoneNumber,
        pin: pin,
        empid: empid,
        fullName: fullName,
        division: division,
        department: department,
        designation: designation,
      );

      final token = result['token'];
      final user = result['user'];

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      // Update state
      final userModel = UserModel.fromJson(user);
      ref.read(tokenProvider.notifier).state = token;
      ref.read(userProvider.notifier).state = userModel;

      _navigateBasedOnRole(userModel.canteenRole, context);

      return null; // success
    } catch (e) {
      log('Signup error: $e');
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  /// ✅ Logout and clear all session info
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    ref.read(tokenProvider.notifier).state = null;
    ref.read(userProvider.notifier).state = null;
  }

  /// ✅ Restore session from SharedPreferences
  Future<void> restoreSessionIfAny() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      ref.read(tokenProvider.notifier).state = token;
      // You can also fetch user profile here if needed
    }
  }

  /// ✅ Private method to navigate to appropriate screen
  void _navigateBasedOnRole(String role, BuildContext context) {
    Widget screen;
    switch (role) {
      case 'admin':
        screen = const AdminHomeScreen();
        break;
      case 'superadmin':
        screen = const SuperAdminHomeScreen();
        break;
      case 'user':
      default:
        screen = const UserHomeScreen();
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => screen),
      (route) => false,
    );
  }
}
