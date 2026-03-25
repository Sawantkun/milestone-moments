import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../models/reminder_model.dart';

class ReminderCard extends StatelessWidget {
  final ReminderModel reminder;
  final String childName;
  final VoidCallback? onToggle;
  final VoidCallback? onDelete;

  const ReminderCard({
    super.key,
    required this.reminder,
    required this.childName,
    this.onToggle,
    this.onDelete,
  });

  Color get _typeColor {
    switch (reminder.type) {
      case ReminderType.vaccination:
        return AppColors.primary;
      case ReminderType.checkup:
        return AppColors.teal;
      case ReminderType.other:
        return AppColors.pink;
    }
  }

  String get _timeUntil {
    final now = DateTime.now();
    final diff = reminder.dateTime.difference(now);
    if (diff.isNegative) return 'Overdue';
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Tomorrow';
    if (diff.inDays < 7) return 'In ${diff.inDays} days';
    if (diff.inDays < 30) return 'In ${(diff.inDays / 7).round()} week${(diff.inDays / 7).round() == 1 ? '' : 's'}';
    return 'In ${(diff.inDays / 30).round()} month${(diff.inDays / 30).round() == 1 ? '' : 's'}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _typeColor;
    final isOverdue = reminder.dateTime.isBefore(DateTime.now()) && !reminder.isCompleted;

    return Opacity(
      opacity: reminder.isCompleted ? 0.55 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isOverdue ? Colors.redAccent.withOpacity(0.4) : color.withOpacity(0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isOverdue ? Colors.redAccent.withOpacity(0.1) : color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                reminder.type.emoji,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          title: Text(
            reminder.title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              decoration: reminder.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text(
                childName,
                style: GoogleFonts.poppins(fontSize: 11, color: color, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 11, color: AppColors.textSecondaryLight),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd MMM yyyy').format(reminder.dateTime),
                    style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondaryLight),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isOverdue ? Colors.redAccent.withOpacity(0.1) : color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _timeUntil,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isOverdue ? Colors.redAccent : color,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onToggle != null)
                GestureDetector(
                  onTap: onToggle,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: reminder.isCompleted ? AppColors.teal : Colors.transparent,
                      border: Border.all(
                        color: reminder.isCompleted ? AppColors.teal : AppColors.dividerLight,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: reminder.isCompleted
                        ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                        : null,
                  ),
                ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                  onPressed: onDelete,
                  padding: const EdgeInsets.only(left: 4),
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
