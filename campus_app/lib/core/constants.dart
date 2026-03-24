import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryDark = Color(0xFF3730A3);
  static const Color secondary = Color(0xFF64748B);
  static const Color accent = Color(0xFFDC2626);

  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  static const Color neutral50 = Color(0xFFF8FAFC);
  static const Color neutral100 = Color(0xFFF1F5F9);
  static const Color neutral200 = Color(0xFFE2E8F0);
  static const Color neutral300 = Color(0xFFCBD5E1);
  static const Color neutral400 = Color(0xFF94A3B8);
  static const Color neutral500 = Color(0xFF64748B);
  static const Color neutral600 = Color(0xFF475569);
  static const Color neutral700 = Color(0xFF334155);
  static const Color neutral800 = Color(0xFF1E293B);
  static const Color neutral900 = Color(0xFF0F172A);

  static const Color categorySecurity = Color(0xFFE53935);
  static const Color categoryMaintenance = Color(0xFFFB8C00);
  static const Color categoryCleaning = Color(0xFFFDD835);
  static const Color categoryInfra = Color(0xFF1E88E5);
  static const Color categoryOther = Color(0xFF43A047);

  static const Color statusOpen = Color(0xFFF59E0B);
  static const Color statusReview = Color(0xFF3B82F6);
  static const Color statusSolved = Color(0xFF16A34A);
  static const Color statusSpam = Color(0xFFDC2626);

  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE2E8F0);

  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textDisabled = Color(0xFF94A3B8);
}

class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 40.0;
  static const double xxxl = 48.0;
  static const double xxxxl = 64.0;
}

class AppRadius {
  AppRadius._();

  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double xxl = 24.0;
  static const double full = 9999.0;
}

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> none = [];

  static const List<BoxShadow> sm = [
    BoxShadow(color: Color(0x14000000), blurRadius: 4, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(color: Color(0x1F000000), blurRadius: 8, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(color: Color(0x29000000), blurRadius: 12, offset: Offset(0, 6)),
  ];

  static const List<BoxShadow> xl = [
    BoxShadow(color: Color(0x33000000), blurRadius: 24, offset: Offset(0, 8)),
  ];
}

class AppFontSizes {
  AppFontSizes._();

  static const double caption = 12.0;
  static const double small = 14.0;
  static const double body = 16.0;
  static const double lead = 18.0;
  static const double h3 = 24.0;
  static const double h2 = 32.0;
  static const double h1 = 40.0;
  static const double display = 28.0;
}

class AppFontWeights {
  AppFontWeights._();

  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semibold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
}

class AppDurations {
  AppDurations._();

  static const Duration fast = Duration(milliseconds: 100);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 300);
  static const Duration splash = Duration(milliseconds: 2500);
}

class AppSizes {
  AppSizes._();

  static const double navHeight = 72.0;
  static const double headerHeight = 56.0;
  static const double maxContentWidth = 480.0;
  static const double inputHeightDefault = 56.0;
  static const double inputHeightSmall = 40.0;
  static const double badgeSize = 40.0;
  static const double fabSizeMain = 56.0;
  static const double fabSizeSos = 48.0;
  static const double iconSizeSm = 20.0;
  static const double iconSizeXl = 80.0;
}

class AppCategories {
  AppCategories._();

  static const List<Map<String, dynamic>> all = [
    {
      'id': 1,
      'name': 'security',
      'display_name': 'Güvenlik',
      'icon': 'security',
      'color_hex': '#E53935',
    },
    {
      'id': 2,
      'name': 'maintenance',
      'display_name': 'Bakım',
      'icon': 'build',
      'color_hex': '#FB8C00',
    },
    {
      'id': 3,
      'name': 'cleaning',
      'display_name': 'Temizlik',
      'icon': 'cleaning_services',
      'color_hex': '#FDD835',
    },
    {
      'id': 4,
      'name': 'infrastructure',
      'display_name': 'Altyapı',
      'icon': 'construction',
      'color_hex': '#1E88E5',
    },
    {
      'id': 5,
      'name': 'other',
      'display_name': 'Diğer',
      'icon': 'more_horiz',
      'color_hex': '#43A047',
    },
  ];

  static IconData getIcon(String iconName) {
    switch (iconName) {
      case 'security':
        return Icons.security;
      case 'build':
        return Icons.build;
      case 'cleaning_services':
        return Icons.cleaning_services;
      case 'construction':
        return Icons.construction;
      case 'more_horiz':
        return Icons.more_horiz;
      default:
        return Icons.info;
    }
  }

  static Color getColor(int categoryId) {
    switch (categoryId) {
      case 1:
        return AppColors.categorySecurity;
      case 2:
        return AppColors.categoryMaintenance;
      case 3:
        return AppColors.categoryCleaning;
      case 4:
        return AppColors.categoryInfra;
      case 5:
        return AppColors.categoryOther;
      default:
        return AppColors.secondary;
    }
  }
}

class AppStatuses {
  AppStatuses._();

  static const List<Map<String, dynamic>> all = [
    {'id': 1, 'name': 'open', 'display_name': 'Açık', 'color_hex': '#F59E0B'},
    {
      'id': 2,
      'name': 'in_review',
      'display_name': 'İnceleniyor',
      'color_hex': '#3B82F6',
    },
    {
      'id': 3,
      'name': 'resolved',
      'display_name': 'Çözüldü',
      'color_hex': '#16A34A',
    },
    {'id': 4, 'name': 'spam', 'display_name': 'Spam', 'color_hex': '#DC2626'},
  ];

  static Color getColor(int statusId) {
    switch (statusId) {
      case 1:
        return AppColors.statusOpen;
      case 2:
        return AppColors.statusReview;
      case 3:
        return AppColors.statusSolved;
      case 4:
        return AppColors.statusSpam;
      default:
        return AppColors.secondary;
    }
  }
}

class AppTimeFilters {
  AppTimeFilters._();

  static const List<Map<String, String>> all = [
    {'value': 'all', 'label': 'Tümü'},
    {'value': 'today', 'label': 'Bugün'},
    {'value': 'this_week', 'label': 'Bu Hafta'},
    {'value': 'this_month', 'label': 'Bu Ay'},
  ];
}
