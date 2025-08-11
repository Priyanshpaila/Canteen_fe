// ignore_for_file: use_build_context_synchronously, deprecated_member_use, unused_local_variable

import 'dart:convert';
import 'package:canteen_fe/controllers/auth_controller.dart';
import 'package:canteen_fe/core/constants/api_endpoints.dart';
import 'package:canteen_fe/providers/meta_provider.dart';
import 'package:canteen_fe/providers/token_provider.dart';
import 'package:canteen_fe/views/auth/login_screen.dart';
import 'package:canteen_fe/views/meta/meta_mnagement_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

// ===== APIs =====
// const String updateUserRoleUrl = '$userUrl/update-role';
// String deleteUserUrl(String userId) => '$userUrl/$userId';
// const String getAllUserUrl = '$userUrl/all-user';

class SuperAdminHomeScreen extends ConsumerWidget {
  const SuperAdminHomeScreen({super.key});

  // Palette (matches login/signup)
  static const _brandPrimary = Color(0xFF4F46E5); // Indigo 600
  static const _brandPrimaryDark = Color(0xFF4338CA); // Indigo 700
  static const _pageBg = Color(0xFFF6F7FB); // very light slate
  static const _cardBg = Colors.white;

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Logout'),
              ),
            ],
          ),
    );

    if (shouldLogout == true) {
      await ref.read(authControllerProvider).logout();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _openMeta(BuildContext context, String type) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MetaManagementScreen(type: type)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: _pageBg,
      appBar: _AppBarFriendly(onLogout: () => _confirmLogout(context, ref)),
      body: SafeArea(
        child: Stack(
          children: [
            // Soft background blobs
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

            CustomScrollView(
              slivers: [
                // Header / Profile section (neumorphic card)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: _NeumorphicCard(
                      background: _cardBg,
                      child: _HeaderStrip(),
                    ),
                  ),
                ),

                // Quick stats (display-only)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            Consumer(
                              builder: (context, ref, _) {
                                final divisions = ref.watch(
                                  divisionCountProvider,
                                );
                                return _StatTile(
                                  title: 'Divisions',
                                  value: divisions.when(
                                    data: (count) => count.toString(),
                                    loading: () => '...',
                                    error: (_, __) => 'Err',
                                  ),
                                  icon: Icons.business_rounded,
                                  color: const Color(0xFFEFF6FF),
                                );
                              },
                            ),
                            Consumer(
                              builder: (context, ref, _) {
                                final departments = ref.watch(
                                  departmentCountProvider,
                                );
                                return _StatTile(
                                  title: 'Departments',
                                  value: departments.when(
                                    data: (count) => count.toString(),
                                    loading: () => '...',
                                    error: (_, __) => 'Err',
                                  ),
                                  icon: Icons.account_tree_rounded,
                                  color: const Color(0xFFEFF6FF),
                                );
                              },
                            ),
                            Consumer(
                              builder: (context, ref, _) {
                                final designations = ref.watch(
                                  designationCountProvider,
                                );
                                return _StatTile(
                                  title: 'Designations',
                                  value: designations.when(
                                    data: (count) => count.toString(),
                                    loading: () => '...',
                                    error: (_, __) => 'Err',
                                  ),
                                  icon: Icons.work_outline_rounded,
                                  color: const Color(0xFFEFF6FF),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                // Manage Metadata
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'Manage Metadata',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF1F2937),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverLayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.crossAxisExtent;
                      final crossAxisCount =
                          width > 1000
                              ? 4
                              : width > 760
                              ? 3
                              : 2;
                      return SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.15,
                        ),
                        delegate: SliverChildListDelegate.fixed([
                          _ActionCard(
                            icon: Icons.business_rounded,
                            title: 'Divisions',
                            subtitle: 'Create, rename, remove',
                            onTap: () => _openMeta(context, 'division'),
                          ),
                          _ActionCard(
                            icon: Icons.account_tree_rounded,
                            title: 'Departments',
                            subtitle: 'Create, rename, remove',
                            onTap: () => _openMeta(context, 'department'),
                          ),
                          _ActionCard(
                            icon: Icons.work_outline_rounded,
                            title: 'Designations',
                            subtitle: 'Create, rename, remove',
                            onTap: () => _openMeta(context, 'designation'),
                          ),
                        ]),
                      );
                    },
                  ),
                ),

                // User Administration
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: _UserAdminCard(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Friendly AppBar (avatar + subtitle + single logout action)
class _AppBarFriendly extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onLogout;
  const _AppBarFriendly({required this.onLogout});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: SuperAdminHomeScreen._pageBg,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 16,
      title: Row(
        children: [
          // Avatar bubble
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  SuperAdminHomeScreen._brandPrimary,
                  SuperAdminHomeScreen._brandPrimaryDark,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: SuperAdminHomeScreen._brandPrimary.withOpacity(0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.security_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SuperAdmin Dashboard',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Manage metadata & users',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Logout',
          icon: const Icon(Icons.logout_rounded, color: Color(0xFF0F172A)),
          onPressed: onLogout,
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

/// Header strip card
class _HeaderStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.verified_user_rounded, color: Color(0xFF4F46E5)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Welcome, Super Admin',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        const _RoleChip(label: 'Full Access'),
        const SizedBox(width: 8),
        const _RoleChip(label: 'Protected Routes'),
      ],
    );
  }
}

