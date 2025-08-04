// ignore_for_file: curly_braces_in_flow_control_structures, use_build_context_synchronously, avoid_print

import 'dart:convert';
import 'package:canteen_fe/controllers/auth_controller.dart';
import 'package:canteen_fe/core/constants/api_endpoints.dart';
import 'package:canteen_fe/widgets/searchable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final phoneController = TextEditingController();
  final pinController = TextEditingController();
  final empidController = TextEditingController();
  final fullNameController = TextEditingController();

  List<String> divisions = [];
  List<String> departments = [];
  List<String> designations = [];

  String? selectedDivision;
  String? selectedDepartment;
  String? selectedDesignation;

  bool loading = false;

  @override
  void initState() {
    super.initState();
    fetchMetaLists();
  }

  Future<void> fetchMetaLists() async {
    try {
      final dRes = await http.get(Uri.parse(getAllDivisionsUrl));
      final depRes = await http.get(Uri.parse(getAllDepartmentsUrl));
      final desigRes = await http.get(Uri.parse(getAllDesignationsUrl));

      if (dRes.statusCode == 200 &&
          depRes.statusCode == 200 &&
          desigRes.statusCode == 200) {
        setState(() {
          divisions = List<String>.from(
            jsonDecode(dRes.body).map((e) => e['name']),
          );
          departments = List<String>.from(
            jsonDecode(depRes.body).map((e) => e['name']),
          );
          designations = List<String>.from(
            jsonDecode(desigRes.body).map((e) => e['name']),
          );
        });
      }
    } catch (e) {
      print("Meta fetch error: $e");
    }
  }

  Future<void> handleSignup() async {
    if (selectedDivision == null ||
        selectedDepartment == null ||
        selectedDesignation == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select all fields')));
      return;
    }

    setState(() => loading = true);

    final error = await ref
        .read(authControllerProvider)
        .signupAndLogin(
          phoneNumber: phoneController.text.trim(),
          pin: pinController.text.trim(),
          empid: empidController.text.trim(),
          fullName: fullNameController.text.trim(),
          division: selectedDivision!,
          department: selectedDepartment!,
          designation: selectedDesignation!,
          context: context,
        );

    setState(() => loading = false);

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Signup")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            TextField(
              controller: pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'PIN'),
            ),
            TextField(
              controller: empidController,
              decoration: const InputDecoration(labelText: 'Emp ID'),
            ),
            TextField(
              controller: fullNameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: 12),
            ListTile(
              title: Text(selectedDivision ?? 'Select Division'),
              trailing: const Icon(Icons.arrow_drop_down),
              onTap: () async {
                final result = await showSearchableBottomSheet(
                  context,
                  divisions,
                  'Division',
                );
                if (result != null) setState(() => selectedDivision = result);
              },
            ),
            ListTile(
              title: Text(selectedDepartment ?? 'Select Department'),
              trailing: const Icon(Icons.arrow_drop_down),
              onTap: () async {
                final result = await showSearchableBottomSheet(
                  context,
                  departments,
                  'Department',
                );
                if (result != null) setState(() => selectedDepartment = result);
              },
            ),
            ListTile(
              title: Text(selectedDesignation ?? 'Select Designation'),
              trailing: const Icon(Icons.arrow_drop_down),
              onTap: () async {
                final result = await showSearchableBottomSheet(
                  context,
                  designations,
                  'Designation',
                );
                if (result != null)
                  setState(() => selectedDesignation = result);
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : handleSignup,
              child:
                  loading
                      ? const CircularProgressIndicator()
                      : const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
