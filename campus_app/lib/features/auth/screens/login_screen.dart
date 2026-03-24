import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/custom_snackbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _resetEmailController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isResetLoading = false;
  String? _errorMessage;
  String? _resetErrorMessage;

  bool _isLocked = false;
  DateTime? _lockoutUntil;
  int _remainingSeconds = 0;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _checkExistingLockout();
  }

  Future<void> _checkExistingLockout() async {
    final lockoutStr = await StorageService.getValue('lockout_until');
    if (lockoutStr != null) {
      final lockoutTime = DateTime.tryParse(lockoutStr);
      if (lockoutTime != null && lockoutTime.isAfter(DateTime.now())) {
        setState(() {
          _isLocked = true;
          _lockoutUntil = lockoutTime;
          _errorMessage = 'Hesap kilitlendi. Lütfen bekleyin.';
        });
        _startCountdown();
      } else {
        await StorageService.deleteValue('lockout_until');
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _resetEmailController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _updateRemainingSeconds();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateRemainingSeconds();
      if (_remainingSeconds <= 0) {
        timer.cancel();
        setState(() {
          _isLocked = false;
          _lockoutUntil = null;
        });
        StorageService.deleteValue('lockout_until');
      }
    });
  }

  void _updateRemainingSeconds() {
    if (_lockoutUntil != null) {
      final remaining = _lockoutUntil!.difference(DateTime.now()).inSeconds;
      setState(() {
        _remainingSeconds = remaining > 0 ? remaining : 0;
      });
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await ApiService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
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
      await StorageService.deleteValue('lockout_until');

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.notifications);
    } else {
      await _handleLoginError(
        response.error?.code ?? 'UNKNOWN_ERROR',
        response.error?.details,
        response.error?.message,
      );
    }

    setState(() => _isLoading = false);
  }

  Future<void> _handleLoginError(
    String errorCode,
    Map<String, dynamic>? details,
    String? errorMessage,
  ) async {
    debugPrint('=== LOGIN ERROR DEBUG ===');
    debugPrint('Error Code: $errorCode');
    debugPrint('Error Message: $errorMessage');
    debugPrint('Details: $details');
    debugPrint('========================');

    if (errorCode == 'ACCOUNT_LOCKED' || errorCode == 'RATE_LIMIT') {
      DateTime lockoutTime;

      if (details != null && details['locked_until'] != null) {
        lockoutTime =
            DateTime.tryParse(details['locked_until']) ??
            DateTime.now().add(const Duration(minutes: 5));
      } else if (details != null && details['remaining_seconds'] != null) {
        final seconds = details['remaining_seconds'] as int;
        lockoutTime = DateTime.now().add(Duration(seconds: seconds));
      } else if (errorMessage != null && errorMessage.contains('saniye')) {
        final match = RegExp(r'(\d+)\s*saniye').firstMatch(errorMessage);
        if (match != null) {
          final seconds = int.tryParse(match.group(1)!) ?? 300;
          lockoutTime = DateTime.now().add(Duration(seconds: seconds));
        } else {
          lockoutTime = DateTime.now().add(const Duration(minutes: 5));
        }
      } else {
        lockoutTime = DateTime.now().add(const Duration(minutes: 5));
      }

      await StorageService.saveValue(
        'lockout_until',
        lockoutTime.toIso8601String(),
      );
      setState(() {
        _isLocked = true;
        _lockoutUntil = lockoutTime;
        _errorMessage = 'Hesap kilitlendi. Lütfen bekleyin.';
      });
      _startCountdown();
      return;
    }

    final remainingAttempts = details?['remaining_attempts'] as int?;
    if (remainingAttempts != null) {
      setState(() {
        _errorMessage =
            'E-posta veya şifre hatalı. Kalan deneme: $remainingAttempts';
      });
    } else {
      setState(() {
        _errorMessage = 'E-posta veya şifre hatalı.';
      });
    }
  }

  String _formatCountdown() {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _showForgotPasswordSheet() {
    _resetEmailController.clear();
    setState(() => _resetErrorMessage = null);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildForgotPasswordSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final logoSize = (screenWidth * 0.17).clamp(48.0, 64.0);
    final cardWidth = (screenWidth - 48).clamp(280.0, 360.0);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    (AppSpacing.lg * 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildHeader(logoSize),
                  const SizedBox(height: AppSpacing.lg),
                  _buildLoginCard(cardWidth),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double logoSize) {
    return Column(
      children: [
        Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppShadows.lg,
          ),
          child: Icon(
            Icons.school,
            size: logoSize * 0.5,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const Text(
          'Kampüs Bildirim',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: AppFontSizes.display,
            fontWeight: AppFontWeights.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Güvenli kampüs hayatı',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: AppFontSizes.caption,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(double cardWidth) {
    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.sm,
      ),
      child: Stack(
        children: [
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Giriş Yap',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: AppFontSizes.h3,
                    fontWeight: AppFontWeights.semibold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
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
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                CustomTextField(
                  controller: _passwordController,
                  label: 'Şifre',
                  hint: '••••••',
                  prefixIcon: Icons.lock_outline,
                  obscureText: !_isPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() => _isPasswordVisible = !_isPasswordVisible);
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Şifre gerekli';
                    }
                    return null;
                  },
                ),
                if (_errorMessage != null || _isLocked) ...[
                  const SizedBox(height: AppSpacing.sm),
                  if (_errorMessage != null)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.error,
                          color: AppColors.error,
                          size: 16,
                        ),
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
                  if (_isLocked) ...[
                    if (_errorMessage != null)
                      const SizedBox(height: AppSpacing.xs),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.lock,
                          color: AppColors.error,
                          size: 16,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            'Kalan süre: ${_formatCountdown()}',
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
                ],
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showForgotPasswordSheet,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Şifremi Unuttum?',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: AppFontSizes.small,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
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
                              'Giriş Yap',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: AppFontSizes.body,
                                fontWeight: AppFontWeights.semibold,
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppColors.divider)),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                      ),
                      child: Text(
                        'veya',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: AppFontSizes.small,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(color: AppColors.divider)),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Hesabınız yok mu? ',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: AppFontSizes.body,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.register);
                      },
                      child: const Text(
                        'Kayıt Ol',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: AppFontSizes.body,
                          fontWeight: AppFontWeights.semibold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPasswordSheet() {
    return StatefulBuilder(
      builder: (context, setSheetState) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'Şifre Sıfırlama',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: AppFontSizes.h3,
                    fontWeight: AppFontWeights.semibold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Kayıtlı e-posta adresinizi giriniz.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: AppFontSizes.body,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                CustomTextField(
                  controller: _resetEmailController,
                  label: 'E-posta',
                  hint: 'ornek@kampus.edu.tr',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  errorText: _resetErrorMessage,
                  onChanged: (_) {
                    if (_resetErrorMessage != null) {
                      setSheetState(() => _resetErrorMessage = null);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed:
                        _isResetLoading
                            ? null
                            : () async {
                              final email = _resetEmailController.text.trim();
                              if (email.isEmpty) {
                                setSheetState(
                                  () =>
                                      _resetErrorMessage =
                                          'E-posta adresi gerekli',
                                );
                                return;
                              }
                              if (!RegExp(
                                r'^[^@]+@[^@]+\.[^@]+',
                              ).hasMatch(email)) {
                                setSheetState(
                                  () =>
                                      _resetErrorMessage =
                                          'Geçerli bir e-posta adresi girin',
                                );
                                return;
                              }
                              setSheetState(() {
                                _isResetLoading = true;
                                _resetErrorMessage = null;
                              });
                              final response = await ApiService.forgotPassword(
                                email: email,
                              );
                              setSheetState(() => _isResetLoading = false);
                              if (response.success) {
                                Navigator.pop(context);
                                CustomSnackbar.show(
                                  context,
                                  message:
                                      'Şifre sıfırlama bağlantısı gönderildi',
                                  type: SnackbarType.success,
                                );
                              } else {
                                setSheetState(() {
                                  _resetErrorMessage =
                                      response.error?.message ??
                                      'Bir hata oluştu';
                                });
                              }
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                    child:
                        _isResetLoading
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
                              'Sıfırlama Bağlantısı Gönder',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: AppFontSizes.body,
                                fontWeight: AppFontWeights.semibold,
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        );
      },
    );
  }
}
