import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../state/auth_provider.dart';
import '../../state/child_provider.dart';
import '../../theme/app_colors.dart';
import '../../models/child_model.dart';
import '../../models/milestone_model.dart';
import '../../models/reminder_model.dart';
import '../../widgets/glassmorphic_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/milestone_card.dart';
import '../../widgets/reminder_card.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final childProvider = context.watch<ChildProvider>();
    final userName = auth.user?.name.split(' ').first ?? 'Parent';
    final children = childProvider.children;
    final selected = childProvider.selectedChild;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 116,
            floating: false,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${_greeting()},',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.85),
                                ),
                              ),
                              Text(
                                userName,
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                DateFormat('EEEE, MMMM d').format(DateTime.now()),
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.75),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              userName.isNotEmpty ? userName[0].toUpperCase() : 'P',
                              style: GoogleFonts.poppins(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Child selector
                  if (children.isNotEmpty)
                    _ChildSelectorRow(children: children, selected: selected, childProvider: childProvider)
                        .animate()
                        .fadeIn(delay: 100.ms)
                        .slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 16),

                  // Hero child card
                  if (selected != null)
                    _HeroChildCard(child: selected, childProvider: childProvider)
                        .animate()
                        .fadeIn(delay: 200.ms)
                        .slideY(begin: 0.2, end: 0),

                  if (selected == null && children.isEmpty)
                    _NoChildCard()
                        .animate()
                        .fadeIn(delay: 200.ms),

                  const SizedBox(height: 20),

                  // Quick Mood
                  if (selected != null)
                    _QuickMoodSection(child: selected)
                        .animate()
                        .fadeIn(delay: 300.ms)
                        .slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 20),

                  // Upcoming reminders
                  SectionHeader(
                    title: 'Upcoming Reminders',
                    onSeeAll: () {},
                  ).animate().fadeIn(delay: 350.ms),
                  const SizedBox(height: 8),
                  _UpcomingReminders(childProvider: childProvider)
                      .animate()
                      .fadeIn(delay: 400.ms),

                  const SizedBox(height: 20),

                  // Recent milestones
                  SectionHeader(
                    title: 'Recent Milestones',
                    onSeeAll: () {},
                  ).animate().fadeIn(delay: 450.ms),
                  const SizedBox(height: 8),
                  _RecentMilestones(selected: selected, childProvider: childProvider)
                      .animate()
                      .fadeIn(delay: 500.ms),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed('/add-milestone'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Milestone'),
      ).animate().scale(delay: 600.ms, duration: 300.ms, curve: Curves.elasticOut),
    );
  }
}

class _ChildSelectorRow extends StatelessWidget {
  final List<ChildModel> children;
  final ChildModel? selected;
  final ChildProvider childProvider;

  const _ChildSelectorRow({
    required this.children,
    required this.selected,
    required this.childProvider,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: children.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, idx) {
          final child = children[idx];
          final isSelected = selected?.id == child.id;
          return GestureDetector(
            onTap: () => childProvider.selectChild(child.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected ? AppColors.primaryGradient : null,
                color: isSelected ? null : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected ? Colors.transparent : AppColors.dividerLight,
                ),
                boxShadow: isSelected
                    ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]
                    : null,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: isSelected ? Colors.white.withOpacity(0.3) : AppColors.primary.withOpacity(0.15),
                    child: Text(
                      child.name[0].toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    child.name,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HeroChildCard extends StatelessWidget {
  final ChildModel child;
  final ChildProvider childProvider;

  const _HeroChildCard({required this.child, required this.childProvider});

  @override
  Widget build(BuildContext context) {
    final milestones = childProvider.milestonesForChild(child.id);
    final lastMilestone = milestones.isNotEmpty ? milestones.first : null;

    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/child-detail'),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  child.name[0].toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    child.name,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    child.ageString,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                  if (lastMilestone != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '⭐ ${lastMilestone.title}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 28),
          ],
        ),
      ),
    );
  }
}

class _NoChildCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.child_care_rounded, size: 48, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(
            'Add your first child',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking milestones, health, and more.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pushNamed('/add-child'),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Child'),
          ),
        ],
      ),
    );
  }
}

class _QuickMoodSection extends StatelessWidget {
  final ChildModel child;

  const _QuickMoodSection({required this.child});

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How is ${child.name} feeling today?',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['😢', '😕', '😐', '😊', '😄'].map((emoji) {
              return GestureDetector(
                onTap: () => Navigator.of(context).pushNamed('/mood-log'),
                child: Text(emoji, style: const TextStyle(fontSize: 30)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _UpcomingReminders extends StatelessWidget {
  final ChildProvider childProvider;

  const _UpcomingReminders({required this.childProvider});

  @override
  Widget build(BuildContext context) {
    final reminders = childProvider.upcomingReminders.take(2).toList();
    if (reminders.isEmpty) {
      return GlassmorphicCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded, color: AppColors.teal),
            const SizedBox(width: 12),
            Text(
              'No upcoming reminders',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }
    return Column(
      children: reminders.map((r) {
        final child = childProvider.children.firstWhere(
          (c) => c.id == r.childId,
          orElse: () => ChildModel(id: '', name: 'Unknown', birthDate: DateTime.now(), gender: 'other'),
        );
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ReminderCard(
            reminder: r,
            childName: child.name,
            onToggle: () => childProvider.toggleReminderComplete(r.id),
          ),
        );
      }).toList(),
    );
  }
}

class _RecentMilestones extends StatelessWidget {
  final ChildModel? selected;
  final ChildProvider childProvider;

  const _RecentMilestones({required this.selected, required this.childProvider});

  @override
  Widget build(BuildContext context) {
    if (selected == null) {
      return const SizedBox.shrink();
    }
    final milestones = childProvider.milestonesForChild(selected!.id).take(3).toList();
    if (milestones.isEmpty) {
      return GlassmorphicCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.star_outline_rounded, size: 36, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              'No milestones yet',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Tap + to record your first milestone!',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    }
    return Column(
      children: milestones
          .map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: MilestoneCard(milestone: m, showTimeline: false),
              ))
          .toList(),
    );
  }
}