/// User Administration Card — Select User (bottom sheet), Update Role (dropdown), Delete User
class _UserAdminCard extends ConsumerStatefulWidget {
  @override
  ConsumerState<_UserAdminCard> createState() => _UserAdminCardState();
}

class _UserAdminCardState extends ConsumerState<_UserAdminCard> {
  static const _brandPrimary = SuperAdminHomeScreen._brandPrimary;
  static const _brandPrimaryDark = SuperAdminHomeScreen._brandPrimaryDark;
  static const _inputFill = Color(0xFFF9FAFB);

  Map<String, dynamic>? _selectedUser;
  String? _selectedRole; // user/admin only
  bool _loadingUsers = false;
  bool _updating = false;
  bool _deleting = false;
  List<Map<String, dynamic>> _users = [];

  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _clearSelectionAndRefresh() async {
    setState(() {
      _selectedUser = null;
      _selectedRole = null;
    });
    await _fetchUsers(); // pull fresh list so UI reflects changes
  }

  Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  void _toast(BuildContext ctx, String msg) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _fetchUsers() async {
    setState(() => _loadingUsers = true);
    try {
      final token = ref.read(tokenProvider);
      final res = await http.get(
        Uri.parse(getAllUserUrl),
        headers: _headers(token!),
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        // ✅ API returns {"count": X, "users": [ ... ]}
        final list =
            (data['users'] as List)
                .map<Map<String, dynamic>>(
                  (e) => Map<String, dynamic>.from(e as Map),
                )
                .toList();
        setState(() => _users = list);
      } else {
        _toast(context, 'Failed to load users');
      }
    } catch (_) {
      _toast(context, 'Failed to load users');
    } finally {
      setState(() => _loadingUsers = false);
    }
  }

