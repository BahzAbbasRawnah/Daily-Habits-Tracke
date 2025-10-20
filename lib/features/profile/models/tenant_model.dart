/// Basic Currency model for tenant preferences
class Currency {
  final String code;
  final String name;
  final String symbol;
  final bool isDefault;
  final bool isActive;
  final int decimalPlaces;
  final DateTime lastUpdated;

  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
    this.isDefault = false,
    this.isActive = true,
    this.decimalPlaces = 2,
    required this.lastUpdated,
  });

  /// Create from JSON
  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      code: json['code'] as String,
      name: json['name'] as String,
      symbol: json['symbol'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      decimalPlaces: json['decimalPlaces'] as int? ?? 2,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'symbol': symbol,
      'isDefault': isDefault,
      'isActive': isActive,
      'decimalPlaces': decimalPlaces,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

/// Subscription plans for a tenant
enum SubscriptionPlans {
  free,
  trial,
  premium;

  /// Get subscription plan by name
  static SubscriptionPlan getByName(String name) {
    switch (name) {
      case 'free':
        return SubscriptionPlanConstants.freePlan;
      case 'trial':
        return SubscriptionPlanConstants.trialPlan;
      case 'premium':
        return SubscriptionPlanConstants.premiumPlan;
      default:
        return SubscriptionPlanConstants.freePlan;
    }
  }
}

class SubscriptionPlan {
  final SubscriptionPlans plan;
  final String description;
  final String name;
  final int maxAccounts;
  final int maxTransactions;
  final int maxCurrencies;
  final bool isOnline;
  final bool hasApiSync;
  final bool hasExternalAccounts;
  final bool hasBackupOptions;
  final double? monthlyPrice;

  const SubscriptionPlan({
    required this.plan,
    required this.description,
    required this.name,
    required this.maxAccounts,
    required this.maxTransactions,
    required this.maxCurrencies,
    required this.isOnline,
    this.hasApiSync = false,
    this.hasExternalAccounts = false,
    this.hasBackupOptions = false,
    this.monthlyPrice,
  });

  /// Check if plan has unlimited usage
  bool get hasUnlimitedUsage => maxAccounts == -1 && maxTransactions == -1;

  /// Check if plan is paid
  bool get isPaid => monthlyPrice != null && monthlyPrice! > 0;

  /// Check if plan is free
  bool get isFree => monthlyPrice == null || monthlyPrice == 0;
}

/// Constants for subscription plans
class SubscriptionPlanConstants {
  static const SubscriptionPlan freePlan = SubscriptionPlan(
    plan: SubscriptionPlans.free,
    name: 'Free',
    description: 'Limited offline functionality with local storage only',
    maxAccounts: 5,
    maxTransactions: 100,
    maxCurrencies: 3,
    isOnline: false,
    hasApiSync: false,
    hasExternalAccounts: false,
    hasBackupOptions: true,
    monthlyPrice: 0.0,
  );

  static const SubscriptionPlan trialPlan = SubscriptionPlan(
    plan: SubscriptionPlans.trial,
    name: 'Trial',
    description: 'Full functionality for 30 days with API synchronization',
    maxAccounts: -1, // Unlimited
    maxTransactions: -1, // Unlimited
    maxCurrencies: -1, // Unlimited
    isOnline: true,
    hasApiSync: true,
    hasExternalAccounts: true,
    hasBackupOptions: true,
    monthlyPrice: 0.0,
  );

  static const SubscriptionPlan premiumPlan = SubscriptionPlan(
    plan: SubscriptionPlans.premium,
    name: 'Premium',
    description:
        'Full functionality with API synchronization and unlimited usage',
    maxAccounts: -1, // Unlimited
    maxTransactions: -1, // Unlimited
    maxCurrencies: -1, // Unlimited
    isOnline: true,
    hasApiSync: true,
    hasExternalAccounts: true,
    hasBackupOptions: true,
    monthlyPrice: 29.99,
  );

  /// Get all available plans
  static List<SubscriptionPlan> get allPlans =>
      [freePlan, trialPlan, premiumPlan];

  /// Get plan by type
  static SubscriptionPlan getPlan(SubscriptionPlans planType) {
    switch (planType) {
      case SubscriptionPlans.free:
        return freePlan;
      case SubscriptionPlans.trial:
        return trialPlan;
      case SubscriptionPlans.premium:
        return premiumPlan;
    }
  }
}

// Tenant Subscription Plans
class TenantSubscriptionPlan {
  final SubscriptionPlan plan;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final String? paymentId;

  const TenantSubscriptionPlan({
    required this.plan,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.paymentId,
  });

  /// Create a copy with updated values
  TenantSubscriptionPlan copyWith({
    SubscriptionPlan? plan,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    String? paymentId,
  }) {
    return TenantSubscriptionPlan(
      plan: plan ?? this.plan,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      paymentId: paymentId ?? this.paymentId,
    );
  }

  /// Check if subscription is currently active
  bool get isCurrentlyActive {
    final now = DateTime.now();
    return isActive && now.isAfter(startDate) && now.isBefore(endDate);
  }

  /// Check if subscription has expired
  bool get isExpired {
    final now = DateTime.now();
    return now.isAfter(endDate);
  }

  /// Get days remaining in subscription
  int get daysRemaining {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'plan': plan.plan.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
      'paymentId': paymentId,
    };
  }

  /// Create from JSON
  factory TenantSubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return TenantSubscriptionPlan(
      plan: SubscriptionPlans.getByName(json['plan']),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      isActive: json['isActive'] ?? true,
      paymentId: json['paymentId'],
    );
  }
}

