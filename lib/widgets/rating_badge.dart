// lib/widgets/rating_badge.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

enum RatingSize { small, medium, large }

class RatingBadge extends StatelessWidget {
  final int persen;
  final RatingSize size;
  final bool showLabel;

  const RatingBadge({
    super.key,
    required this.persen,
    this.size = RatingSize.medium,
    this.showLabel = false,
  });

  Color get _ratingColor {
    if (persen >= 75) return const Color(0xFF43A047); // Hijau
    if (persen >= 50) return AppColors.gold;           // Emas
    return AppColors.cinemaRed;                        // Merah
  }

  String get _ratingLabel {
    if (persen >= 75) return 'BAGUS';
    if (persen >= 50) return 'CUKUP';
    return 'KURANG';
  }

  double get _circleSize {
    switch (size) {
      case RatingSize.small:  return 42;
      case RatingSize.medium: return 58;
      case RatingSize.large:  return 78;
    }
  }

  double get _fontSize {
    switch (size) {
      case RatingSize.small:  return 12;
      case RatingSize.medium: return 16;
      case RatingSize.large:  return 22;
    }
  }

  double get _borderWidth {
    switch (size) {
      case RatingSize.small:  return 1.5;
      case RatingSize.medium: return 2;
      case RatingSize.large:  return 2.5;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: _circleSize,
          height: _circleSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _ratingColor.withOpacity(0.12),
            border: Border.all(color: _ratingColor, width: _borderWidth),
            boxShadow: [
              BoxShadow(
                color: _ratingColor.withOpacity(0.25),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$persen',
                style: GoogleFonts.cinzel(
                  color: _ratingColor,
                  fontSize: _fontSize,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              Text(
                '%',
                style: GoogleFonts.raleway(
                  color: _ratingColor,
                  fontSize: _fontSize * 0.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 6),
          Text(
            _ratingLabel,
            style: GoogleFonts.cinzel(
              color: _ratingColor,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}

/// Versi chip/pill kecil — cocok untuk list/card
class RatingChip extends StatelessWidget {
  final int persen;

  const RatingChip({super.key, required this.persen});

  Color get _color {
    if (persen >= 75) return const Color(0xFF43A047);
    if (persen >= 50) return AppColors.gold;
    return AppColors.cinemaRed;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.75),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, color: _color, size: 11),
          const SizedBox(width: 3),
          Text(
            '$persen%',
            style: GoogleFonts.raleway(
              color: _color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Versi bar horizontal — cocok untuk halaman detail
class RatingBar extends StatelessWidget {
  final int persen;
  final double height;

  const RatingBar({
    super.key,
    required this.persen,
    this.height = 6,
  });

  Color get _color {
    if (persen >= 75) return const Color(0xFF43A047);
    if (persen >= 50) return AppColors.gold;
    return AppColors.cinemaRed;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Stack(
        children: [
          // Background track
          Container(
            height: height,
            color: AppColors.divider,
          ),
          // Filled portion
          FractionallySizedBox(
            widthFactor: (persen / 100).clamp(0.0, 1.0),
            child: Container(
              height: height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_color.withOpacity(0.7), _color],
                ),
                borderRadius: BorderRadius.circular(height),
              ),
            ),
          ),
        ],
      ),
    );
  }
}