  Future<void> _openUserPicker() async {
    if (_users.isEmpty && !_loadingUsers) {
      await _fetchUsers();
    }
    final picked = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _UserPickerSheet(
          users: _users,
          loading: _loadingUsers,
          onRefresh: _fetchUsers,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedUser = picked;
        // preset role dropdown – exclude superadmin from options
        final current = (picked['canteenRole'] ?? '').toString().toLowerCase();
        if (current == 'superadmin') {
          _selectedRole = null; // we will block actions on superadmin
        } else if (current == 'admin' || current == 'user') {
          _selectedRole = current;
        } else {
          _selectedRole = 'user';
        }
      });
    }
  }

  Future<void> _updateRole() async {
    if (_selectedUser == null || _selectedRole == null) {
      _toast(context, 'Select a user and a role');
      return;
    }
    final userId = (_selectedUser!['_id'] ?? '').toString();
    final currentRole =
        (_selectedUser!['canteenRole'] ?? '').toString().toLowerCase();
    if (currentRole == 'superadmin') {
      _toast(context, 'Cannot change role of a superadmin');
      return;
    }

    setState(() => _updating = true);
    try {
      final token = ref.read(tokenProvider);
      final res = await http.patch(
        Uri.parse(updateUserRoleUrl),
        headers: _headers(token!),
        body: jsonEncode({'userId': userId, 'newRole': _selectedRole}),
      );
      if (res.statusCode == 200) {
        _toast(context, 'Role updated');
        _clearSelectionAndRefresh(); // ✅ clear & refresh so the card hides
      } else {
        _toast(context, 'Failed to update role');
      }
    } catch (_) {
      _toast(context, 'Failed to update role');
    } finally {
      setState(() => _updating = false);
    }
  }

  Future<void> _deleteUser() async {
    if (_selectedUser == null) {
      _toast(context, 'Select a user first');
      return;
    }
    final userId = (_selectedUser!['_id'] ?? '').toString();
    final currentRole =
        (_selectedUser!['canteenRole'] ?? '').toString().toLowerCase();
    if (currentRole == 'superadmin') {
      _toast(context, 'Superadmin cannot be deleted');
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Delete User'),
            content: Text(
              'Are you sure you want to delete "${_displayName(_selectedUser!)}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
    if (ok != true) return;

    setState(() => _deleting = true);
    try {
      final token = ref.read(tokenProvider);
      final res = await http.delete(
        Uri.parse(deleteUserUrl(userId)),
        headers: _headers(token!),
      );
      if (res.statusCode == 200) {
        _toast(context, 'User deleted');
        _clearSelectionAndRefresh();
        setState(() {
          _selectedUser = null;
          _selectedRole = null;
        });
        await _fetchUsers();
      } else {
        _toast(context, 'Failed to delete user');
      }
    } catch (_) {
      _toast(context, 'Failed to delete user');
    } finally {
      setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 880;
    final isSuperadminSelected =
        (_selectedUser?['canteenRole'] ?? '').toString().toLowerCase() ==
        'superadmin';

    final roleOptions = const ['user', 'admin']; // no 'superadmin' here

    return _NeumorphicCard(
      background: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Container(
                height: 44,
                width: 44,
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
                      offset: const Offset(0, 8),
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.manage_accounts_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'User Administration',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _openUserPicker,
                icon: const Icon(Icons.person_search_rounded),
                label: const Text('Select User'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Selected user chip / info
          if (_selectedUser != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5FF),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFFEFF6FF),
                    child: const Icon(Icons.person, color: _brandPrimary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _displayName(_selectedUser!),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Current role: ${(_selectedUser!['canteenRole'] ?? '').toString()}',
                          style: const TextStyle(color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  if (isSuperadminSelected) const _ProtectedPill(),
                ],
              ),
            ),

          if (_selectedUser != null) const SizedBox(height: 16),

          // Responsive forms: role change & delete
          if (_selectedUser != null)
            (isWide)
                ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _RoleForm(
                        enabled: !isSuperadminSelected,
                        selectedRole: _selectedRole,
                        onRoleChanged: (r) => setState(() => _selectedRole = r),
                        onSubmit: _updating ? null : _updateRole,
                        busy: _updating,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _DeleteForm(
                        enabled: !isSuperadminSelected,
                        onSubmit: _deleting ? null : _deleteUser,
                        busy: _deleting,
                      ),
                    ),
                  ],
                )
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _RoleForm(
                      enabled: !isSuperadminSelected,
                      selectedRole: _selectedRole,
                      onRoleChanged: (r) => setState(() => _selectedRole = r),
                      onSubmit: _updating ? null : _updateRole,
                      busy: _updating,
                    ),
                    const SizedBox(height: 16),
                    _DeleteForm(
                      enabled: !isSuperadminSelected,
                      onSubmit: _deleting ? null : _deleteUser,
                      busy: _deleting,
                    ),
                  ],
                )
          else
            // Empty-state prompt when no user selected
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Color(0xFF64748B)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Select a user to update their role or delete the account.',
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _displayName(Map<String, dynamic> u) {
    return (u['fullName'] ??
            u['name'] ??
            u['phoneNumber'] ??
            u['phone'] ??
            'Unknown')
        .toString();
  }
}

