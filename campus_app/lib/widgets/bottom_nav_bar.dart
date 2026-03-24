import 'package:flutter/material.dart';
import '../core/constants.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final bool isAdmin;
  final Function(int)? onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    this.isAdmin = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.navHeight,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              context: context,
              index: 0,
              icon: Icons.notifications_outlined,
              activeIcon: Icons.notifications,
              label: 'Bildirimler',
              route: '/notifications',
            ),
            _buildNavItem(
              context: context,
              index: 1,
              icon: Icons.map_outlined,
              activeIcon: Icons.map,
              label: 'Harita',
              route: '/map',
            ),
            _buildNavItem(
              context: context,
              index: 2,
              icon: Icons.add_circle_outline,
              activeIcon: Icons.add_circle,
              label: 'Oluştur',
              route: '/create',
            ),
            if (isAdmin)
              _buildNavItem(
                context: context,
                index: 3,
                icon: Icons.admin_panel_settings_outlined,
                activeIcon: Icons.admin_panel_settings,
                label: 'Admin',
                route: '/admin',
              ),
            _buildNavItem(
              context: context,
              index: isAdmin ? 4 : 3,
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: 'Profil',
              route: '/profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required String route,
  }) {
    final isSelected = currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          if (onTap != null) {
            onTap!(index);
          } else if (!isSelected) {
            Navigator.pushReplacementNamed(context, route);
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.primary : AppColors.secondary,
              size: 24,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    isSelected ? AppFontWeights.medium : AppFontWeights.regular,
                color: isSelected ? AppColors.primary : AppColors.secondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
