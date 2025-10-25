import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:daily_habits/config/routes.dart';
import 'package:daily_habits/config/theme.dart';
import 'package:daily_habits/shared/widgets/custom_button.dart';
import 'package:daily_habits/shared/widgets/custom_text_field.dart';
import 'package:daily_habits/shared/widgets/custom_messages.dart';
import 'package:daily_habits/features/habits/models/user_model.dart';
import 'package:daily_habits/core/database/habit_database_service.dart';
import 'package:daily_habits/core/services/google_auth_service.dart';
import 'package:daily_habits/features/auth/services/auth_service.dart';
import 'package:daily_habits/features/habits/services/reminder_manager_service.dart';
import 'package:daily_habits/features/habits/widgets/permission_dialog.dart';

/// Register screen
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final HabitDatabaseService _databaseService = HabitDatabaseService();
  final GoogleAuthService _googleAuthService = GoogleAuthService();

  bool _isLoading = false;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Check and request notification permissions
  Future<void> _checkAndRequestPermissions() async {
    // Wait for navigation to complete
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    
    debugPrint('🔍 Checking permissions after registration...');
    
    final reminderManager = ReminderManagerService();
    final hasPermission = await reminderManager.arePermissionsGranted();
    
    debugPrint('🔍 Has permission: $hasPermission');
    
    if (!hasPermission && mounted) {
      debugPrint('🔔 Showing permission dialog...');
      await PermissionDialog.showExactAlarmPermissionDialog(context);
    } else {
      debugPrint('✅ Permissions already granted or context not available');
    }
  }

  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_acceptTerms) {
        context.showWarningMessage('acceptTermsError'.tr());
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final user = User(
          name: _nameController.text.trim(),
          email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
          password: _passwordController.text.trim(),
          language: 'ar',
          theme: 'light',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final userId = await _databaseService.insertUser(user);

        // Save login state
        await AuthService.saveLoginState(
          userId: userId,
          email: user.email ?? '',
          name: user.name,
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          context.showSuccessMessage('registrationSuccessful'.tr());

          // Start permission check in parallel
          _checkAndRequestPermissions();

          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              // Navigate to dashboard and clear all previous routes
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.dashboard,
                (route) => false,
              );
            }
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          context.showErrorMessage('registrationFailed'.tr());
        }
      }
    }
  }

  // Sign in with Google
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _googleAuthService.signInWithGoogle();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (user != null) {
          // Save login state for Google sign-in
          await AuthService.saveLoginState(
            userId: user.userID ?? 0,
            email: user.email ?? '',
            name: user.name,
          );

          context.showSuccessMessage('registrationSuccessful'.tr());

          // Start permission check in parallel
          _checkAndRequestPermissions();

          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted) {
              // Navigate to dashboard and clear all previous routes
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.dashboard,
                (route) => false,
              );
            }
          });
        } else {
          context.showErrorMessage('googleSignInCancelled'.tr());
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        context.showErrorMessage('googleSignInFailed'.tr());
      }
    }
  }

  // Navigate to login screen
  void _navigateToLogin() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // App logo
                  Center(
                    child: Hero(
                      tag: 'app_logo',
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withAlpha(70),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.track_changes,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Create Account 🌟',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start building better habits today',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Name field
                  CustomTextField(
                    controller: _nameController,
                    label: 'fullName'.tr(),
                    keyboardType: TextInputType.name,
                    prefixIcon: Icons.person_outline,
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'requiredField'.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),



                  // Email field (Optional)
                  CustomTextField(
                    controller: _emailController,
                    label: 'email'.tr(),
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'invalidEmail'.tr();
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Password field
                  CustomTextField(
                    controller: _passwordController,
                    label: 'password'.tr(),
                    obscureText: true,
                    prefixIcon: Icons.lock_outline,
                    showTogglePasswordButton: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'requiredField'.tr();
                      }
                      if (value.length < 6) {
                        return 'passwordTooShort'.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Confirm password field
                  CustomTextField(
                    controller: _confirmPasswordController,
                    label: 'confirmPassword'.tr(),
                    obscureText: true,
                    prefixIcon: Icons.lock_outline,
                    showTogglePasswordButton: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'requiredField'.tr();
                      }
                      if (value != _passwordController.text) {
                        return 'passwordsDontMatch'.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Terms and conditions checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: _acceptTerms,
                        onChanged: (value) {
                          setState(() {
                            _acceptTerms = value ?? false;
                          });
                        },
                        activeColor: AppTheme.primaryColor,
                      ),
                      Expanded(
                        child: Text(
                          'agreeTerms'.tr(),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Register button with gold gradient
                  Center(
                    child: CustomButton(
                      text: 'signUp'.tr(),
                      onPressed: _register,
                      isLoading: _isLoading,
                      type: ButtonType.primary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Divider with "OR" text
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey[400],
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'or'.tr(),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.grey[400],
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Google Sign-In button
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _signInWithGoogle,
                      icon: Image.asset(
                        'assets/icons/google_logo.png',
                        height: 24,
                        width: 24,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.g_mobiledata,
                            size: 28,
                            color: Colors.red,
                          );
                        },
                      ),
                      label: Text(
                        'signInWithGoogle'.tr(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        side: BorderSide(color: Colors.grey[300]!, width: 1.5),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Login link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'alreadyHaveAccount'.tr(),
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                          ),
                        ),
                        TextButton(
                          onPressed: _navigateToLogin,
                          child: Text(
                            'signIn'.tr(),
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