/// Role change form (dropdown)
class _RoleForm extends StatelessWidget {
  final bool enabled;
  final String? selectedRole;
  final ValueChanged<String?> onRoleChanged;
  final VoidCallback? onSubmit;
  final bool busy;

  const _RoleForm({
    required this.enabled,
    required this.selectedRole,
    required this.onRoleChanged,
    required this.onSubmit,
    required this.busy,
  });

  static const roles = ['user', 'admin']; // Explicitly exclude superadmin

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Update User Role',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        InputDecorator(
          decoration: _inputDecoration(
            hint: 'Select role',
            icon: Icons.workspace_premium_rounded,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedRole,
              isExpanded: true,
              hint: const Text('Select role'),
              items:
                  roles
                      .map(
                        (r) => DropdownMenuItem<String>(
                          value: r,
                          child: Text(r.toUpperCase()),
                        ),
                      )
                      .toList(),
              onChanged: enabled ? onRoleChanged : null,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: enabled ? onSubmit : null,
            icon: const Icon(Icons.upgrade_rounded),
            label:
                busy
                    ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 2),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                    : const Text('Update Role'),
            style: ElevatedButton.styleFrom(
              backgroundColor: SuperAdminHomeScreen._brandPrimary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF94A3B8)),
      filled: true,
      fillColor: _UserAdminCardState._inputFill,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: SuperAdminHomeScreen._brandPrimary,
          width: 1.4,
        ),
      ),
    );
  }
}

/// Delete user form
class _DeleteForm extends StatelessWidget {
  final bool enabled;
  final VoidCallback? onSubmit;
  final bool busy;

  const _DeleteForm({
    required this.enabled,
    required this.onSubmit,
    required this.busy,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Delete User',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: enabled ? onSubmit : null,
            icon: const Icon(Icons.delete_forever_rounded),
            label:
                busy
                    ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 2),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                    : const Text('Delete User'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        if (!enabled)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Superadmin accounts are protected.',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ),
      ],
    );
  }
}

