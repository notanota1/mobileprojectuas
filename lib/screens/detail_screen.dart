// lib/screens/detail_screen.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/film_model.dart';
import '../services/favorites_service.dart';
import '../services/watchlist_service.dart'; // ← TAMBAHAN
import '../theme/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class DetailScreen extends StatefulWidget {
  final Film film;

  const DetailScreen({super.key, required this.film});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  bool _isFavorite = false;
  bool _isInWatchlist = false; // ← TAMBAHAN

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );
    _loadFavoriteStatus();
    _loadWatchlistStatus(); // ← TAMBAHAN
    _saveWatchHistory();
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _openTrailer() async {
    final url = widget.film.urlTrailer;
    if (url.startsWith('http')) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.surfaceVariant,
          content: Text(
            'Trailer tidak tersedia',
            style: GoogleFonts.raleway(color: AppColors.textPrimary),
          ),
        ),
      );
    }
  }

  Future<void> _loadFavoriteStatus() async {
    final status = await FavoritesService.isFavorite(widget.film.id);
    if (mounted) {
      setState(() {
        _isFavorite = status;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    await FavoritesService.toggleFavorite(widget.film);
    if (mounted) {
      final status = await FavoritesService.isFavorite(widget.film.id);
      setState(() {
        _isFavorite = status;
      });
    }
  }

  // ── Watchlist methods ─────────────────────────────────────────────────────

  Future<void> _loadWatchlistStatus() async {
    final status = await WatchlistService.isInWatchlist(widget.film.id);
    if (mounted) {
      setState(() {
        _isInWatchlist = status;
      });
    }
  }

  Future<void> _toggleWatchlist() async {
    final added = await WatchlistService.toggle(widget.film);
    if (mounted) {
      setState(() {
        _isInWatchlist = added;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.surfaceVariant,
          content: Text(
            added
                ? '✅ Ditambahkan ke Watchlist'
                : '🗑️ Dihapus dari Watchlist',
            style: GoogleFonts.raleway(color: AppColors.textPrimary),
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _saveWatchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('watch_history') ?? '[]';
    final List<dynamic> list = json.decode(raw) as List<dynamic>;
    final history = list
        .map((e) => e as Map<String, dynamic>)
        .where((item) => item['id'] != widget.film.id)
        .toList();

    final entry = {
      'id': widget.film.id,
      'judul': widget.film.judul,
      'gambar_poster': widget.film.gambarPoster,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    history.insert(0, entry);
    final trimmed = history.take(20).toList();
    await prefs.setString('watch_history', json.encode(trimmed));
  }

  Future<void> _shareFilm(Film film) async {
    final String shareText = '''
    🎬 ${film.judul} (${film.tahunRilis})
  📊 Rating: ${film.ratingPersen}/100

${film.ringkasan}

🔗 Lihat selengkapnya di aplikasi
    '''.trim();

    try {
      await Share.share(
        shareText,
        subject: '${film.judul} (${film.tahunRilis})',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal membagikan')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final film = widget.film;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildHeroHeader(film, size)),
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: _buildInfoContent(film),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: _buildBackButton(),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: _buildFavoriteButton(),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomActions(film),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(Film film, Size size) {
    return SizedBox(
      height: size.height * 0.5,
      child: Stack(
        fit: StackFit.expand,
        children: [
          film.isValidSampulUrl
              ? CachedNetworkImage(
                  imageUrl: film.gambarSampul,
                  fit: BoxFit.cover,
                  errorWidget: (c, u, e) => _posterFallback(film),
                )
              : film.isValidPosterUrl
              ? CachedNetworkImage(
                  imageUrl: film.gambarPoster,
                  fit: BoxFit.cover,
                )
              : Container(color: AppColors.surfaceVariant),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                  AppColors.background.withOpacity(0.8),
                  AppColors.background,
                ],
                stops: const [0.0, 0.4, 0.8, 1.0],
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 90,
                  height: 130,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.6),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: film.isValidPosterUrl
                        ? CachedNetworkImage(
                            imageUrl: film.gambarPoster,
                            fit: BoxFit.cover,
                            errorWidget: (c, u, e) => _posterFallback(film),
                          )
                        : _posterFallback(film),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cinemaRed,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          film.kategori.toUpperCase(),
                          style: GoogleFonts.raleway(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        film.judul.toUpperCase(),
                        style: GoogleFonts.cinzel(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                          height: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.8),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        film.tahunRilis,
                        style: GoogleFonts.raleway(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _posterFallback(Film film) {
    return Container(
      color: AppColors.surfaceVariant,
      child: const Icon(Icons.movie, color: AppColors.textMuted, size: 40),
    );
  }

  Widget _buildInfoContent(Film film) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRatingRow(film),
          const SizedBox(height: 24),
          _buildGoldDivider(),
          const SizedBox(height: 24),
          _buildSectionTitle('SINOPSIS'),
          const SizedBox(height: 12),
          Text(
            film.ringkasan,
            style: GoogleFonts.raleway(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 24),
          _buildGoldDivider(),
          const SizedBox(height: 24),
          _buildSectionTitle('DETAIL FILM'),
          const SizedBox(height: 16),
          _buildDetailGrid(film),
        ],
      ),
    );
  }

  Widget _buildRatingRow(Film film) {
    Color ratingColor;
    String ratingLabel;
    if (film.ratingPersen >= 75) {
      ratingColor = const Color(0xFF43A047);
      ratingLabel = 'SANGAT BAGUS';
    } else if (film.ratingPersen >= 50) {
      ratingColor = AppColors.gold;
      ratingLabel = 'BAGUS';
    } else {
      ratingColor = AppColors.cinemaRed;
      ratingLabel = 'KURANG';
    }

    return Row(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ratingColor, width: 2.5),
            color: ratingColor.withOpacity(0.1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${film.ratingPersen}',
                style: GoogleFonts.cinzel(
                  color: ratingColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '%',
                style: GoogleFonts.raleway(color: ratingColor, fontSize: 11),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ratingLabel,
              style: GoogleFonts.cinzel(
                color: ratingColor,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Skor Penonton',
              style: GoogleFonts.raleway(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (i) {
                final filled = i < (film.ratingValue / 2).round();
                return Icon(
                  filled ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: filled ? AppColors.gold : AppColors.textMuted,
                  size: 18,
                );
              }),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGoldDivider() {
    return Container(
      height: 1,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, AppColors.gold, Colors.transparent],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(width: 3, height: 16, color: AppColors.gold),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.cinzel(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.5,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailGrid(Film film) {
    final details = [
      {'label': 'ID Film', 'value': '#${film.id}', 'icon': Icons.tag},
      {
        'label': 'Kategori',
        'value': film.kategori,
        'icon': Icons.category_outlined,
      },
      {
        'label': 'Tahun',
        'value': film.tahunRilis,
        'icon': Icons.calendar_today_outlined,
      },
      {
        'label': 'Rating',
        'value': '${film.ratingPersen}/100',
        'icon': Icons.bar_chart_rounded,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 64,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: details.length,
      itemBuilder: (context, i) {
        final item = details[i];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.divider, width: 1),
          ),
          child: Row(
            children: [
              Icon(item['icon'] as IconData, color: AppColors.gold, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item['label'] as String,
                      style: GoogleFonts.raleway(
                        color: AppColors.textMuted,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      item['value'] as String,
                      style: GoogleFonts.raleway(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.6),
          border: Border.all(color: AppColors.divider, width: 1),
        ),
        child: const Icon(
          Icons.arrow_back_rounded,
          color: AppColors.textPrimary,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return GestureDetector(
      onTap: _toggleFavorite,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isFavorite
              ? AppColors.cinemaRed.withOpacity(0.8)
              : Colors.black.withOpacity(0.6),
          border: Border.all(
            color: _isFavorite ? AppColors.cinemaRed : AppColors.divider,
            width: 1,
          ),
        ),
        child: Icon(
          _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  // ── Tombol bawah: Trailer | Watchlist (Bookmark) | Share ─────────────────
  Widget _buildBottomActions(Film film) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.background.withOpacity(0.0),
            AppColors.background.withOpacity(0.95),
            AppColors.background,
          ],
        ),
      ),
      child: Row(
        children: [
          // Tombol utama: TONTON TRAILER
          Expanded(
            child: GestureDetector(
              onTap: _openTrailer,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.gold, AppColors.goldDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.play_circle_outline_rounded,
                      color: Colors.black,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'TONTON TRAILER',
                      style: GoogleFonts.raleway(
                        color: Colors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // ── Tombol WATCHLIST (Bookmark) ──────────────────────────────────
          GestureDetector(
            onTap: _toggleWatchlist,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _isInWatchlist
                    ? AppColors.gold.withOpacity(0.15)
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isInWatchlist ? AppColors.gold : AppColors.divider,
                  width: _isInWatchlist ? 1.5 : 1,
                ),
              ),
              child: Icon(
                _isInWatchlist
                    ? Icons.bookmark_rounded          // sudah disimpan
                    : Icons.bookmark_border_rounded,  // belum disimpan
                color: _isInWatchlist
                    ? AppColors.gold
                    : AppColors.textSecondary,
                size: 22,
              ),
            ),
          ),
          // ────────────────────────────────────────────────────────────────

          const SizedBox(width: 10),

          // Tombol SHARE
          GestureDetector(
            onTap: () => _shareFilm(film),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider, width: 1),
              ),
              child: const Icon(
                Icons.share_outlined,
                color: AppColors.textSecondary,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}