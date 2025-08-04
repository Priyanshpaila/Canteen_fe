import 'package:canteen_fe/controllers/auth_controller.dart';
import 'package:canteen_fe/views/auth/login_screen.dart';
import 'package:canteen_fe/views/home/admin_home_screen.dart';
import 'package:canteen_fe/views/home/super_admin_home_screen.dart';
import 'package:canteen_fe/views/home/user_home_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:canteen_fe/providers/token_provider.dart';
import 'package:canteen_fe/providers/user_provider.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    restoreSession();
  }

  Future<void> restoreSession() async {
    await ref.read(authControllerProvider).restoreSessionIfAny();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final token = ref.watch(tokenProvider);
    final user = ref.watch(userProvider);

    Widget startScreen;

    if (isLoading) {
      startScreen = const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else if (token != null && user != null) {
      // Navigate based on role
      switch (user.canteenRole) {
        case 'user':
          startScreen = const UserHomeScreen();
          break;
        case 'admin':
          startScreen = const AdminHomeScreen();
          break;
        case 'superadmin':
          startScreen = const SuperAdminHomeScreen();
          break;
        default:
          startScreen = const LoginScreen();
      }
    } else {
      startScreen = const LoginScreen();
    }

    return MaterialApp(
      title: 'Canteen App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: startScreen,
    );
  }
}
