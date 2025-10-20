import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:daily_habits/config/theme.dart';
import 'package:daily_habits/features/profile/models/tenant_model.dart';
import 'package:daily_habits/shared/widgets/custom_button.dart';
import 'package:daily_habits/shared/widgets/custom_text_field.dart';

/// Dialog for editing tenant/business information
class EditTenantDialog extends StatefulWidget {
  final Tenant tenant;
  final Function(String name, String phone, String? email, String address,
      String website, String description) onSave;

  const EditTenantDialog({
    Key? key,
    required this.tenant,
    required this.onSave,
  }) : super(key: key);

  @override
  State<EditTenantDialog> createState() => _EditTenantDialogState();
}

class _EditTenantDialogState extends State<EditTenantDialog> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _websiteController;
  late TextEditingController _descriptionController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.tenant.name);
    _phoneController = TextEditingController(text: widget.tenant.phone);
    _emailController = TextEditingController(text: widget.tenant.email ?? '');
    _addressController = TextEditingController(text: widget.tenant.address);
    _websiteController = TextEditingController(text: widget.tenant.website);
    _descriptionController =
        TextEditingController(text: widget.tenant.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _websiteController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Save tenant changes
  void _saveChanges() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      // Call the onSave callback
      widget.onSave(
        _nameController.text.trim(),
        _phoneController.text.trim(),
        _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        _addressController.text.trim(),
        _websiteController.text.trim(),
        _descriptionController.text.trim(),
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
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dialog title
                Text(
                  'editBusinessInfo'.tr(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryDarkColor,
                      ),
                ),
                const SizedBox(height: 24),

                // Scrollable content
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Business Name field
                        CustomTextField(
                          controller: _nameController,
                          label: 'businessName'.tr(),
                          prefixIcon: Icons.business,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'requiredField'.tr();
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Business Phone field
                        CustomTextField(
                          controller: _phoneController,
                          label: 'businessPhone'.tr(),
                          prefixIcon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'requiredField'.tr();
                            }
                            if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(
                                value.replaceAll(RegExp(r'\s+'), ''))) {
                              return 'invalidPhone'.tr();
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Business Email field (Optional)
                        CustomTextField(
                          controller: _emailController,
                          label: '${'businessEmail'.tr()} (Optional)',
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

                        // Business Address field
                        CustomTextField(
                          controller: _addressController,
                          label: 'businessAddress'.tr(),
                          prefixIcon: Icons.location_on,
                          maxLines: 2,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'requiredField'.tr();
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Website field (Optional)
                        CustomTextField(
                          controller: _websiteController,
                          label: '${'website'.tr()} (Optional)',
                          prefixIcon: Icons.language,
                          keyboardType: TextInputType.url,
                        ),
                        const SizedBox(height: 16),

                        // Description field (Optional)
                        CustomTextField(
                          controller: _descriptionController,
                          label: '${'description'.tr()} (Optional)',
                          prefixIcon: Icons.description,
                          maxLines: 3,
                          keyboardType: TextInputType.multiline,
                        ),
                      ],
                    ),
                  ),
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
      ),
    );
  }
}
