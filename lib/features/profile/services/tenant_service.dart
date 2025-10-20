import 'package:flutter/foundation.dart';
import 'package:daily_habits/features/profile/models/tenant_model.dart';
import 'package:daily_habits/features/profile/models/user_model.dart';
import 'package:daily_habits/features/profile/repositories/tenant_repository.dart';
import 'package:daily_habits/features/profile/repositories/user_repository.dart';

/// Service for managing tenant operations
class TenantService {
  final TenantRepository _tenantRepository = TenantRepository();
  final UserRepository _userRepository = UserRepository();

  /// Create a new tenant with trial subscription
  Future<Tenant> createTenantWithTrialSubscription({
    required String tenantId,
    required String name,
    required String phone,
    String? email,
    required String address,
    String website = '',
    String description = '',
    Currency? defaultCurrency,
  }) async {
    try {
      // Check if tenant already exists
      if (await _tenantRepository.existsByPhone(phone)) {
        throw Exception('Tenant with this phone number already exists');
      }

      // Create default currency if not provided
      final currency = defaultCurrency ??
          Currency(
            code: 'USD',
            name: 'US Dollar',
            symbol: '\$',
            lastUpdated: DateTime.now(),
          );

      // Create trial subscription (30 days)
      final trialSubscription = TenantSubscriptionPlan(
        plan: SubscriptionPlanConstants.trialPlan,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        isActive: true,
      );

      // Create tenant preferences
      final preferences = TenantPreferences(
        authEnabled: true,
        biometricAuthEnabled: false,
        defaultCurrency: currency,
      );

      // Create tenant
      final tenant = Tenant(
        id: tenantId,
        name: name,
        phone: phone,
        email: email,
        address: address,
        website: website,
        logo: '',
        description: description,
        lastUpdated: DateTime.now(),
        preferences: preferences,
        subscriptionPlan: trialSubscription,
      );

      // Note: Database insert would be implemented here
      // await _tenantRepository.insert(tenant);

      debugPrint('Created tenant with trial subscription: ${tenant.id}');
      return tenant;
    } catch (e) {
      debugPrint('Error creating tenant: $e');
      rethrow;
    }
  }

  /// Create user and tenant during registration
  Future<User> registerUserWithTenant({
    required String userId,
    required String tenantId,
    required String userName,
    required String userPhone,
    required String tenantName,
    required String tenantAddress,
    String? userEmail,
    String tenantWebsite = '',
    String tenantDescription = '',
    String userRole = 'owner',
  }) async {
    try {
      // Check if user already exists
      if (await _userRepository.existsByPhone(userPhone)) {
        throw Exception('User with this phone number already exists');
      }

      // Create tenant with trial subscription
      final tenant = await createTenantWithTrialSubscription(
        tenantId: tenantId,
        name: tenantName,
        phone: userPhone,
        email: userEmail,
        address: tenantAddress,
        website: tenantWebsite,
        description: tenantDescription,
      );

      // Create user preferences
      final userPreferences = UserPreferences(
        notificationsEnabled: true,
        emailNotificationsEnabled: true,
        pushNotificationsEnabled: true,
        smsNotificationsEnabled: false,
        biometricAuthEnabled: false,
      );

      // Create user
      final user = User(
        tenant: tenant,
        id: userId,
        name: userName,
        phoneNumber: userPhone,
        email: userEmail,
        role: userRole,
        status: UserStatus.active,
        preferences: userPreferences,
        createdAt: DateTime.now(),
      );

      // Note: Database insert would be implemented here
      // await _userRepository.insert(user);

      debugPrint('Registered user with tenant: ${user.id}');
      return user;
    } catch (e) {
      debugPrint('Error registering user with tenant: $e');
      rethrow;
    }
  }

