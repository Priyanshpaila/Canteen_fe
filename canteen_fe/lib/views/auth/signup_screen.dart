// ignore_for_file: use_build_context_synchronously, unused_local_variable

import 'dart:convert';
import 'package:canteen_fe/controllers/auth_controller.dart';
import 'package:canteen_fe/core/constants/api_endpoints.dart';
import 'package:canteen_fe/widgets/searchable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  List<Map<String, dynamic>> divisions = [];
  List<Map<String, dynamic>> departments = [];
  List<Map<String, dynamic>> designations = [];

  Map<String, dynamic>? selectedDivision;
  Map<String, dynamic>? selectedDepartment;
  Map<String, dynamic>? selectedDesignation;

  bool loading = false;
  bool isPinObscured = true;

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
          divisions = List<Map<String, dynamic>>.from(
            jsonDecode(
              dRes.body,
            ).map((e) => {'id': e['_id'], 'name': e['name']}),
          );
          departments = List<Map<String, dynamic>>.from(
            jsonDecode(
              depRes.body,
            ).map((e) => {'id': e['_id'], 'name': e['name']}),
          );
          designations = List<Map<String, dynamic>>.from(
            jsonDecode(
              desigRes.body,
            ).map((e) => {'id': e['_id'], 'name': e['name']}),
          );
        });
      }
    } catch (e) {
      debugPrint("Meta fetch error: $e");
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
          division: selectedDivision!['id'],
          department: selectedDepartment!['id'],
          designation: selectedDesignation!['id'],
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
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.person_add,
                  size: 60,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: pinController,
                  keyboardType: TextInputType.number,
                  obscureText: isPinObscured,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  decoration: InputDecoration(
                    labelText: '6-digit PIN',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPinObscured ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed:
                          () => setState(() => isPinObscured = !isPinObscured),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: empidController,
                  decoration: const InputDecoration(
                    labelText: 'Employee ID',
                    prefixIcon: Icon(Icons.badge),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),

                /// Division
                buildMetaSelector(
                  context,
                  title: "Select Division",
                  current: selectedDivision?['name'],
                  icon: Icons.apartment,
                  onTap: () async {
                    final result = await showSearchableBottomSheet(
                      context,
                      divisions.map((e) => e['name'].toString()).toList(),
                      'Division',
                    );
                    if (result != null) {
                      setState(() {
                        selectedDivision = divisions.firstWhere(
                          (e) => e['name'] == result,
                        );
                      });
                    }
                  },
                ),

                /// Department
                buildMetaSelector(
                  context,
                  title: "Select Department",
                  current: selectedDepartment?['name'],
                  icon: Icons.account_tree,
                  onTap: () async {
                    final result = await showSearchableBottomSheet(
                      context,
                      departments.map((e) => e['name'].toString()).toList(),
                      'Department',
                    );
                    if (result != null) {
                      setState(() {
                        selectedDepartment = departments.firstWhere(
                          (e) => e['name'] == result,
                        );
                      });
                    }
                  },
                ),

                /// Designation
                buildMetaSelector(
                  context,
                  title: "Select Designation",
                  current: selectedDesignation?['name'],
                  icon: Icons.work_outline,
                  onTap: () async {
                    final result = await showSearchableBottomSheet(
                      context,
                      designations.map((e) => e['name'].toString()).toList(),
                      'Designation',
                    );
                    if (result != null) {
                      setState(() {
                        selectedDesignation = designations.firstWhere(
                          (e) => e['name'] == result,
                        );
                      });
                    }
                  },
                ),

                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: loading ? null : handleSignup,
                  icon: const Icon(Icons.person_add_alt),
                  label:
                      loading
                          ? const Padding(
                            padding: EdgeInsets.all(6),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text("Sign Up"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildMetaSelector(
    BuildContext context, {
    required String title,
    required String? current,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          onTap: onTap,
          leading: Icon(icon),
          title: Text(current ?? title),
          trailing: const Icon(Icons.arrow_drop_down),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Colors.grey),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
