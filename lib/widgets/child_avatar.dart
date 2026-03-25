import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/child_model.dart';
import '../theme/app_colors.dart';

/// Reusable child avatar — shows photo if one is saved, otherwise shows
/// a gradient circle with the child's initial.
class ChildAvatar extends StatelessWidget {
  final ChildModel child;
  final double size;
  final double borderRadius;

  /// When true a small camera-badge is drawn in the bottom-right corner.
  final bool showEditBadge;

  /// Callback for the edit badge tap (or the whole widget if [showEditBadge] is false).
  final VoidCallback? onTap;

  const ChildAvatar({
    super.key,
    required this.child,
    this.size = 80,
    this.borderRadius = 24,
    this.showEditBadge = false,
    this.onTap,
  });

  Color get _gradientStart =>
      child.gender == 'female' ? AppColors.primary : AppColors.teal;

  Color get _gradientEnd =>
      child.gender == 'female' ? AppColors.pink : AppColors.primary;

  bool get _hasPhoto =>
      child.photoUrl != null && File(child.photoUrl!).existsSync();

  @override
  Widget build(BuildContext context) {
    Widget avatar;

    if (_hasPhoto) {
      avatar = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.file(
          File(child.photoUrl!),
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    } else {
      avatar = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_gradientStart, _gradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: _gradientStart.withOpacity(0.30),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            child.name[0].toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: size * 0.42,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    if (!showEditBadge) {
      return GestureDetector(onTap: onTap, child: avatar);
    }

    // Avatar with camera-badge overlay
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(
            bottom: -2,
            right: -2,
            child: Container(
              width: size * 0.30,
              height: size * 0.30,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: size * 0.15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Smaller variant used in cards/lists — shows photo or coloured initial box.
class ChildAvatarCompact extends StatelessWidget {
  final ChildModel child;
  final double size;
  final double borderRadius;
  final bool isSelected;

  const ChildAvatarCompact({
    super.key,
    required this.child,
    this.size = 50,
    this.borderRadius = 14,
    this.isSelected = false,
  });

  Color get _color {
    if (child.gender == 'female') return AppColors.primary;
    if (child.gender == 'male') return AppColors.teal;
    return AppColors.pink;
  }

  bool get _hasPhoto =>
      child.photoUrl != null && File(child.photoUrl!).existsSync();

  @override
  Widget build(BuildContext context) {
    if (_hasPhoto) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.file(
          File(child.photoUrl!),
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withOpacity(0.25) : _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: Text(
          child.name[0].toUpperCase(),
          style: GoogleFonts.poppins(
            fontSize: size * 0.40,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : _color,
          ),
        ),
      ),
    );
  }
}
