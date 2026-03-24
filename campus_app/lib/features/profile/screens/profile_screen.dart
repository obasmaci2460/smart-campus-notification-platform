import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../widgets/settings_tile.dart';
import 'notification_preferences_screen.dart';
import 'followed_notifications_screen.dart';
import 'account_info_screen.dart';
import 'about_screen.dart';
import '../../admin/screens/admin_dashboard_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  int _departmentId = 0;
  String _role = 'user';
  bool _isSuperAdmin = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    final userId = await StorageService.getUserId();
    if (userId == null) {
      _handleLogout();
      return;
    }

    final response = await ApiService.getUserProfile();

    if (response.success && response.data != null) {
      setState(() {
        _firstName = response.data!['first_name'] ?? '';
        _lastName = response.data!['last_name'] ?? '';
        _email = response.data!['email'] ?? '';
        _departmentId = response.data!['department_id'] ?? 0;
        _role = response.data!['role'] ?? 'user';
        _isSuperAdmin = response.data!['is_super_admin'] ?? false;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Çıkış Yap'),
            content: const Text('Çıkış yapmak istediğinizden emin misiniz?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('İptal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('Çıkış Yap'),
              ),
            ],
          ),
    );

    if (confirm == true && mounted) {
      await StorageService.clearAll();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Profil',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _email.isEmpty
              ? const Center(child: Text('Kullanıcı bilgisi yüklenemedi'))
              : Column(
                children: [
                  _buildProfileHeader(),
                  Expanded(child: _buildSettingsList()),
                ],
              ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.only(
        top: 24,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.neutral200)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFF1F5F9),
                    width: 2.5,
                  ),
                  color: AppColors.primary.withOpacity(0.1),
                ),
                child: Center(
                  child: Text(
                    _getInitials(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: AppFontWeights.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.edit, size: 12, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$_firstName $_lastName',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: AppFontWeights.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _email,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E7FF),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Text(
              _getDepartmentName(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: AppFontWeights.semibold,
                color: AppColors.primary,
              ),
            ),
          ),
          if (_role == 'admin' || _isSuperAdmin) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color:
                    _isSuperAdmin
                        ? const Color(0xFFDCFCE7)
                        : const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isSuperAdmin ? Icons.shield : Icons.admin_panel_settings,
                    size: 14,
                    color:
                        _isSuperAdmin
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFCA8A04),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isSuperAdmin ? 'Super Admin' : 'Admin',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: AppFontWeights.semibold,
                      color:
                          _isSuperAdmin
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFCA8A04),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingsList() {
    return Container(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            color: Colors.white,
          ),
          child: Column(
            children: [
              SettingsTile(
                icon: Icons.notifications_outlined,
                title: 'Bildirim Tercihleri',
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationPreferencesScreen(),
                      ),
                    ),
              ),
              SettingsTile(
                icon: Icons.bookmark_outline,
                title: 'Takip Ettiklerim',
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FollowedNotificationsScreen(),
                      ),
                    ),
              ),
              SettingsTile(
                icon: Icons.person_outline,
                title: 'Hesap Bilgileri',
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AccountInfoScreen(),
                      ),
                    ),
              ),
              if (_role == 'admin' || _isSuperAdmin)
                SettingsTile(
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'Admin Panel',
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminDashboardScreen(),
                        ),
                      ),
                ),
              SettingsTile(
                icon: Icons.info_outline,
                title: 'Hakkında',
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutScreen()),
                    ),
              ),
              SettingsTile(
                icon: Icons.logout,
                title: 'Çıkış Yap',
                onTap: _handleLogout,
                isLogout: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials() {
    final first = _firstName.isNotEmpty ? _firstName[0] : '';
    final last = _lastName.isNotEmpty ? _lastName[0] : '';
    return '$first$last'.toUpperCase();
  }

  String _getDepartmentName() {
    switch (_departmentId) {
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
