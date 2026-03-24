import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../models/department_model.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/custom_snackbar.dart';
import '../widgets/password_strength.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  List<DepartmentModel> _departments = [];
  DepartmentModel? _selectedDepartment;
  bool _isLoading = false;
  bool _isLoadingDepartments = true;
  String? _errorMessage;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadDepartments();
    _firstNameController.addListener(_updateProgress);
    _lastNameController.addListener(_updateProgress);
    _emailController.addListener(_updateProgress);
    _passwordController.addListener(_updateProgress);
    _confirmController.addListener(_updateProgress);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _loadDepartments() {
    setState(() {
      _departments = [
        DepartmentModel(id: 1, name: 'Bilgisayar Mühendisliği'),
        DepartmentModel(id: 2, name: 'Elektrik-Elektronik Mühendisliği'),
        DepartmentModel(id: 3, name: 'Makine Mühendisliği'),
        DepartmentModel(id: 4, name: 'İnşaat Mühendisliği'),
        DepartmentModel(id: 5, name: 'Endüstri Mühendisliği'),
        DepartmentModel(id: 6, name: 'İşletme'),
        DepartmentModel(id: 7, name: 'İktisat'),
        DepartmentModel(id: 8, name: 'Hukuk'),
        DepartmentModel(id: 9, name: 'Tıp'),
        DepartmentModel(id: 10, name: 'Hemşirelik'),
        DepartmentModel(id: 11, name: 'Mimarlık'),
        DepartmentModel(id: 12, name: 'İç Mimarlık'),
        DepartmentModel(id: 13, name: 'Psikoloji'),
        DepartmentModel(id: 14, name: 'Sosyoloji'),
        DepartmentModel(id: 15, name: 'İletişim'),
        DepartmentModel(id: 16, name: 'Yönetim'),
        DepartmentModel(id: 17, name: 'Fen-Edebiyat'),
        DepartmentModel(id: 18, name: 'Eğitim Fakültesi'),
        DepartmentModel(id: 19, name: 'İdari Personel'),
        DepartmentModel(id: 20, name: 'Öğrenci İşleri'),
      ];
      _isLoadingDepartments = false;
    });
  }

  void _updateProgress() {
    int filled = 0;
    if (_firstNameController.text.trim().length >= 2) filled++;
    if (_lastNameController.text.trim().length >= 2) filled++;
    if (_emailController.text.contains('@')) filled++;
    if (_selectedDepartment != null) filled++;
    if (_passwordController.text.length >= 6) filled++;
    if (_confirmController.text == _passwordController.text &&
        _confirmController.text.isNotEmpty)
      filled++;

    setState(() {
      _progress = filled / 6;
    });
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDepartment == null) {
      setState(() => _errorMessage = 'Lütfen birim seçin');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await ApiService.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      departmentId: _selectedDepartment!.id,
    );

    if (!mounted) return;

    if (response.success && response.data != null) {
      await StorageService.saveTokens(
        response.data!.tokens.accessToken,
        response.data!.tokens.refreshToken,
      );
      await StorageService.saveUserInfo(
        response.data!.user.id.toString(),
        response.data!.user.email,
        response.data!.user.role,
      );

      if (!mounted) return;
      CustomSnackbar.show(
        context,
        message: 'Kayıt başarılı!',
        type: SnackbarType.success,
      );
      Navigator.pushReplacementNamed(context, AppRoutes.notifications);
    } else {
      setState(() {
        _errorMessage = response.error?.message ?? 'Kayıt başarısız';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildAppBar(),
          _buildProgressBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  _buildFormCard(),
                  const SizedBox(height: AppSpacing.md),
                  _buildLoginLink(),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: AppColors.surface,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: AppSpacing.md),
              const Text(
                'Kayıt Ol',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: AppFontSizes.lead,
                  fontWeight: AppFontWeights.semibold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: 4,
      color: AppColors.divider,
      child: Align(
        alignment: Alignment.centerLeft,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: MediaQuery.of(context).size.width * _progress,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.sm,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              controller: _firstNameController,
              label: 'Ad',
              hint: 'Adınız',
              prefixIcon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.trim().length < 2) {
                  return 'Ad en az 2 karakter olmalı';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            CustomTextField(
              controller: _lastNameController,
              label: 'Soyad',
              hint: 'Soyadınız',
              prefixIcon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.trim().length < 2) {
                  return 'Soyad en az 2 karakter olmalı';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            CustomTextField(
              controller: _emailController,
              label: 'E-posta',
              hint: 'ornek@kampus.edu.tr',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'E-posta adresi gerekli';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Geçerli bir e-posta adresi girin';
                }
                if (!value.toLowerCase().contains('.edu')) {
                  return 'Sadece .edu uzantılı e-postalar kabul edilir';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            _buildDepartmentDropdown(),
            const SizedBox(height: AppSpacing.md),
            CustomTextField(
              controller: _passwordController,
              label: 'Şifre',
              hint: '••••••••',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Şifre gerekli';
                }
                if (value.length < 8) {
                  return 'Şifre en az 8 karakter olmalı';
                }
                if (!value.contains(RegExp(r'[A-Z]'))) {
                  return 'En az 1 büyük harf gerekli';
                }
                if (!value.contains(RegExp(r'[a-z]'))) {
                  return 'En az 1 küçük harf gerekli';
                }
                if (!value.contains(RegExp(r'[0-9]'))) {
                  return 'En az 1 rakam gerekli';
                }
                if (!value.contains(RegExp(r'[!@#$%^&*]'))) {
                  return 'En az 1 özel karakter gerekli (!@#\$%^&*)';
                }
                return null;
              },
            ),
            PasswordStrengthIndicator(password: _passwordController.text),
            const SizedBox(height: AppSpacing.md),
            CustomTextField(
              controller: _confirmController,
              label: 'Şifre Tekrar',
              hint: '••••••••',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Şifre tekrarı gerekli';
                }
                if (value != _passwordController.text) {
                  return 'Şifreler eşleşmiyor';
                }
                return null;
              },
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  const Icon(Icons.error, color: AppColors.error, size: 16),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: AppFontSizes.small,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Text(
                          'Kayıt Ol',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: AppFontSizes.body,
                            fontWeight: AppFontWeights.semibold,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Birim / Bölüm',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: AppFontSizes.caption,
            fontWeight: AppFontWeights.medium,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: AppColors.divider),
          ),
          child:
              _isLoadingDepartments
                  ? const Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                  : DropdownButtonHideUnderline(
                    child: DropdownButton<DepartmentModel>(
                      value: _selectedDepartment,
                      hint: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.business_outlined,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            SizedBox(width: AppSpacing.sm),
                            Text(
                              'Biriminizi seçin',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: AppFontSizes.body,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      isExpanded: true,
                      icon: const Padding(
                        padding: EdgeInsets.only(right: AppSpacing.md),
                        child: Icon(
                          Icons.expand_more,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      items:
                          _departments.map((dept) {
                            return DropdownMenuItem(
                              value: dept,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.business_outlined,
                                      color: AppColors.textSecondary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: Text(
                                        dept.name,
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: AppFontSizes.body,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDepartment = value;
                        });
                        _updateProgress();
                      },
                    ),
                  ),
        ),
      ],
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Zaten hesabınız var mı? ',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: AppFontSizes.body,
            color: AppColors.textSecondary,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Text(
            'Giriş Yap',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: AppFontSizes.body,
              fontWeight: AppFontWeights.semibold,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
