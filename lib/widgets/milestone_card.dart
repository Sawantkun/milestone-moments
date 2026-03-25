import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../models/milestone_model.dart';

class MilestoneCard extends StatelessWidget {
  final MilestoneModel milestone;
  final bool showTimeline;
  final bool isLast;

  const MilestoneCard({
    super.key,
    required this.milestone,
    this.showTimeline = false,
    this.isLast = false,
  });

  Color get _categoryColor {
    switch (milestone.category) {
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (showTimeline) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Timeline column
            SizedBox(
              width: 32,
              child: Column(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: _categoryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: _categoryColor.withOpacity(0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: _categoryColor.withOpacity(0.2),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Card
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CardContent(
                  milestone: milestone,
                  categoryColor: _categoryColor,
                  isDark: isDark,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _CardContent(
        milestone: milestone,
        categoryColor: _categoryColor,
        isDark: isDark,
      ),
    );
  }
}

class _CardContent extends StatelessWidget {
  final MilestoneModel milestone;
  final Color categoryColor;
  final bool isDark;

  const _CardContent({
    required this.milestone,
    required this.categoryColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: categoryColor.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border(
          left: BorderSide(color: categoryColor, width: 3),
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category icon circle
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(milestone.category.emoji, style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        milestone.title,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        milestone.category.displayName,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: categoryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  milestone.description,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 12, color: categoryColor),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd MMM yyyy').format(milestone.date),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: categoryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (milestone.photoUrl != null) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.photo_outlined, size: 12, color: categoryColor.withOpacity(0.7)),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
          ),

          // ── Photo thumbnail (shown when a local image is attached) ──
          if (milestone.photoUrl != null && File(milestone.photoUrl!).existsSync()) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => _MilestoneImageViewer(imagePath: milestone.photoUrl!),
                ),
              ),
              child: Hero(
                tag: 'milestone_image_${milestone.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(milestone.photoUrl!),
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Full-screen image viewer shown when user taps a milestone photo.
class _MilestoneImageViewer extends StatelessWidget {
  final String imagePath;
  const _MilestoneImageViewer({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.file(File(imagePath), fit: BoxFit.contain),
        ),
      ),
    );
  }
}
