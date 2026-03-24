import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/services/api_service.dart';
import '../widgets/custom_switch.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  Map<int, bool> _preferences = {};
  bool _isLoading = true;

  final List<Map<String, dynamic>> _categories = [
    {'id': 0, 'name': '🚨 Acil Durum', 'disabled': true},
    {'id': 1, 'name': '🔴 Güvenlik', 'disabled': false},
    {'id': 2, 'name': '🟠 Teknik Arıza', 'disabled': false},
    {'id': 3, 'name': '🟡 Temizlik', 'disabled': false},
    {'id': 4, 'name': '🔵 Altyapı', 'disabled': false},
    {'id': 5, 'name': '🟢 Diğer', 'disabled': false},
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.getNotificationPreferences();

      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;

        setState(() {
          _preferences = {
            0: true,
            1: data['notify_security'] ?? true,
            2: data['notify_maintenance'] ?? true,
            3: data['notify_cleaning'] ?? true,
            4: data['notify_infrastructure'] ?? true,
            5: data['notify_other'] ?? true,
          };
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Tercihler yüklenemedi'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bir hata oluştu: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _updatePreference(int categoryId, bool value) async {
    final Map<int, String> fieldMap = {
      1: 'notify_security',
      2: 'notify_maintenance',
      3: 'notify_cleaning',
      4: 'notify_infrastructure',
      5: 'notify_other',
    };

    final fieldName = fieldMap[categoryId];
    if (fieldName == null) return;

    setState(() {
      _preferences[categoryId] = value;
    });

    try {
      final response = await ApiService.updateNotificationPreferences(
        preferences: {fieldName: value},
      );

      if (!response.success && mounted) {
        setState(() {
          _preferences[categoryId] = !value;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Güncelleme başarısız'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _preferences[categoryId] = !value;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bir hata oluştu: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Bildirim Tercihleri',
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
              : Column(
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: ListView.builder(
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          final categoryId = category['id'] as int;
                          final isDisabled = category['disabled'] as bool;

                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: AppColors.neutral200),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  category['name'] as String,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color:
                                        isDisabled
                                            ? AppColors.textSecondary
                                            : AppColors.textPrimary,
                                    fontWeight:
                                        isDisabled
                                            ? AppFontWeights.medium
                                            : AppFontWeights.semibold,
                                  ),
                                ),
                                CustomSwitch(
                                  value: _preferences[categoryId] ?? true,
                                  disabled: isDisabled,
                                  onChanged:
                                      isDisabled
                                          ? null
                                          : (value) => _updatePreference(
                                            categoryId,
                                            value,
                                          ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
