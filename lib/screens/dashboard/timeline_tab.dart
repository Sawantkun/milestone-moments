import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../state/child_provider.dart';
import '../../theme/app_colors.dart';
import '../../models/milestone_model.dart';
import '../../widgets/milestone_card.dart';
import '../../widgets/empty_state.dart';

class TimelineTab extends StatefulWidget {
  const TimelineTab({super.key});

  @override
  State<TimelineTab> createState() => _TimelineTabState();
}

class _TimelineTabState extends State<TimelineTab> {
  MilestoneCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final childProvider = context.watch<ChildProvider>();
    final children = childProvider.children;
    final selected = childProvider.selectedChild;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Milestone Timeline'),
        actions: [
          if (children.length > 1)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: DropdownButton<String>(
                value: selected?.id,
                underline: const SizedBox.shrink(),
                icon: const Icon(Icons.expand_more_rounded),
                items: children
                    .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                    .toList(),
                onChanged: (id) {
                  if (id != null) childProvider.selectChild(id);
                },
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Category filter chips
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    isSelected: _selectedCategory == null,
                    onTap: () => setState(() => _selectedCategory = null),
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  ...MilestoneCategory.values.map((cat) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _FilterChip(
                          label: cat.displayName,
                          isSelected: _selectedCategory == cat,
                          onTap: () => setState(() => _selectedCategory = _selectedCategory == cat ? null : cat),
                          color: _categoryColor(cat),
                        ),
                      )),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 100.ms),

          // Milestones list
          Expanded(
            child: selected == null
                ? const EmptyState(
                    icon: Icons.timeline_rounded,
                    title: 'No child selected',
                    subtitle: 'Add a child to see their timeline',
                  )
                : _MilestoneList(
                    childId: selected.id,
                    selectedCategory: _selectedCategory,
                    childProvider: childProvider,
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed('/add-milestone'),
        child: const Icon(Icons.add_rounded),
      ).animate().scale(delay: 300.ms, duration: 300.ms, curve: Curves.elasticOut),
    );
  }

  Color _categoryColor(MilestoneCategory cat) {
    switch (cat) {
      case MilestoneCategory.motor:
        return AppColors.motorColor;
      case MilestoneCategory.language:
        return AppColors.languageColor;
      case MilestoneCategory.social:
        return AppColors.socialColor;
      case MilestoneCategory.cognitive:
        return AppColors.cognitiveColor;
      case MilestoneCategory.other:
        return AppColors.otherColor;
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}

class _MilestoneList extends StatelessWidget {
  final String childId;
  final MilestoneCategory? selectedCategory;
  final ChildProvider childProvider;

  const _MilestoneList({
    required this.childId,
    required this.selectedCategory,
    required this.childProvider,
  });

  @override
  Widget build(BuildContext context) {
    final all = childProvider.milestonesForChild(childId);
    final milestones = selectedCategory == null
        ? all
        : all.where((m) => m.category == selectedCategory).toList();

    if (milestones.isEmpty) {
      return EmptyState(
        icon: Icons.star_outline_rounded,
        title: 'No milestones yet',
        subtitle: selectedCategory != null
            ? 'No ${selectedCategory!.displayName} milestones recorded'
            : 'Tap + to add the first milestone',
        actionLabel: 'Add Milestone',
        onAction: () => Navigator.of(context).pushNamed('/add-milestone'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: milestones.length,
      itemBuilder: (context, idx) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 0),
          child: MilestoneCard(
            milestone: milestones[idx],
            showTimeline: true,
            isLast: idx == milestones.length - 1,
          ).animate().fadeIn(delay: (idx * 60).ms).slideX(begin: 0.1, end: 0),
        );
      },
    );
  }
}
