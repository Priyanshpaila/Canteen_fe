// ignore_for_file: use_build_context_synchronously

import 'package:canteen_fe/controllers/auth_controller.dart';
import 'package:canteen_fe/views/auth/login_screen.dart';
import 'package:canteen_fe/views/meta/meta_mnagement_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SuperAdminHomeScreen extends ConsumerWidget {
  const SuperAdminHomeScreen({super.key});

  void _logout(BuildContext context, WidgetRef ref) async {
    await ref.read(authControllerProvider).logout();

    // Clear navigation stack and go to LoginScreen directly
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SuperAdmin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCard(
            context,
            icon: Icons.business,
            title: 'Divisions',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MetaManagementScreen(type: 'division'),
                ),
              );
            },
          ),
          _buildCard(
            context,
            icon: Icons.account_tree_outlined,
            title: 'Departments',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => const MetaManagementScreen(type: 'department'),
                ),
              );
            },
          ),
          _buildCard(
            context,
            icon: Icons.work_outline,
            title: 'Designations',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => const MetaManagementScreen(type: 'designation'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, size: 28),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
