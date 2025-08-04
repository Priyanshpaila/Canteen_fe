import 'package:flutter/material.dart';

class SuperAdminHomeScreen extends StatelessWidget {
  const SuperAdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SuperAdmin Dashboard')),
      body: const Center(child: Text('Welcome SuperAdmin')),
    );
  }
}