  /// Upgrade subscription plan
  Future<bool> upgradeSubscription({
    required String tenantId,
    required SubscriptionPlans newPlan,
    String? paymentId,
  }) async {
    try {
      final tenant = await _tenantRepository.findById(tenantId);
      if (tenant == null) {
        throw Exception('Tenant not found');
      }

      // Create new subscription plan
      final subscriptionPlan = SubscriptionPlanConstants.getPlan(newPlan);
      final newSubscription = TenantSubscriptionPlan(
        plan: subscriptionPlan,
        startDate: DateTime.now(),
        endDate: newPlan == SubscriptionPlans.premium
            ? DateTime.now()
                .add(const Duration(days: 365)) // 1 year for premium
            : DateTime.now()
                .add(const Duration(days: 365)), // 1 year for any paid plan
        isActive: true,
        paymentId: paymentId,
      );

      // Update subscription
      await _tenantRepository.updateSubscriptionPlan(tenantId, newSubscription);

      debugPrint(
          'Upgraded subscription for tenant $tenantId to ${newPlan.name}');
      return true;
    } catch (e) {
      debugPrint('Error upgrading subscription: $e');
      return false;
    }
  }

  /// Downgrade to free plan
  Future<bool> downgradeToFree(String tenantId) async {
    try {
      final freeSubscription = TenantSubscriptionPlan(
        plan: SubscriptionPlanConstants.freePlan,
        startDate: DateTime.now(),
        endDate:
            DateTime.now().add(const Duration(days: 365)), // Free is perpetual
        isActive: true,
      );

      await _tenantRepository.updateSubscriptionPlan(
          tenantId, freeSubscription);

      debugPrint('Downgraded tenant $tenantId to free plan');
      return true;
    } catch (e) {
      debugPrint('Error downgrading to free: $e');
      return false;
    }
  }

  /// Check subscription limits
  Future<bool> checkSubscriptionLimits({
    required String tenantId,
    int? accountCount,
    int? transactionCount,
    int? currencyCount,
  }) async {
    try {
      final tenant = await _tenantRepository.findById(tenantId);
      if (tenant == null) return false;

      final plan = tenant.subscriptionPlan.plan;

      // Check if subscription is active
      if (!tenant.subscriptionPlan.isCurrentlyActive) {
        return false;
      }

      // Check limits (unlimited = -1)
      if (accountCount != null &&
          plan.maxAccounts != -1 &&
          accountCount > plan.maxAccounts) {
        return false;
      }

      if (transactionCount != null &&
          plan.maxTransactions != -1 &&
          transactionCount > plan.maxTransactions) {
        return false;
      }

      if (currencyCount != null &&
          plan.maxCurrencies != -1 &&
          currencyCount > plan.maxCurrencies) {
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('Error checking subscription limits: $e');
      return false;
    }
  }

  /// Get tenant by ID
  Future<Tenant?> getTenantById(String tenantId) async {
    return await _tenantRepository.findById(tenantId);
  }

  /// Get tenant by phone (primary identifier)
  Future<Tenant?> getTenantByPhone(String phone) async {
    return await _tenantRepository.findByPhone(phone);
  }

  /// Get tenant by email
  Future<Tenant?> getTenantByEmail(String? email) async {
    return await _tenantRepository.findByEmail(email);
  }

  /// Update tenant information
  Future<bool> updateTenant(Tenant tenant) async {
    try {
      // Note: Database update would be implemented here
      // await _tenantRepository.update(tenant);
      return true;
    } catch (e) {
      debugPrint('Error updating tenant: $e');
      return false;
    }
  }

  /// Get expired tenants
  Future<List<Tenant>> getExpiredTenants() async {
    return await _tenantRepository.findExpiredTenants();
  }

  /// Get tenant statistics
  Future<Map<String, int>> getTenantStatistics() async {
    return await _tenantRepository.getTenantStatistics();
  }

  /// Check if tenant has feature access
  bool hasFeatureAccess(Tenant tenant, String feature) {
    final plan = tenant.subscriptionPlan.plan;

    switch (feature) {
      case 'api_sync':
        return plan.hasApiSync;
      case 'external_accounts':
        return plan.hasExternalAccounts;
      case 'backup_options':
        return plan.hasBackupOptions;
      case 'online_features':
        return plan.isOnline;
      default:
        return true; // Basic features are available to all
    }
  }
}
