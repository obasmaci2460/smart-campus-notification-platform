import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../models/simple_user.dart';
import '../widgets/custom_switch.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<SimpleUser> _users = [];
  List<SimpleUser> _filteredUsers = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    _users = [
      SimpleUser(
        id: 1,
        email: 'ahmet.yilmaz@example.com',
        firstName: 'Ahmet',
        lastName: 'Yılmaz',
        departmentId: 1,
        role: 'user',
        isSuperAdmin: false,
      ),
      SimpleUser(
        id: 2,
        email: 'ayse.kaya@example.com',
        firstName: 'Ayşe',
        lastName: 'Kaya',
        departmentId: 2,
        role: 'admin',
        isSuperAdmin: false,
      ),
      SimpleUser(
        id: 3,
        email: 'mehmet.demir@example.com',
        firstName: 'Mehmet',
        lastName: 'Demir',
        departmentId: 1,
        role: 'admin',
        isSuperAdmin: true,
      ),
    ];

    setState(() {
      _filteredUsers = _users;
      _isLoading = false;
    });
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredUsers = _users;
      } else {
        _filteredUsers =
            _users.where((user) {
              final fullName =
                  '${user.firstName} ${user.lastName}'.toLowerCase();
              final email = user.email.toLowerCase();
              return fullName.contains(query) || email.contains(query);
            }).toList();
      }
    });
  }

  Future<void> _toggleAdminRole(SimpleUser user) async {
    final newRole = user.role == 'admin' ? 'user' : 'admin';

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      final index = _users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        _users[index] = SimpleUser(
          id: user.id,
          email: user.email,
          firstName: user.firstName,
          lastName: user.lastName,
          departmentId: user.departmentId,
          role: newRole,
          isSuperAdmin: user.isSuperAdmin,
        );
      }
      _filterUsers();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newRole == 'admin'
                ? 'Kullanıcı admin yapıldı'
                : 'Admin yetkisi kaldırıldı',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Kullanıcı Yönetimi',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'İsim veya e-posta ara...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                ),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredUsers.isEmpty
                    ? const Center(
                      child: Text(
                        'Kullanıcı bulunamadı',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                    : ListView.builder(
                      itemCount: _filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = _filteredUsers[index];
                        return _buildUserCard(user);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(SimpleUser user) {
    final initials = '${user.firstName[0]}${user.lastName[0]}'.toUpperCase();
    final avatarColor = _getAvatarColor(user.id);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.neutral200)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: avatarColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: AppFontWeights.semibold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${user.firstName} ${user.lastName}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: AppFontWeights.semibold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  user.email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  _getDepartmentName(user.departmentId),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (user.isSuperAdmin)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                'Super Admin',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: AppFontWeights.semibold,
                  color: AppColors.primary,
                ),
              ),
            )
          else
            CustomSwitch(
              value: user.role == 'admin',
              onChanged: (value) => _toggleAdminRole(user),
            ),
        ],
      ),
    );
  }

  Color _getAvatarColor(int userId) {
    final colors = [
      AppColors.primary,
      AppColors.success,
      AppColors.warning,
      AppColors.error,
      const Color(0xFF8B5CF6),
      const Color(0xFF06B6D4),
    ];
    return colors[userId % colors.length];
  }

  String _getDepartmentName(int departmentId) {
    switch (departmentId) {
      case 1:
        return 'Bilgisayar Mühendisliği';
      case 2:
        return 'Elektrik-Elektronik Mühendisliği';
      case 3:
        return 'Makine Mühendisliği';
      case 4:
        return 'İnşaat Mühendisliği';
      case 5:
        return 'Endüstri Mühendisliği';
      default:
        return 'Diğer';
    }
  }
}
