import 'package:daily_habits/features/profile/models/user_model.dart';
import 'package:daily_habits/features/profile/models/tenant_model.dart';
import 'package:daily_habits/features/profile/repositories/tenant_repository.dart';

/// Repository for user data operations
class UserRepository {
  final TenantRepository _tenantRepository = TenantRepository();

  String get tableName => 'users';
  User fromMap(Map<String, dynamic> map) {
    // Note: This creates a User without tenant data
    // Use findByIdWithTenant for complete user data
    return User(
      tenant: Tenant(
        id: map['tenant_id'] as String,
        name: '',
        phone: '',
        email: '',
        address: '',
        website: '',
        logo: '',
        description: '',
        lastUpdated: DateTime.now(),
        preferences: TenantPreferences(
          authEnabled: true,
          biometricAuthEnabled: false,
          defaultCurrency: Currency(
            code: 'USD',
            name: 'US Dollar',
            symbol: '\$',
            lastUpdated: DateTime.now(),
          ),
        ),
        subscriptionPlan: TenantSubscriptionPlan(
          plan: SubscriptionPlanConstants.freePlan,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 30)),
        ),
      ),
      id: map['id'] as String,
      name: map['name'] as String,
      phoneNumber: map['phone_number'] as String,
      email: map['email'] as String?,
      profileImageUrl: map['profile_image_url'] as String?,
      role: map['role'] as String,
      status: UserStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => UserStatus.active,
      ),
      preferences: UserPreferences(
        notificationsEnabled: (map['notifications_enabled'] ?? 0) == 1,
        emailNotificationsEnabled:
            (map['email_notifications_enabled'] ?? 0) == 1,
        pushNotificationsEnabled: (map['push_notifications_enabled'] ?? 0) == 1,
        smsNotificationsEnabled: (map['sms_notifications_enabled'] ?? 0) == 1,
        biometricAuthEnabled: (map['biometric_auth_enabled'] ?? 0) == 1,
      ),
      createdAt: DateTime.parse(map['created_at'] as String),
      lastLoginAt: map['last_login_at'] != null
          ? DateTime.parse(map['last_login_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap(User model) {
    return {
      'id': model.id,
      'tenant_id': model.tenant.id,
      'name': model.name,
      'email': model.email,
      'phone_number': model.phoneNumber,
      'profile_image_url': model.profileImageUrl,
      'role': model.role,
      'status': model.status.toString().split('.').last,
      'notifications_enabled': model.preferences.notificationsEnabled ? 1 : 0,
      'email_notifications_enabled':
          model.preferences.emailNotificationsEnabled ? 1 : 0,
      'push_notifications_enabled':
          model.preferences.pushNotificationsEnabled ? 1 : 0,
      'sms_notifications_enabled':
          model.preferences.smsNotificationsEnabled ? 1 : 0,
      'biometric_auth_enabled': model.preferences.biometricAuthEnabled ? 1 : 0,
      'created_at': model.createdAt.toIso8601String(),
      'last_login_at': model.lastLoginAt?.toIso8601String(),
    };
  }

  /// Find user by phone with tenant data (placeholder implementation)
  Future<User?> findByPhoneWithTenant(String phone) async {
    // Placeholder implementation - would query database in real app
    return null;
  }

  /// Find user by phone (placeholder implementation)
  Future<User?> findByPhone(String phone) async {
    // Placeholder implementation - would query database in real app
    return null;
  }

  /// Find user by email (placeholder implementation)
  Future<User?> findByEmail(String? email) async {
    // Placeholder implementation - would query database in real app
    return null;
  }

  /// Check if user exists by phone (placeholder implementation)
  Future<bool> existsByPhone(String phone) async {
    // Placeholder implementation - would check database in real app
    return false;
  }

  /// Update user preferences (placeholder implementation)
  Future<int> updatePreferences(
      String userId, UserPreferences preferences) async {
    // Placeholder implementation - would update database in real app
    return 1;
  }

  /// Insert user (placeholder implementation)
  Future<String> insert(User user) async {
    // Placeholder implementation - would insert into database in real app
    return user.id;
  }
}
