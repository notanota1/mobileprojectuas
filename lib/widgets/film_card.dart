// lib/widgets/film_card.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/film_model.dart';
import '../theme/app_theme.dart';

class FilmCard extends StatelessWidget {
  final Film film;
  final VoidCallback onTap;
  final bool isLarge;

  const FilmCard({
    super.key,
    required this.film,
    required this.onTap,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isLarge ? 160 : 130,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  _buildPosterImage(isLarge ? 220 : 185),
                  // Gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.85),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Rating badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _buildRatingChip(film.ratingPersen),
                  ),
                  // Kategori
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.cinemaRed.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        film.kategori,
                        style: GoogleFonts.raleway(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Judul
            Text(
              film.judul,
              style: GoogleFonts.raleway(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              film.tahunRilis,
              style: GoogleFonts.raleway(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingChip(int persen) {
    Color ratingColor;
    if (persen >= 75) {
      ratingColor = const Color(0xFF43A047);
    } else if (persen >= 50) {
      ratingColor = AppColors.gold;
    } else {
      ratingColor = AppColors.cinemaRed;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: ratingColor, width: 1),
      ),
      child: Text(
        '$persen%',
        style: GoogleFonts.raleway(
          color: ratingColor,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildShimmer(double height) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        height: height,
        color: AppColors.shimmerBase,
      ),
    );
  }

  Widget _buildErrorWidget(double height) {
    return Container(
      height: height,
      color: AppColors.surfaceVariant,
      child: const Center(
        child: Icon(Icons.movie_outlined, color: AppColors.textMuted, size: 40),
      ),
    );
  }

  Widget _buildPosterImage(double height) {
    // Jika URL kosong atau tidak valid, tampilkan fallback
    if (film.gambarPoster.isEmpty || !film.isValidPosterUrl) {
      return _buildErrorWidget(height);
    }

    return CachedNetworkImage(
      imageUrl: film.gambarPoster,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => _buildShimmer(height),
      errorWidget: (context, url, error) {
        // Print error untuk debugging
        print('❌ Error loading image for ${film.judul}: $error');
        return _buildErrorWidget(height);
      },
    );
  }
}