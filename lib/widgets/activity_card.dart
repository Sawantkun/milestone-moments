import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../models/activity_model.dart';

class ActivityCard extends StatelessWidget {
  final ActivityModel activity;
  final VoidCallback? onMarkDone;

  const ActivityCard({
    super.key,
    required this.activity,
    this.onMarkDone,
  });

  Color get _categoryColor {
    switch (activity.category.toLowerCase()) {
      case 'motor':
        return AppColors.motorColor;
      case 'language':
        return AppColors.languageColor;
      case 'social':
        return AppColors.socialColor;
      case 'cognitive':
        return AppColors.cognitiveColor;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _categoryColor;

    return GestureDetector(
      onTap: () => _showDetailSheet(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: activity.isDone ? AppColors.teal.withOpacity(0.4) : color.withOpacity(0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category + duration row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          activity.category,
                          style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w700, color: color),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.teal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.schedule_rounded, size: 10, color: AppColors.teal),
                            const SizedBox(width: 2),
                            Text(
                              '${activity.durationMinutes}m',
                              style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.teal),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Title
                  Text(
                    activity.title,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Description preview
                  Expanded(
                    child: Text(
                      activity.description,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Materials preview
                  if (activity.materials.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.inventory_2_outlined, size: 12, color: AppColors.textSecondaryLight),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            activity.materials.take(2).join(', '),
                            style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondaryLight),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  // Done button
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: onMarkDone,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        decoration: BoxDecoration(
                          color: activity.isDone ? AppColors.teal : color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              activity.isDone ? Icons.check_circle_rounded : Icons.play_circle_outline_rounded,
                              size: 14,
                              color: activity.isDone ? Colors.white : color,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              activity.isDone ? 'Done!' : 'Try it',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: activity.isDone ? Colors.white : color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (activity.isDone)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: AppColors.teal,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDetailSheet(BuildContext context) {
    final color = _categoryColor;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                    child: Text(activity.category, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: AppColors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        const Icon(Icons.schedule_rounded, size: 14, color: AppColors.teal),
                        const SizedBox(width: 4),
                        Text('${activity.durationMinutes} mins', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.teal, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(activity.title, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Text(activity.description, style: GoogleFonts.poppins(fontSize: 14, height: 1.6, color: AppColors.textSecondaryLight)),
              if (activity.materials.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text('Materials Needed', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ...activity.materials.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(Icons.fiber_manual_record_rounded, size: 8, color: color),
                      const SizedBox(width: 8),
                      Text(m, style: GoogleFonts.poppins(fontSize: 13)),
                    ],
                  ),
                )),
              ],
              if (activity.benefits.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text('Benefits', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ...activity.benefits.map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline_rounded, size: 14, color: AppColors.teal),
                      const SizedBox(width: 8),
                      Expanded(child: Text(b, style: GoogleFonts.poppins(fontSize: 13))),
                    ],
                  ),
                )),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    onMarkDone?.call();
                    Navigator.pop(ctx);
                  },
                  child: Text(activity.isDone ? 'Mark as Not Done' : 'Mark as Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
