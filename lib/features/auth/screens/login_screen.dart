import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:daily_habits/config/routes.dart';
import 'package:daily_habits/config/theme.dart';
import 'package:daily_habits/shared/widgets/custom_button.dart';
import 'package:daily_habits/shared/widgets/custom_text_field.dart';
import 'package:daily_habits/shared/widgets/custom_messages.dart';
import 'package:daily_habits/core/database/habit_database_service.dart';
import 'package:daily_habits/core/services/google_auth_service.dart';
import 'package:daily_habits/features/auth/services/auth_service.dart';
import 'package:local_auth/local_auth.dart';
import 'package:daily_habits/features/habits/services/reminder_manager_service.dart';
import 'package:daily_habits/features/habits/widgets/permission_dialog.dart';

/// Login screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final HabitDatabaseService _databaseService = HabitDatabaseService();
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  bool _isLoading = false;
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _canCheckBiometrics = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Check if biometric authentication is available
  Future<void> _checkBiometrics() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      setState(() {
        _canCheckBiometrics = canCheckBiometrics;
      });
    } catch (e) {
      setState(() {
        _canCheckBiometrics = false;
      });
    }
  }

  // Check and request notification permissions
  Future<void> _checkAndRequestPermissions() async {
    // Wait for navigation to complete
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    
    debugPrint('🔍 Checking permissions after login...');
    
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

  // Authenticate with biometrics
  Future<void> _authenticateWithBiometrics() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access your account',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (authenticated) {
          // Show success message
          context.showSuccessMessage(
            'loginSuccessful'.tr(),
            duration: const Duration(seconds: 1),
          );

          // Login successful - navigate to habits screen
          // Start permission check in parallel
          _checkAndRequestPermissions();
          
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.dashboard,
                (route) => false,
              );
            }
          });
        } else {
          // Show error message for failed authentication
          context.showErrorMessage(
            'authenticationFailed'.tr(),
            action: CustomSnackBarMessages.createRetryAction(() {
              _authenticateWithBiometrics();
            }),
          );
        }
      }
    } catch (e) {
      // Handle authentication error
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        context.showErrorMessage(
          'errorOccurred'.tr(),
          action: CustomSnackBarMessages.createRetryAction(() {
            _authenticateWithBiometrics();
          }),
        );
      }
    }
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final email = _emailController.text.trim();
        final password = _passwordController.text.trim();

        final user = await _databaseService.getUserByEmail(email);

        if (user == null) {
          throw Exception('User not found');
        }

        if (user.password != password) {
          throw Exception('Invalid password');
        }

        // Save login state
        await AuthService.saveLoginState(
          userId: user.userID ?? 0,
          email: user.email ?? '',
          name: user.name,
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          context.showSuccessMessage('loginSuccessful'.tr());

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
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          String errorMessage;
          if (e.toString().contains('not found')) {
            errorMessage = 'emailNotFound'.tr();
          } else if (e.toString().contains('password')) {
            errorMessage = 'invalidPassword'.tr();
          } else {
            errorMessage = 'loginFailed'.tr();
          }

          context.showErrorMessage(errorMessage);
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

          context.showSuccessMessage('loginSuccessful'.tr());

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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
                  SizedBox(height: size.height * 0.03),

                  // App logo with animation
                  Center(
                    child: Hero(
                      tag: 'app_logo',
                      child: Container(
                        width: 120,
                        height: 120,
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
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.04),

                  // Welcome text
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Welcome Back! 👋',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in to continue your habit journey',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Email field
                  CustomTextField(
                    controller: _emailController,
                    label: 'email'.tr(),
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'requiredField'.tr();
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'invalidEmail'.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

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
                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (bool? value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                          ),
                          Text(
                            'rememberMe'.tr(),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRoutes.forgotPassword,
                        ),
                        child: Text(
                          'forgotPassword'.tr(),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  const SizedBox(height: 24),

                  // Login button with gold gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withAlpha(70),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CustomButton(
                      text: 'signIn'.tr(),
                      onPressed: _login,
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
                  OutlinedButton.icon(
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
                  const SizedBox(height: 24),

                  // Register link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'dontHaveAccount'.tr(),
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            AppRoutes.register,
                          ),
                          child: Text(
                            'signUp'.tr(),
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
