import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../state/child_provider.dart';
import '../../theme/app_colors.dart';
import '../../models/mood_entry_model.dart';
import '../../widgets/glassmorphic_card.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/mood_selector.dart';

class MoodLogScreen extends StatefulWidget {
  const MoodLogScreen({super.key});

  @override
  State<MoodLogScreen> createState() => _MoodLogScreenState();
}

class _MoodLogScreenState extends State<MoodLogScreen> {
  static const _uuid = Uuid();
  MoodLevel _selectedMood = MoodLevel.good;
  final _notesCtrl = TextEditingController();
  final Set<String> _selectedActivities = {};
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  static const List<String> _activityOptions = [
    'Outdoor play',
    'Reading',
    'Music',
    'Arts & crafts',
    'Social play',
    'Dancing',
    'Swimming',
    'Nap time',
    'Learning',
    'TV / Screen time',
    'Family time',
    'Exercise',
  ];

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final childProvider = context.read<ChildProvider>();
    final child = childProvider.selectedChild;
    if (child == null) return;

    setState(() => _isLoading = true);
    try {
      final entry = MoodEntry(
        id: _uuid.v4(),
        childId: child.id,
        date: _selectedDate,
        mood: _selectedMood,
        notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
        activities: _selectedActivities.toList(),
      );
      await childProvider.addMoodEntry(entry);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Mood logged successfully!'),
            backgroundColor: AppColors.teal,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final childProvider = context.watch<ChildProvider>();
    final child = childProvider.selectedChild;

    return Scaffold(
      appBar: AppBar(
        title: Text('${child?.name ?? 'Child'}\'s Mood Log'),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date selector
            GestureDetector(
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now(),
                );
                if (d != null) setState(() => _selectedDate = d);
              },
              child: GlassmorphicCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondaryLight),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: 24),

            // Mood selector
            Text('How is ${child?.name ?? 'your child'} feeling?', style: Theme.of(context).textTheme.titleLarge)
                .animate().fadeIn(delay: 150.ms),
            const SizedBox(height: 16),
            MoodSelector(
              selected: _selectedMood,
              onSelect: (m) => setState(() => _selectedMood = m),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 24),

            // Activities
            Text('What did they do today?', style: Theme.of(context).textTheme.titleLarge)
                .animate().fadeIn(delay: 250.ms),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _activityOptions.map((activity) {
                final isSelected = _selectedActivities.contains(activity);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedActivities.remove(activity);
                      } else {
                        _selectedActivities.add(activity);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      activity,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.primary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 24),

            // Notes
            Text('Notes (optional)', style: Theme.of(context).textTheme.titleLarge)
                .animate().fadeIn(delay: 350.ms),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'How was the day? Any observations...',
                alignLabelWithHint: true,
              ),
            ).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: 32),

            GradientButton(
              text: 'Save Mood Log',
              isLoading: _isLoading,
              onPressed: _save,
            ).animate().fadeIn(delay: 450.ms),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
