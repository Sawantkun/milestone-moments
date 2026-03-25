import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../state/child_provider.dart';
import '../../theme/app_colors.dart';
import '../../models/child_model.dart';
import '../../models/milestone_model.dart';
import '../../widgets/child_avatar.dart';
import '../../models/mood_entry_model.dart';
import '../../widgets/milestone_card.dart';
import '../../widgets/glassmorphic_card.dart';
import '../../widgets/empty_state.dart';
import '../child/activities_screen.dart';

class ChildDetailScreen extends StatefulWidget {
  const ChildDetailScreen({super.key});

  @override
  State<ChildDetailScreen> createState() => _ChildDetailScreenState();
}

class _ChildDetailScreenState extends State<ChildDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final childProvider = context.watch<ChildProvider>();
    final child = childProvider.selectedChild;

    if (child == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Child Detail')),
        body: const EmptyState(
          icon: Icons.child_care_rounded,
          title: 'No child selected',
          subtitle: 'Please select a child from the home screen',
        ),
      );
    }

    // Total expanded height = toolbar (56) + avatar (80) + gaps (20) + name (30) + age (22) + bottom clearance for TabBar (52) + top status-bar padding (~44) ≈ 304.
    // We use a fixed 300 and rely on explicit SizedBoxes inside to distribute space cleanly.
    const double expandedHeight = 300;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: expandedHeight,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: BoxDecoration(
                  gradient: child.gender == 'female'
                      ? AppColors.primaryGradient
                      : AppColors.purpleTeal,
                ),
                child: Column(
                  children: [
                    // ── top clearance: status bar + toolbar (back button row) ──
                    const SizedBox(height: kToolbarHeight + 44),

                    // ── Avatar (photo or initials) ──
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: Colors.white.withOpacity(0.6), width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ChildAvatar(
                        child: child,
                        size: 84,
                        borderRadius: 26,
                        showEditBadge: true,
                        onTap: () => Navigator.of(context).pushNamed(
                          '/add-child',
                          arguments: child,
                        ),
                      ),
                    ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),

                    const SizedBox(height: 10),

                    // ── Name ──
                    Text(
                      child.name,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ).animate().fadeIn(delay: 150.ms),

                    const SizedBox(height: 2),

                    // ── Age ──
                    Text(
                      child.ageString,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ).animate().fadeIn(delay: 200.ms),

                    // ── bottom clearance: TabBar height ──
                    const SizedBox(height: kTextTabBarHeight),
                  ],
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(kTextTabBarHeight),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                indicatorColor: Colors.white,
                isScrollable: true,
                tabs: const [
                  Tab(text: 'Milestones'),
                  Tab(text: 'Health'),
                  Tab(text: 'Mood'),
                  Tab(text: 'Activities'),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _MilestonesTab(child: child, childProvider: childProvider),
            _HealthSummaryTab(child: child, childProvider: childProvider),
            _MoodTab(child: child, childProvider: childProvider),
            ActivitiesScreen(embeddedChild: child),
          ],
        ),
      ),
    );
  }
}

class _MilestonesTab extends StatelessWidget {
  final ChildModel child;
  final ChildProvider childProvider;

  const _MilestonesTab({required this.child, required this.childProvider});

  @override
  Widget build(BuildContext context) {
    final milestones = childProvider.milestonesForChild(child.id);

    if (milestones.isEmpty) {
      return EmptyState(
        icon: Icons.star_outline_rounded,
        title: 'No milestones yet',
        subtitle: 'Start recording ${child.name}\'s precious moments',
        actionLabel: 'Add Milestone',
        onAction: () => Navigator.of(context).pushNamed('/add-milestone'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: milestones.length,
      itemBuilder: (context, idx) => Padding(
        padding: const EdgeInsets.only(bottom: 0),
        child: MilestoneCard(
          milestone: milestones[idx],
          showTimeline: true,
          isLast: idx == milestones.length - 1,
        ).animate().fadeIn(delay: (idx * 50).ms),
      ),
    );
  }
}

class _HealthSummaryTab extends StatelessWidget {
  final ChildModel child;
  final ChildProvider childProvider;

  const _HealthSummaryTab({required this.child, required this.childProvider});

  @override
  Widget build(BuildContext context) {
    final records = childProvider.healthRecordsForChild(child.id);
    final latest = records.isNotEmpty ? records.first : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (latest != null)
            GlassmorphicCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Latest Measurements', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _StatBox(
                        label: 'Height',
                        value: latest.heightCm != null ? '${latest.heightCm!.toStringAsFixed(1)} cm' : '—',
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      _StatBox(
                        label: 'Weight',
                        value: latest.weightKg != null ? '${latest.weightKg!.toStringAsFixed(1)} kg' : '—',
                        color: AppColors.pink,
                      ),
                      const SizedBox(width: 12),
                      _StatBox(
                        label: 'Head Circ',
                        value: latest.headCircumferenceCm != null ? '${latest.headCircumferenceCm!.toStringAsFixed(1)} cm' : '—',
                        color: AppColors.teal,
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 12),
          if (records.isEmpty)
            const EmptyState(
              icon: Icons.monitor_heart_outlined,
              title: 'No health records',
              subtitle: 'Go to the Health tab to add measurements',
            ),
          ...records.take(5).map((r) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.favorite_outline_rounded, color: AppColors.pink),
                  title: Text(
                    '${r.heightCm?.toStringAsFixed(0) ?? '—'} cm  •  ${r.weightKg?.toStringAsFixed(1) ?? '—'} kg',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  subtitle: Text(
                    '${r.date.day}/${r.date.month}/${r.date.year}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ).animate().fadeIn()),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBox({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
            Text(label, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondaryLight)),
          ],
        ),
      ),
    );
  }
}

class _MoodTab extends StatelessWidget {
  final ChildModel child;
  final ChildProvider childProvider;

  const _MoodTab({required this.child, required this.childProvider});

  @override
  Widget build(BuildContext context) {
    final entries = childProvider.moodEntriesForChild(child.id);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GlassmorphicCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Log Today\'s Mood', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ['😢', '😕', '😐', '😊', '😄'].map((e) => GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed('/mood-log'),
                    child: Text(e, style: const TextStyle(fontSize: 32)),
                  )).toList(),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 16),

          if (entries.isEmpty)
            const EmptyState(
              icon: Icons.emoji_emotions_outlined,
              title: 'No mood entries yet',
              subtitle: 'Track your child\'s daily mood above',
            )
          else
            ...entries.take(7).toList().asMap().entries.map((e) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Text(e.value.mood.emoji, style: const TextStyle(fontSize: 28)),
                    title: Text(e.value.mood.displayName, style: Theme.of(context).textTheme.titleSmall),
                    subtitle: e.value.notes != null ? Text(e.value.notes!, maxLines: 1, overflow: TextOverflow.ellipsis) : null,
                    trailing: Text(
                      '${e.value.date.day}/${e.value.date.month}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ).animate().fadeIn(delay: (e.key * 50).ms)),
        ],
      ),
    );
  }
}
