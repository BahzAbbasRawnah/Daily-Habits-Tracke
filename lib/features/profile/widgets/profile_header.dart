import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:daily_habits/config/theme.dart';
import 'package:daily_habits/features/profile/models/user_model.dart';
import 'package:daily_habits/shared/widgets/custom_card.dart';

/// Widget for displaying the profile header
class ProfileHeader extends StatelessWidget {
  final User user;
  final VoidCallback onEditPressed;
  
  const ProfileHeader({
    Key? key,
    required this.user,
    required this.onEditPressed,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Profile image and edit button
          Stack(
            alignment: Alignment.center,
            children: [
              // Profile image
              _buildProfileImage(),
              
              // Edit button
              GestureDetector(
                onTap: onEditPressed,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: AppTheme.primaryDarkColor,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // User name
          Text(
            user.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          
          // User email
          Text(
            user.email ?? 'No email provided',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          
          // User status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: user.status.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  user.status.translationKey.tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build profile image
  Widget _buildProfileImage() {
    if (user.profileImageUrl != null) {
      return CircleAvatar(
        radius: 50,
        backgroundImage: NetworkImage(user.profileImageUrl!),
      );
    } else {
      return CircleAvatar(
        radius: 50,
        backgroundColor: Colors.white.withOpacity(0.2),
        child: Text(
          _getInitials(user.name),
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }
  }
  
  /// Get initials from name
  String _getInitials(String name) {
    final nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}';
    } else if (name.isNotEmpty) {
      return name[0];
    } else {
      return '';
    }
  }
}

/// Widget for displaying the profile stats
class ProfileStats extends StatelessWidget {
  final int transactionsCount;
  final double goldBalance;
  final double cashBalance;
  
  const ProfileStats({
    Key? key,
    required this.transactionsCount,
    required this.goldBalance,
    required this.cashBalance,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Row(
        children: [
          // Transactions count
          Expanded(
            child: _buildStatItem(
              context,
              Icons.swap_horiz,
              transactionsCount.toString(),
              'transactions'.tr(),
            ),
          ),
          
          // Vertical divider
          Container(
            height: 40,
            width: 1,
            color: Colors.grey.withOpacity(0.3),
          ),
          
          // Gold balance
          Expanded(
            child: _buildStatItem(
              context,
              Icons.track_changes,
              '${goldBalance.toStringAsFixed(0)}',
              'totalHabits'.tr(),
            ),
          ),
          
          // Vertical divider
          Container(
            height: 40,
            width: 1,
            color: Colors.grey.withOpacity(0.3),
          ),
          
          // Cash balance
          Expanded(
            child: _buildStatItem(
              context,
              Icons.local_fire_department,
              '${cashBalance.toStringAsFixed(0)}',
              'currentStreak'.tr(),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build stat item
  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryDarkColor,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[300]
                : Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