/// Model representing a shop information
class Tenant {
  final String id;
  final String name;
  final String phone; // Primary identifier
  final String? email; // Optional
  final String address;
  final String website;
  final String logo;
  final String description;
  final DateTime lastUpdated;
  final TenantPreferences preferences;
  final TenantSubscriptionPlan subscriptionPlan;

  const Tenant({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.address,
    required this.website,
    required this.logo,
    required this.description,
    required this.lastUpdated,
    required this.preferences,
    required this.subscriptionPlan,
  });

  // Create a copy of this shop with the given fields replaced with the new values
  Tenant copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? website,
    String? logo,
    String? description,
    DateTime? lastUpdated,
    TenantPreferences? preferences,
    TenantSubscriptionPlan? subscriptionPlan,
  }) {
    return Tenant(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      website: website ?? this.website,
      logo: logo ?? this.logo,
      description: description ?? this.description,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      preferences: preferences ?? this.preferences,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
    );
  }

  /// Convert shop to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'website': website,
      'logo': logo,
      'description': description,
      'lastUpdated': lastUpdated.toIso8601String(),
      'preferences': preferences.toJson(),
      'subscriptionPlan': subscriptionPlan.toJson(),
    };
  }

  /// Create shop from JSON
  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      website: json['website'],
      logo: json['logo'],
      description: json['description'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
      preferences: TenantPreferences.fromJson(json['preferences']),
      subscriptionPlan:
          TenantSubscriptionPlan.fromJson(json['subscriptionPlan']),
    );
  }
}
////////// Tenant Preferences

class TenantPreferences {
  final bool biometricAuthEnabled;
  final bool authEnabled;
  final Currency defaultCurrency;

  const TenantPreferences({
    required this.authEnabled,
    required this.biometricAuthEnabled,
    required this.defaultCurrency,
  });

  /// Create a copy of this preferences with the given fields replaced with the new values
  TenantPreferences copyWith({
    bool? authEnabled,
    bool? biometricAuthEnabled,
    Currency? defaultCurrency,
  }) {
    return TenantPreferences(
      authEnabled: authEnabled ?? this.authEnabled,
      biometricAuthEnabled: biometricAuthEnabled ?? this.biometricAuthEnabled,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
    );
  }

  /// Convert preferences to JSON
  Map<String, dynamic> toJson() {
    return {
      'authEnabled': authEnabled,
      'biometricAuthEnabled': biometricAuthEnabled,
      'defaultCurrency': defaultCurrency.code,
    };
  }

  /// Create preferences from JSON
  factory TenantPreferences.fromJson(Map<String, dynamic> json) {
    return TenantPreferences(
      authEnabled: json['authEnabled'] ?? false,
      biometricAuthEnabled: json['biometricAuthEnabled'] ?? false,
      defaultCurrency: Currency.fromJson(json['defaultCurrency']),
    );
  }
}
