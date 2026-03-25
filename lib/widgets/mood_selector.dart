import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/mood_entry_model.dart';
import '../theme/app_colors.dart';

class MoodSelector extends StatelessWidget {
  final MoodLevel selected;
  final ValueChanged<MoodLevel> onSelect;

  const MoodSelector({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  Color _moodColor(MoodLevel mood) {
    switch (mood) {
      case MoodLevel.awful:
        return AppColors.moodAwful;
      case MoodLevel.sad:
        return AppColors.moodSad;
      case MoodLevel.okay:
        return AppColors.moodOkay;
      case MoodLevel.good:
        return AppColors.moodGood;
      case MoodLevel.great:
        return AppColors.moodGreat;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: MoodLevel.values.map((mood) {
          final isSelected = selected == mood;
          final color = _moodColor(mood);
          return GestureDetector(
            onTap: () => onSelect(mood),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              padding: EdgeInsets.all(isSelected ? 12 : 8),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? color : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(fontSize: isSelected ? 36 : 28),
                    child: Text(mood.emoji),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mood.displayName,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                      color: isSelected ? color : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            )
                .animate(target: isSelected ? 1 : 0)
                .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 200.ms),
          );
        }).toList(),
      ),
    );
  }
}
