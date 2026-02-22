import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../providers/auth_provider.dart';
import '../../providers/mood_provider.dart';
import '../../providers/journal_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? ThemeConfig.darkBackground : ThemeConfig.lightBackground;
    final cardColor = isDark ? ThemeConfig.darkSurface : ThemeConfig.lightSurface;
    final textColor = isDark ? ThemeConfig.darkTextPrimary : ThemeConfig.darkText;
    final mutedColor = isDark ? ThemeConfig.darkTextSecondary : ThemeConfig.mutedText;
    final borderColor = isDark ? ThemeConfig.darkBorder : Colors.grey.withOpacity(0.1);

    return Scaffold(
      backgroundColor: bgColor,
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
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [ThemeConfig.darkSurface, ThemeConfig.darkCard]
                            : [ThemeConfig.lightSurface, const Color(0xFFF0F0F0)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? ThemeConfig.primaryTeal.withOpacity(0.15)
                              : Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        user?.name.isNotEmpty == true ? user!.name.substring(0, 1).toUpperCase() : 'U',
                        style: GoogleFonts.montserrat(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: ThemeConfig.primaryTeal,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: ThemeConfig.primaryTeal,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: ThemeConfig.primaryTeal.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
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
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Member since ${DateFormat('MMMM yyyy').format(user?.createdAt ?? DateTime.now())}',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: mutedColor,
                ),
              ),
              const SizedBox(height: ThemeConfig.spacingL),

              // Stats Row
              Row(
                children: [
                  Expanded(child: _buildStatCard(context, '0', 'MEDITATIONS', isDark)),
                  const SizedBox(width: ThemeConfig.spacingM),
                  Expanded(child: Consumer<JournalProvider>(
                    builder: (context, jp, _) => _buildStatCard(context, '${jp.entries.length}', 'JOURNALS', isDark)
                  )),
                  const SizedBox(width: ThemeConfig.spacingM),
                  Expanded(child: Consumer<MoodProvider>(
                    builder: (context, mp, _) => _buildStatCard(context, '${mp.getMoodStreak()}', 'DAY STREAK', isDark)
                  )),
                ],
              ),
              
              const SizedBox(height: ThemeConfig.spacingXL),
              
              // Settings Section
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'ACCOUNT SETTINGS',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: mutedColor,
                  ),
                ),
              ),
              const SizedBox(height: ThemeConfig.spacingM),
              
              _buildMenuItem(
                context, 
                icon: Icons.person, 
                title: 'Update Profile',
                isDark: isDark,
                onTap: () => _showUpdateNameDialog(context),
              ),
              const SizedBox(height: ThemeConfig.spacingS),
              _buildMenuItem(
                context, 
                icon: Icons.track_changes, 
                title: 'Mental Health Goals',
                subtitle: user?.mentalHealthGoals.isNotEmpty == true ? user?.mentalHealthGoals.first : 'Set Goals',
                isDark: isDark,
                onTap: () => _showSetGoalsDialog(context),
              ),
              const SizedBox(height: ThemeConfig.spacingS),
              _buildMenuItem(
                context, 
                icon: Icons.notifications, 
                title: 'App Preferences',
                subtitle: 'Manage theme & alerts',
                isDark: isDark,
                onTap: () => _showPreferencesDialog(context),
              ),
              const SizedBox(height: ThemeConfig.spacingS),
              _buildMenuItem(
                context, 
                icon: Icons.feedback_outlined, 
                title: 'Send Feedback',
                isDark: isDark,
                onTap: () => _showFeedbackDialog(context),
              ),
              const SizedBox(height: ThemeConfig.spacingS),
              _buildMenuItem(
                context, 
                icon: Icons.delete_outline, 
                title: 'Delete Account',
                isDark: isDark,
                isDestructive: true,
                onTap: () => _showDeleteAccountConfirm(context),
              ),
              
              const SizedBox(height: ThemeConfig.spacingXL),
              
              // Logout Button
              _buildMenuItem(
                context, 
                icon: Icons.logout, 
                title: 'Log Out',
                isDark: isDark,
                isLogout: true,
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

  void _showUpdateNameDialog(BuildContext context) {
    final controller = TextEditingController(text: context.read<AuthProvider>().currentUser?.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Profile'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Full Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await context.read<AuthProvider>().updateProfile(
                context.read<AuthProvider>().currentUser!.copyWith(name: controller.text),
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSetGoalsDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Goals'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'e.g. Reduce daily stress'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await ApiService().setGoals([controller.text]);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Add Goal'),
          ),
        ],
      ),
    );
  }

  void _showPreferencesDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (stfContext, setState) {
            final themeProvider = stfContext.watch<ThemeProvider>();
            final currentlyDark = themeProvider.themeMode == ThemeMode.dark;
            
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.settings, color: ThemeConfig.primaryTeal, size: 22),
                  const SizedBox(width: 10),
                  const Text('App Preferences'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPreferenceSwitch(
                    icon: Icons.notifications_active_rounded,
                    title: 'Notifications',
                    subtitle: 'Daily reminders & alerts',
                    value: true,
                    onChanged: (v) {},
                    isDark: isDark,
                  ),
                  const SizedBox(height: 8),
                  _buildPreferenceSwitch(
                    icon: Icons.dark_mode_rounded,
                    title: 'Dark Mode',
                    subtitle: currentlyDark ? 'Dark theme active' : 'Light theme active',
                    value: currentlyDark,
                    onChanged: (v) {
                      themeProvider.toggleTheme();
                    },
                    isDark: isDark,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    'Done',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                      color: ThemeConfig.primaryTeal,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPreferenceSwitch({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? ThemeConfig.darkCard : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ThemeConfig.primaryTeal.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: ThemeConfig.primaryTeal, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? ThemeConfig.darkTextPrimary : ThemeConfig.darkText,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    color: isDark ? ThemeConfig.darkTextSecondary : ThemeConfig.mutedText,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: ThemeConfig.primaryTeal,
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Tell us what you think...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await ApiService().submitFeedback(
                  feedback: controller.text,
                  rating: 5,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thank you for your feedback!')));
                }
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure? This action is permanent and all your data will be lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await ApiService().deleteAccount();
              if (context.mounted) {
                context.go('/login');
              }
            },
            style: TextButton.styleFrom(foregroundColor: ThemeConfig.errorRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: ThemeConfig.spacingM),
      decoration: BoxDecoration(
        color: isDark ? ThemeConfig.darkSurface : ThemeConfig.lightSurface,
        borderRadius: BorderRadius.circular(ThemeConfig.radiusM),
        border: isDark ? Border.all(color: ThemeConfig.darkBorder, width: 1) : null,
        boxShadow: isDark
            ? [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))]
            : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: ThemeConfig.primaryTeal,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isDark ? ThemeConfig.darkTextSecondary : ThemeConfig.mutedText,
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
    required bool isDark,
    required VoidCallback onTap,
    bool isDestructive = false,
    bool isLogout = false,
  }) {
    final Color iconBg;
    final Color iconFg;

    if (isDestructive) {
      iconBg = isDark ? ThemeConfig.errorRed.withOpacity(0.15) : const Color(0xFFFFEBEE);
      iconFg = ThemeConfig.errorRed;
    } else if (isLogout) {
      iconBg = isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFF5F6FA);
      iconFg = isDark ? ThemeConfig.darkTextSecondary : ThemeConfig.mutedText;
    } else {
      iconBg = isDark ? ThemeConfig.primaryTeal.withOpacity(0.12) : const Color(0xFFE0F2F1);
      iconFg = ThemeConfig.primaryTeal;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ThemeConfig.radiusM),
      child: Container(
        padding: const EdgeInsets.all(ThemeConfig.spacingM),
        decoration: BoxDecoration(
          color: isDark ? ThemeConfig.darkSurface : ThemeConfig.lightSurface,
          borderRadius: BorderRadius.circular(ThemeConfig.radiusM),
          border: Border.all(
            color: isDark ? ThemeConfig.darkBorder : Colors.grey.withOpacity(0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.15) : Colors.black.withOpacity(0.02),
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
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconFg,
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
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? ThemeConfig.darkTextPrimary : ThemeConfig.darkText,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        color: ThemeConfig.primaryTeal,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!isLogout)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isDark ? ThemeConfig.darkTextSecondary : ThemeConfig.mutedText,
              ),
          ],
        ),
      ),
    );
  }
}
