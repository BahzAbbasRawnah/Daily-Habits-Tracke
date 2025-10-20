import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:daily_habits/config/theme.dart';
import 'package:daily_habits/features/profile/models/user_model.dart';
import 'package:daily_habits/shared/widgets/custom_button.dart';
import 'package:daily_habits/shared/widgets/custom_text_field.dart';

/// Dialog for editing profile information
class EditProfileDialog extends StatefulWidget {
  final User user;
  final Function(String name, String? email, String phoneNumber) onSave;

  const EditProfileDialog({
    Key? key,
    required this.user,
    required this.onSave,
  }) : super(key: key);

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email ?? '');
    _phoneController = TextEditingController(text: widget.user.phoneNumber);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// Save profile changes
  void _saveChanges() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      // Call the onSave callback
      widget.onSave(
        _nameController.text.trim(),
        _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        _phoneController.text.trim(),
      );

      setState(() {
        _isLoading = false;
      });

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dialog title
              Text(
                'editProfile'.tr(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryDarkColor,
                    ),
              ),
              const SizedBox(height: 24),

              // Name field
              CustomTextField(
                controller: _nameController,
                label: 'fullName'.tr(),
                prefixIcon: Icons.person,
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
                label: '${'email'.tr()} (Optional)',
                prefixIcon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'invalidEmail'.tr();
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone field
              CustomTextField(
                controller: _phoneController,
                label: 'phoneNumber'.tr(),
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'requiredField'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Cancel button
                  CustomButton(
                    text: 'cancel'.tr(),
                    onPressed: () => Navigator.pop(context),
                    type: ButtonType.text,
                    isFullWidth: false,
                  ),
                  const SizedBox(width: 16),

                  // Save button
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
                      text: 'saveChanges'.tr(),
                      onPressed: _saveChanges,
                      isLoading: _isLoading,
                      type: ButtonType.primary,
                      backgroundColor: Colors.transparent,
                      textColor: Colors.white,
                      isFullWidth: false,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
