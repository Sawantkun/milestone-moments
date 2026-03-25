import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../state/child_provider.dart';
import '../../services/ai_service.dart';
import '../../theme/app_colors.dart';
import '../../models/activity_model.dart';
import '../../models/child_model.dart';
import '../../widgets/activity_card.dart';
import '../../widgets/empty_state.dart';

class ActivitiesScreen extends StatefulWidget {
  final ChildModel? embeddedChild;

  const ActivitiesScreen({super.key, this.embeddedChild});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  final AiService _aiService = AiService();
  List<ActivityModel> _activities = [];
  String? _selectedCategory;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadActivities();
  }

  void _loadActivities() {
    final child = widget.embeddedChild ?? context.read<ChildProvider>().selectedChild;
    if (child == null) return;
    setState(() {
      _activities = _aiService.getActivitiesForAge(child.ageInMonths);
      _selectedCategory = null;
    });
  }

  List<String> get _categories {
    final cats = _activities.map((a) => a.category).toSet().toList();
    cats.sort();
    return cats;
  }

  List<ActivityModel> get _filtered {
    if (_selectedCategory == null) return _activities;
    return _activities.where((a) => a.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.embeddedChild ?? context.watch<ChildProvider>().selectedChild;
    final isEmbedded = widget.embeddedChild != null;

    Widget body = child == null
        ? const EmptyState(
            icon: Icons.lightbulb_outline_rounded,
            title: 'No child selected',
            subtitle: 'Select a child to see AI-powered activity suggestions',
          )
        : _buildContent(context, child);

    if (isEmbedded) return body;

    return Scaffold(
      appBar: AppBar(title: const Text('Activity Suggestions')),
      body: body,
    );
  }

  Widget _buildContent(BuildContext context, ChildModel child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header banner
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppColors.purpleTeal,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Activity Suggestions',
                      style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                    Text(
                      '${_activities.length} activities for ${child.name} (${child.ageString})',
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withOpacity(0.85)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 100.ms),

        // Category filter
        if (_categories.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _CategoryChip(
                    label: 'All',
                    isSelected: _selectedCategory == null,
                    onTap: () => setState(() => _selectedCategory = null),
                  ),
                  ...(_categories.map((cat) => Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: _CategoryChip(
                          label: cat,
                          isSelected: _selectedCategory == cat,
                          onTap: () => setState(() => _selectedCategory = _selectedCategory == cat ? null : cat),
                        ),
                      ))),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 150.ms),

        const SizedBox(height: 12),

        // Activities grid
        Expanded(
          child: _filtered.isEmpty
              ? const EmptyState(
                  icon: Icons.lightbulb_outline_rounded,
                  title: 'No activities',
                  subtitle: 'No activities found for this category',
                )
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: _filtered.length,
                  itemBuilder: (context, idx) {
                    return ActivityCard(
                      activity: _filtered[idx],
                      onMarkDone: () {
                        setState(() => _filtered[idx].isDone = !_filtered[idx].isDone);
                      },
                    ).animate().fadeIn(delay: (idx * 60).ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
                  },
                ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.teal : AppColors.teal.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.teal,
          ),
        ),
      ),
    );
  }
}