/// Pretty “protected” pill shown when a superadmin is selected
class _ProtectedPill extends StatelessWidget {
  const _ProtectedPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.redAccent.withOpacity(0.25)),
      ),
      child: const Text(
        'Protected',
        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Searchable bottom sheet for users
class _UserPickerSheet extends StatefulWidget {
  final List<Map<String, dynamic>> users;
  final bool loading;
  final Future<void> Function() onRefresh;

  const _UserPickerSheet({
    required this.users,
    required this.loading,
    required this.onRefresh,
  });

  @override
  State<_UserPickerSheet> createState() => _UserPickerSheetState();
}

class _UserPickerSheetState extends State<_UserPickerSheet> {
  static const brandPrimary = SuperAdminHomeScreen._brandPrimary;
  static const brandPrimaryDark = SuperAdminHomeScreen._brandPrimaryDark;
  static const cardBg = Colors.white;
  static const inputFill = Color(0xFFF9FAFB);

  final TextEditingController searchCtrl = TextEditingController();
  late List<Map<String, dynamic>> filtered;

  @override
  void initState() {
    super.initState();
    filtered = List.of(widget.users);
    searchCtrl.addListener(_applyFilter);
  }

  @override
  void dispose() {
    searchCtrl.removeListener(_applyFilter);
    searchCtrl.dispose();
    super.dispose();
  }

  void _applyFilter() {
    final q = searchCtrl.text.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        filtered = List.of(widget.users);
      } else {
        filtered =
            widget.users.where((e) {
              final name =
                  (e['fullName'] ??
                          e['name'] ??
                          e['phoneNumber'] ??
                          e['phone'] ??
                          '')
                      .toString()
                      .toLowerCase();
              final role = (e['canteenRole'] ?? '').toString().toLowerCase();
              return name.contains(q) || role.contains(q);
            }).toList();
      }
    });
  }

  String _displayName(Map<String, dynamic> u) {
    return (u['fullName'] ??
            u['name'] ??
            u['phoneNumber'] ??
            u['phone'] ??
            'Unknown')
        .toString();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 12,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Container(
                decoration: BoxDecoration(
                  color: cardBg,
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
                child: DraggableScrollableSheet(
                  initialChildSize: 0.6,
                  minChildSize: 0.4,
                  maxChildSize: 0.95,
                  expand: false,
                  builder: (context, controller) {
                    return Column(
                      children: [
                        const SizedBox(height: 8),
                        Container(
                          width: 42,
                          height: 5,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5E7EB),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Header
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [brandPrimary, brandPrimaryDark],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: brandPrimary.withOpacity(0.28),
                                      offset: const Offset(0, 8),
                                      blurRadius: 18,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.person_search_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Select User',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: "Close",
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Search bar
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextField(
                            controller: searchCtrl,
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              hintText: 'Search name / role',
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                color: Color(0xFF94A3B8),
                              ),
                              filled: true,
                              fillColor: inputFill,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE5E7EB),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE5E7EB),
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(14),
                                ),
                                borderSide: BorderSide(
                                  color: brandPrimary,
                                  width: 1.4,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        Expanded(
                          child:
                              widget.loading
                                  ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                  : RefreshIndicator(
                                    onRefresh: widget.onRefresh,
                                    child:
                                        filtered.isEmpty
                                            ? const _EmptyUsers()
                                            : ListView.separated(
                                              controller: controller,
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                    12,
                                                    8,
                                                    12,
                                                    16,
                                                  ),
                                              itemBuilder: (_, i) {
                                                final u = filtered[i];
                                                final name = _displayName(u);
                                                final role =
                                                    (u['canteenRole'] ?? '')
                                                        .toString();
                                                final isSuper =
                                                    role.toLowerCase() ==
                                                    'superadmin';
                                                return Card(
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          14,
                                                        ),
                                                    side: const BorderSide(
                                                      color: Color(0xFFE5E7EB),
                                                    ),
                                                  ),
                                                  child: ListTile(
                                                    leading: CircleAvatar(
                                                      backgroundColor:
                                                          const Color(
                                                            0xFFEFF6FF,
                                                          ),
                                                      child: Icon(
                                                        isSuper
                                                            ? Icons.verified
                                                            : Icons.person,
                                                        color: brandPrimary,
                                                      ),
                                                    ),
                                                    title: Text(
                                                      name,
                                                      style: const TextStyle(
                                                        color: Color(
                                                          0xFF0F172A,
                                                        ),
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    subtitle: Text(
                                                      'Role: $role',
                                                    ),
                                                    trailing: const Icon(
                                                      Icons
                                                          .chevron_right_rounded,
                                                      color: Color(0xFF94A3B8),
                                                    ),
                                                    onTap:
                                                        () => Navigator.pop(
                                                          context,
                                                          u,
                                                        ),
                                                  ),
                                                );
                                              },
                                              separatorBuilder:
                                                  (_, __) =>
                                                      const SizedBox(height: 8),
                                              itemCount: filtered.length,
                                            ),
                                  ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyUsers extends StatelessWidget {
  const _EmptyUsers();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          'No users found.',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
      ),
    );
  }
}

/// ---------- Neumorphic Card Wrapper ----------
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: child,
    );
  }
}

/// ---------- Role Chip ----------
class _RoleChip extends StatelessWidget {
  final String label;
  const _RoleChip({required this.label});

  @override
  Widget build(BuildContext context) {
    const color = SuperAdminHomeScreen._brandPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        label,
        style: const TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// ---------- Stat Tile (display-only) ----------
class _StatTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final onColor =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark
            ? Colors.white
            : const Color(0xFF0F172A);

    return Container(
      width: 320,
      constraints: const BoxConstraints(minWidth: 240),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: onColor.withOpacity(0.08),
            child: Icon(icon, color: onColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: onColor.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: onColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------- Action Card ----------
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFEFF6FF),
                  child: Icon(icon, color: SuperAdminHomeScreen._brandPrimary),
                ),
                const Spacer(),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Shared blur blob
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
