import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../state/auth_provider.dart';
import '../../state/child_provider.dart';
import '../../state/theme_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glassmorphic_card.dart';

class MoreTab extends StatelessWidget {
  const MoreTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final childProvider = context.watch<ChildProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header
            GlassmorphicCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: Text(
                        user != null && user.name.isNotEmpty ? user.name[0].toUpperCase() : 'P',
                        style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Parent',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          user?.email ?? '',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${childProvider.children.length} child${childProvider.children.length == 1 ? '' : 'ren'}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 20),

            // Settings section
            _SectionTitle(title: 'Settings').animate().fadeIn(delay: 150.ms),
            const SizedBox(height: 8),
            GlassmorphicCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  SwitchListTile(
                    value: themeProvider.isDark,
                    onChanged: (_) => themeProvider.toggleTheme(),
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Switch between light and dark theme'),
                    secondary: Icon(
                      themeProvider.isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      color: AppColors.primary,
                    ),
                    activeColor: AppColors.primary,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.notifications_outlined, color: AppColors.primary),
                    title: const Text('Notifications'),
                    subtitle: const Text('Manage reminder notifications'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notification settings coming soon')),
                      );
                    },
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(16))),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 20),

            // Children section
            _SectionTitle(title: 'My Children').animate().fadeIn(delay: 250.ms),
            const SizedBox(height: 8),
            GlassmorphicCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ...childProvider.children.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final child = entry.value;
                    return Column(
                      children: [
                        if (idx > 0) const Divider(height: 1),
                        ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                child.name[0].toUpperCase(),
                                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                            ),
                          ),
                          title: Text(child.name, style: Theme.of(context).textTheme.titleMedium),
                          subtitle: Text(child.ageString, style: Theme.of(context).textTheme.bodySmall),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
                                onPressed: () {
                                  childProvider.selectChild(child.id);
                                  Navigator.of(context).pushNamed('/add-child', arguments: child);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.redAccent),
                                onPressed: () => _confirmDeleteChild(context, child.id, child.name, childProvider),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                  if (childProvider.children.isNotEmpty) const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add_rounded, color: AppColors.primary),
                    ),
                    title: Text('Add Child', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.primary)),
                    onTap: () => Navigator.of(context).pushNamed('/add-child'),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 20),

            // Reports
            _SectionTitle(title: 'Reports').animate().fadeIn(delay: 350.ms),
            const SizedBox(height: 8),
            GlassmorphicCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.teal),
                ),
                title: const Text('Generate PDF Report'),
                subtitle: const Text('Export your child\'s progress'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.of(context).pushNamed('/reports'),
              ),
            ).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: 20),

            // About
            _SectionTitle(title: 'About').animate().fadeIn(delay: 450.ms),
            const SizedBox(height: 8),
            GlassmorphicCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded, color: AppColors.primary),
                    title: const Text('About MilestoneMoments'),
                    subtitle: const Text('Version 1.0.0'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showAboutDialog(context),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                    title: const Text('Sign Out', style: TextStyle(color: Colors.redAccent)),
                    onTap: () => _confirmSignOut(context, auth),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(16))),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 500.ms),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteChild(BuildContext context, String childId, String name, ChildProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete $name?'),
        content: Text('This will permanently delete all data for $name including milestones, health records, and reminders.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.deleteChild(childId);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign Out?'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await auth.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'MilestoneMoments',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.child_care_rounded, color: Colors.white, size: 32),
      ),
      children: [
        const Text('A premium parenting & child development tracker. Track milestones, health, and growth with beautiful visualizations.'),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondaryLight,
        letterSpacing: 0.5,
      ),
    );
  }
}
