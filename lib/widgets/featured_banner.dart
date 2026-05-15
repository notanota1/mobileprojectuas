// lib/widgets/featured_banner.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/film_model.dart';
import '../theme/app_theme.dart';

class FeaturedBanner extends StatelessWidget {
  final Film film;
  final VoidCallback onTap;

  const FeaturedBanner({super.key, required this.film, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: size.height * 0.52,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Sampul gambar background dengan fallback yang lebih baik
            _buildBackgroundImage(),

            // Multi-layer gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.transparent,
                    AppColors.background.withOpacity(0.7),
                    AppColors.background,
                  ],
                  stops: const [0.0, 0.35, 0.75, 1.0],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            // Content
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // FEATURED label
                  Row(
                    children: [
                      Container(
                        width: 3,
                        height: 16,
                        color: AppColors.gold,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'FEATURED',
                        style: GoogleFonts.cinzel(
                          color: AppColors.gold,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Judul
                  Text(
                    film.judul.toUpperCase(),
                    style: GoogleFonts.cinzel(
                      color: AppColors.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      height: 1.1,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.8),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  // Meta info
                  Row(
                    children: [
                      _MetaChip(
                        icon: Icons.star_rounded,
                        label: '${film.ratingPersen}%',
                        color: AppColors.gold,
                      ),
                      const SizedBox(width: 10),
                      _MetaChip(
                        icon: Icons.calendar_month_outlined,
                        label: film.tahunRilis,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 10),
                      _MetaChip(
                        icon: Icons.local_movies_outlined,
                        label: film.kategori,
                        color: AppColors.cinemaRedLight,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Ringkasan
                  Text(
                    film.ringkasan,
                    style: GoogleFonts.raleway(
                      color: AppColors.textSecondary,
                      fontSize: 12.5,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 18),
                  // CTA Buttons
                  Row(
                    children: [
                      _buildPlayButton(),
                      const SizedBox(width: 12),
                      _buildMoreInfoButton(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundImage() {
    if (film.isValidSampulUrl) {
      return CachedNetworkImage(
        imageUrl: film.gambarSampul,
        fit: BoxFit.cover,
        errorWidget: (c, u, e) {
          print('Error loading sampul for ${film.judul}: $e');
          // Fallback ke poster jika sampul error
          if (film.isValidPosterUrl) {
            return CachedNetworkImage(
              imageUrl: film.gambarPoster,
              fit: BoxFit.cover,
              errorWidget: (c, u, e) => _fallbackBg(),
            );
          }
          return _fallbackBg();
        },
      );
    } else if (film.isValidPosterUrl) {
      return CachedNetworkImage(
        imageUrl: film.gambarPoster,
        fit: BoxFit.cover,
        errorWidget: (c, u, e) {
          print('Error loading poster for ${film.judul}: $e');
          return _fallbackBg();
        },
      );
    } else {
      return _fallbackBg();
    }
  }

  Widget _fallbackBg() {
    return Container(
      color: AppColors.surfaceVariant,
      child: const Center(
        child: Icon(Icons.movie, size: 80, color: AppColors.textMuted),
      ),
    );
  }

  Widget _buildPlayButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.gold, AppColors.goldDark],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 20),
                const SizedBox(width: 6),
                Text(
                  'TONTON',
                  style: GoogleFonts.raleway(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoreInfoButton() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.textMuted, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.info_outline, color: AppColors.textSecondary, size: 18),
              const SizedBox(width: 6),
              Text(
                'INFO',
                style: GoogleFonts.raleway(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.raleway(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}