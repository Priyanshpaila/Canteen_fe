// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
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

  static const _kTokenKey = 'token';
  static const _kUserKey = 'user'; // stored as JSON string

  /// ✅ Login and persist token/user + navigate by role
  Future<String?> login(String phone, String pin, BuildContext context) async {
    try {
      final result = await _authService.login(phone, pin);
      final token = result['token'] as String;
      final userMap = (result['user'] as Map).cast<String, dynamic>();

      // Build UserModel (works with partial user too)
      final userModel = UserModel.fromJson(userMap);

      // Persist
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kTokenKey, token);
      await prefs.setString(_kUserKey, jsonEncode(userModel.toJson()));

      // Update state
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

      final token = result['token'] as String;
      final userMap = (result['user'] as Map).cast<String, dynamic>();
      final userModel = UserModel.fromJson(userMap);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kTokenKey, token);
      await prefs.setString(_kUserKey, jsonEncode(userModel.toJson()));

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
    await prefs.remove(_kTokenKey);
    await prefs.remove(_kUserKey);
    ref.read(tokenProvider.notifier).state = null;
    ref.read(userProvider.notifier).state = null;
  }

  /// ✅ Restore session from SharedPreferences (token + user)
  Future<void> restoreSessionIfAny() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_kTokenKey);
    final userJson = prefs.getString(_kUserKey);

    if (token != null && userJson != null) {
      try {
        final map = jsonDecode(userJson) as Map<String, dynamic>;
        final userModel = UserModel.fromJson(map);

        ref.read(tokenProvider.notifier).state = token;
        ref.read(userProvider.notifier).state = userModel;
      } catch (e) {
        log('Restore user decode error: $e');
        // Fallback: just set token; user can be fetched later
        ref.read(tokenProvider.notifier).state = token;
        ref.read(userProvider.notifier).state = null;
      }
    } else if (token != null) {
      // Token present but no user cached — optional: fetch profile
      ref.read(tokenProvider.notifier).state = token;
      try {
        final profile = await _authService.getProfile(
          token,
        ); // implement in AuthService
        final userModel = UserModel.fromJson(profile);
        ref.read(userProvider.notifier).state = userModel;
        await prefs.setString(_kUserKey, jsonEncode(userModel.toJson()));
      } catch (e) {
        log('Fetching profile failed: $e');
      }
    } else {
      // nothing to restore
      ref.read(tokenProvider.notifier).state = null;
      ref.read(userProvider.notifier).state = null;
    }
  }

  /// ✅ Update stored user after profile changes
  Future<void> refreshAndPersistProfile() async {
    try {
      // ✅ Get token from Riverpod state
      final token = ref.read(tokenProvider);
      if (token == null) {
        log('refreshAndPersistProfile: No token found');
        return;
      }

      // ✅ Fetch profile from API
      final profile = await _authService.getProfile(
        token,
      ); // expects token param
      final userModel = UserModel.fromJson(profile);

      // ✅ Update state
      ref.read(userProvider.notifier).state = userModel;

      // ✅ Persist updated user
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kUserKey, jsonEncode(userModel.toJson()));
    } catch (e) {
      log('refreshAndPersistProfile error: $e');
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
