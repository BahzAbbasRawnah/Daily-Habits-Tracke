import 'package:daily_habits/features/profile/models/tenant_model.dart';

/// Repository for tenant data operations
class TenantRepository {
  String get tableName => 'tenants';

  Tenant fromMap(Map<String, dynamic> map) {
    return Tenant(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String?,
      address: map['address'] as String,
      website: map['website'] as String,
      logo: map['logo'] as String,
      description: map['description'] as String,
      lastUpdated: DateTime.parse(map['last_updated'] as String),
      preferences: TenantPreferences(
        authEnabled: (map['auth_enabled'] ?? 0) == 1,
        biometricAuthEnabled: (map['biometric_auth_enabled'] ?? 0) == 1,
        defaultCurrency: Currency(
          code: map['default_currency'] as String? ?? 'USD',
          name: '', // Will be loaded separately
          symbol: '', // Will be loaded separately
          lastUpdated: DateTime.now(),
        ),
      ),
      subscriptionPlan: TenantSubscriptionPlan(
        plan: SubscriptionPlans.getByName(
            map['subscription_plan'] as String? ?? 'free'),
        startDate: DateTime.parse(map['subscription_start_date'] as String? ??
            DateTime.now().toIso8601String()),
        endDate: DateTime.parse(map['subscription_end_date'] as String? ??
            DateTime.now().add(const Duration(days: 30)).toIso8601String()),
        isActive: (map['subscription_is_active'] ?? 0) == 1,
        paymentId: map['subscription_payment_id'] as String?,
      ),
    );
  }

  Map<String, dynamic> toMap(Tenant model) {
    return {
      'id': model.id,
      'name': model.name,
      'phone': model.phone,
      'email': model.email,
      'address': model.address,
      'website': model.website,
      'logo': model.logo,
      'description': model.description,
      'last_updated': model.lastUpdated.toIso8601String(),
      'auth_enabled': model.preferences.authEnabled ? 1 : 0,
      'biometric_auth_enabled': model.preferences.biometricAuthEnabled ? 1 : 0,
      'default_currency': model.preferences.defaultCurrency.code,
      'subscription_plan': model.subscriptionPlan.plan.plan.name,
      'subscription_start_date':
          model.subscriptionPlan.startDate.toIso8601String(),
      'subscription_end_date': model.subscriptionPlan.endDate.toIso8601String(),
      'subscription_is_active': model.subscriptionPlan.isActive ? 1 : 0,
      'subscription_payment_id': model.subscriptionPlan.paymentId,
    };
  }

  /// Update subscription plan (placeholder implementation)
  Future<int> updateSubscriptionPlan(
    String tenantId,
    TenantSubscriptionPlan subscriptionPlan,
  ) async {
    // Placeholder implementation - would update database in real app
    return 1;
  }

  /// Check if tenant exists by phone (placeholder implementation)
  Future<bool> existsByPhone(String phone) async {
    // Placeholder implementation - would check database in real app
    return false;
  }

  /// Find tenant by phone (placeholder implementation)
  Future<Tenant?> findByPhone(String phone) async {
    // Placeholder implementation - would query database in real app
    return null;
  }

  /// Find tenant by email (placeholder implementation)
  Future<Tenant?> findByEmail(String? email) async {
    // Placeholder implementation - would query database in real app
    return null;
  }

  /// Find tenant by ID (placeholder implementation)
  Future<Tenant?> findById(String id) async {
    // Placeholder implementation - would query database in real app
    return null;
  }

  /// Find expired tenants (placeholder implementation)
  Future<List<Tenant>> findExpiredTenants() async {
    // Placeholder implementation - would query database in real app
    return [];
  }

  /// Get tenant statistics (placeholder implementation)
  Future<Map<String, int>> getTenantStatistics() async {
    // Placeholder implementation - would query database in real app
    return {
      'total': 0,
      'active': 0,
      'trial': 0,
      'premium': 0,
      'free': 0,
    };
  }
}
