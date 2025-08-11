// ignore_for_file: use_build_context_synchronously, unused_local_variable, deprecated_member_use

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

  final _phoneFocus = FocusNode();
  final _pinFocus = FocusNode();

  List<Map<String, dynamic>> divisions = [];
  List<Map<String, dynamic>> departments = [];
  List<Map<String, dynamic>> designations = [];

  Map<String, dynamic>? selectedDivision;
  Map<String, dynamic>? selectedDepartment;
  Map<String, dynamic>? selectedDesignation;

  bool loading = false;
  bool isPinObscured = true;

  // --- Palette (same as Login) ---
  static const _brandPrimary = Color(0xFF4F46E5); // Indigo 600
  static const _brandPrimaryDark = Color(0xFF4338CA); // Indigo 700
  static const _pageBg = Color(0xFFF6F7FB); // very light slate
  static const _cardBg = Colors.white;
  static const _inputFill = Color(0xFFF9FAFB);

  @override
  void initState() {
    super.initState();
    fetchMetaLists();
  }

  @override
  void dispose() {
    phoneController.dispose();
    pinController.dispose();
    empidController.dispose();
    fullNameController.dispose();
    _phoneFocus.dispose();
    _pinFocus.dispose();
    super.dispose();
  }

  /// Robustly parse meta list responses that can be either:
  /// - List<dynamic>
  /// - { count: number, items: List<dynamic> }
  List<Map<String, dynamic>> _parseMetaList(String body) {
    final decoded = jsonDecode(body);
    final List raw =
        decoded is List
            ? decoded
            : (decoded is Map && decoded['items'] is List)
            ? decoded['items'] as List
            : const [];
    return raw
        .whereType<Map>() // keep only map items
        .map(
          (e) => {
            'id': e['_id']?.toString() ?? '',
            'name': e['name']?.toString() ?? '',
          },
        )
        .where((e) => e['id']!.isNotEmpty && e['name']!.isNotEmpty)
        .toList();
  }

  Future<void> fetchMetaLists() async {
    try {
      final dRes = await http.get(Uri.parse(getAllDivisionsUrl));
      final depRes = await http.get(Uri.parse(getAllDepartmentsUrl));
      final desigRes = await http.get(Uri.parse(getAllDesignationsUrl));

      if (dRes.statusCode == 200 &&
          depRes.statusCode == 200 &&
          desigRes.statusCode == 200) {
        final parsedDiv = _parseMetaList(dRes.body);
        final parsedDep = _parseMetaList(depRes.body);
        final parsedDes = _parseMetaList(desigRes.body);

        setState(() {
          divisions = parsedDiv;
          departments = parsedDep;
          designations = parsedDes;
        });
      } else {
        debugPrint(
          'Meta fetch failed: div=${dRes.statusCode}, dep=${depRes.statusCode}, des=${desigRes.statusCode}',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load metadata')),
        );
      }
    } catch (e) {
      debugPrint("Meta fetch error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to load metadata')));
    }
  }

  Future<void> handleSignup() async {
    if (phoneController.text.trim().length != 10 ||
        pinController.text.trim().length != 6 ||
        fullNameController.text.trim().isEmpty ||
        empidController.text.trim().isEmpty ||
        selectedDivision == null ||
        selectedDepartment == null ||
        selectedDesignation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please complete all fields (Phone: 10 digits, PIN: 6)',
          ),
        ),
      );
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
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 700;

    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppBar(
        backgroundColor: _pageBg,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Create Account",
          style: TextStyle(color: Color(0xFF0F172A)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -120,
                right: -80,
                child: _blurBlob(const Color(0xFFEEF2FF)),
              ),
              Positioned(
                bottom: -140,
                left: -100,
                child: _blurBlob(const Color(0xFFE0E7FF)),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 32 : 20,
                    vertical: 24,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: _NeumorphicCard(
                      background: _cardBg,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Brand mark
                          Container(
                            height: 72,
                            width: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [_brandPrimary, _brandPrimaryDark],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _brandPrimary.withOpacity(0.28),
                                  offset: const Offset(0, 10),
                                  blurRadius: 22,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person_add_alt_1_rounded,
                              color: Colors.white,
                              size: 34,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Welcome! Let’s get you started",
                            textAlign: TextAlign.center,
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Fill in your details below to create your account",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: const Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 24),

                          // Phone
                          _LabeledField(
                            label: "Phone Number",
                            child: TextField(
                              focusNode: _phoneFocus,
                              controller: phoneController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              onSubmitted: (_) => _pinFocus.requestFocus(),
                              decoration: _inputDecoration(
                                context,
                                hint: "Enter 10-digit phone number",
                                icon: Icons.phone_rounded,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // PIN
                          _LabeledField(
                            label: "PIN",
                            child: TextField(
                              focusNode: _pinFocus,
                              controller: pinController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              obscureText: isPinObscured,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(6),
                              ],
                              decoration: _inputDecoration(
                                context,
                                hint: "6-digit PIN",
                                icon: Icons.lock_rounded,
                                suffix: IconButton(
                                  splashRadius: 20,
                                  icon: Icon(
                                    isPinObscured
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                  onPressed:
                                      () => setState(
                                        () => isPinObscured = !isPinObscured,
                                      ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Employee ID
                          _LabeledField(
                            label: "Employee ID",
                            child: TextField(
                              controller: empidController,
                              textInputAction: TextInputAction.next,
                              decoration: _inputDecoration(
                                context,
                                hint: "Enter employee ID",
                                icon: Icons.badge_rounded,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Full Name
                          _LabeledField(
                            label: "Full Name",
                            child: TextField(
                              controller: fullNameController,
                              textInputAction: TextInputAction.next,
                              decoration: _inputDecoration(
                                context,
                                hint: "Enter your full name",
                                icon: Icons.person_rounded,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Division
                          _MetaSelectorTile(
                            title: "Division",
                            current: selectedDivision?['name'],
                            icon: Icons.apartment_rounded,
                            onTap: () async {
                              final result = await showSearchableBottomSheet(
                                context,
                                divisions
                                    .map((e) => e['name'].toString())
                                    .toList(),
                                'Division',
                                icon: Icons.apartment_rounded,
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
                          const SizedBox(height: 12),

                          // Department
                          _MetaSelectorTile(
                            title: "Department",
                            current: selectedDepartment?['name'],
                            icon: Icons.account_tree_rounded,
                            onTap: () async {
                              final result = await showSearchableBottomSheet(
                                context,
                                departments
                                    .map((e) => e['name'].toString())
                                    .toList(),
                                'Department',
                                icon: Icons.account_tree_rounded,
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
                          const SizedBox(height: 12),

                          // Designation
                          _MetaSelectorTile(
                            title: "Designation",
                            current: selectedDesignation?['name'],
                            icon: Icons.work_outline_rounded,
                            onTap: () async {
                              final result = await showSearchableBottomSheet(
                                context,
                                designations
                                    .map((e) => e['name'].toString())
                                    .toList(),
                                'Designation',
                                icon: Icons.work_outline_rounded,
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

                          const SizedBox(height: 22),

                          // Signup button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: loading ? null : handleSignup,
                              icon: const Icon(Icons.person_add_alt_1_rounded),
                              label:
                                  loading
                                      ? const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 2,
                                        ),
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      )
                                      : const Text("Create Account"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _brandPrimary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Input decoration matching login
  InputDecoration _inputDecoration(
    BuildContext context, {
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF94A3B8)),
      suffixIcon: suffix,
      filled: true,
      fillColor: _inputFill,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)), // gray-200
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _brandPrimary, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  // Subtle blurred blob
  Widget _blurBlob(Color color) {
    return Container(
      width: 260,
      height: 260,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.6),
            blurRadius: 90,
            spreadRadius: 20,
          ),
        ],
      ),
    );
  }
}

// Soft, elegant card (same as login)
class _NeumorphicCard extends StatelessWidget {
  final Widget child;
  final Color background;

  const _NeumorphicCard({required this.child, this.background = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 28,
            offset: Offset(0, 16),
          ),
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
      child: child,
    );
  }
}

// Label above field for pro form look
class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: const Color(0xFF475569), // slate-600
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

// Styled meta selector tile (Division/Department/Designation)
class _MetaSelectorTile extends StatelessWidget {
  final String title;
  final String? current;
  final IconData icon;
  final VoidCallback onTap;

  const _MetaSelectorTile({
    required this.title,
    required this.current,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = current ?? "Select $title";
    return Material(
      color: _SignupScreenState._inputFill,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(icon, color: const Color(0xFF94A3B8)),
            title: Text(
              text,
              style: TextStyle(
                color:
                    current == null
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF0F172A),
                fontWeight: current == null ? FontWeight.w400 : FontWeight.w600,
              ),
            ),
            trailing: const Icon(
              Icons.arrow_drop_down_rounded,
              color: Color(0xFF94A3B8),
            ),
          ),
        ),
      ),
    );
  }
}
