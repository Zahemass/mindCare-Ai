import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../providers/auth_provider.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: ThemeConfig.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: ThemeConfig.spacingL),
          child: Column(
            children: [
              const SizedBox(height: ThemeConfig.spacingL),
              // Profile Header
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ThemeConfig.lightSurface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        user?.name.isNotEmpty == true ? user!.name.substring(0, 1).toUpperCase() : 'U',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: ThemeConfig.primaryTeal,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: ThemeConfig.primaryTeal,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: ThemeConfig.spacingM),
              Text(
                user?.name ?? 'Alex Johnson',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Member since ${DateFormat('MMMM yyyy').format(user?.createdAt ?? DateTime.now())}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ThemeConfig.mutedText,
                ),
              ),
              const SizedBox(height: ThemeConfig.spacingL),

              // Stats Row
              Row(
                children: [
                  Expanded(child: _buildStatCard(context, '48', 'MEDITATIONS')),
                  const SizedBox(width: ThemeConfig.spacingM),
                  Expanded(child: _buildStatCard(context, '124', 'JOURNALS')),
                  const SizedBox(width: ThemeConfig.spacingM),
                  Expanded(child: _buildStatCard(context, '12', 'DAY STREAK')),
                ],
              ),
              
              const SizedBox(height: ThemeConfig.spacingXL),
              
              // Settings Section
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'ACCOUNT SETTINGS',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: ThemeConfig.mutedText,
                  ),
                ),
              ),
              const SizedBox(height: ThemeConfig.spacingM),
              
              _buildMenuItem(
                context, 
                icon: Icons.person, 
                title: 'Personal Information',
                iconColor: const Color(0xFFE0F2F1), // Light teal background
                iconFromTheme: ThemeConfig.primaryTeal,
                onTap: () {},
              ),
              const SizedBox(height: ThemeConfig.spacingM),
              _buildMenuItem(
                context, 
                icon: Icons.track_changes, 
                title: 'Mental Health Goals',
                subtitle: 'Reduce Stress',
                iconColor: const Color(0xFFE0F2F1),
                iconFromTheme: ThemeConfig.primaryTeal,
                onTap: () {},
              ),
              const SizedBox(height: ThemeConfig.spacingM),
              _buildMenuItem(
                context, 
                icon: Icons.notifications, 
                title: 'Notifications', // Replaced Subscription Plan
                subtitle: 'On',
                iconColor: const Color(0xFFE0F2F1),
                iconFromTheme: ThemeConfig.primaryTeal,
                onTap: () {},
              ),
              const SizedBox(height: ThemeConfig.spacingM),
              _buildMenuItem(
                context, 
                icon: Icons.security, 
                title: 'Privacy & Security',
                iconColor: const Color(0xFFE0F2F1),
                iconFromTheme: ThemeConfig.primaryTeal,
                onTap: () {},
              ),
              
              const SizedBox(height: ThemeConfig.spacingXL),
              
              // Logout Button
               _buildMenuItem(
                context, 
                icon: Icons.logout, 
                title: 'Log Out',
                iconColor: const Color(0xFFF5F6FA),
                iconFromTheme: ThemeConfig.mutedText,
                hideArrow: true,
                onTap: () async {
                  await authProvider.logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
              ),
              const SizedBox(height: ThemeConfig.spacingXL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: ThemeConfig.spacingM),
      decoration: BoxDecoration(
        color: ThemeConfig.lightSurface,
        borderRadius: BorderRadius.circular(ThemeConfig.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: ThemeConfig.primaryTeal,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required Color iconColor,
    required Color iconFromTheme,
    required VoidCallback onTap,
    bool hideArrow = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ThemeConfig.radiusM),
      child: Container(
        padding: const EdgeInsets.all(ThemeConfig.spacingM),
        decoration: BoxDecoration(
          color: ThemeConfig.lightSurface,
          borderRadius: BorderRadius.circular(ThemeConfig.radiusM),
          border: Border.all(
            color: Colors.grey.withOpacity(0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconFromTheme,
                size: 22,
              ),
            ),
            const SizedBox(width: ThemeConfig.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ThemeConfig.primaryTeal,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!hideArrow)
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: ThemeConfig.mutedText,
              ),
          ],
        ),
      ),
    );
  }
}
