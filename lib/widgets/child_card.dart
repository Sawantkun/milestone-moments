import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../models/child_model.dart';
import '../models/milestone_model.dart';
import 'child_avatar.dart';

class ChildCard extends StatelessWidget {
  final ChildModel child;
  final MilestoneModel? lastMilestone;
  final bool isSelected;
  final VoidCallback? onTap;

  const ChildCard({
    super.key,
    required this.child,
    this.lastMilestone,
    this.isSelected = false,
    this.onTap,
  });

  Color get _avatarColor {
    if (child.gender == 'female') return AppColors.primary;
    if (child.gender == 'male') return AppColors.teal;
    return AppColors.pink;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [AppColors.primary, AppColors.pink],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : (isDark ? AppColors.cardDark : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.dividerLight,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.25)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar
            ChildAvatarCompact(
              child: child,
              size: 50,
              borderRadius: 14,
              isSelected: isSelected,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  child.name,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
                Text(
                  child.ageString,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: isSelected ? Colors.white.withOpacity(0.8) : AppColors.textSecondaryLight,
                  ),
                ),
                if (lastMilestone != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '⭐ ${lastMilestone!.title}',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: isSelected ? Colors.white.withOpacity(0.7) : AppColors.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
