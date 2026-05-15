// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../models/film_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/film_card.dart';
import '../widgets/featured_banner.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Film> _allFilms = [];
  bool _isLoading = true;
  String? _error;
  int _activeCarouselIndex = 0;
  int _selectedNavIndex = 0;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;

  List<Film> get _featuredFilms =>
      _allFilms.take(5).toList();

  List<Film> get _topRatedFilms {
    final sorted = [..._allFilms];
    sorted.sort((a, b) => b.ratingPersen.compareTo(a.ratingPersen));
    return sorted.take(10).toList();
  }

  List<Film> get _filteredFilms {
    if (_searchQuery.isEmpty) return _allFilms;
    return _allFilms
        .where((f) =>
            f.judul.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            f.kategori.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _loadFilms();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFilms() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final films = await ApiService.fetchFilms();
      setState(() {
        _allFilms = films;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _goToDetail(Film film) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => DetailScreen(film: film),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? _buildLoadingState()
          : _error != null
              ? _buildErrorState()
              : _buildContentByTab(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildContentByTab() {
    switch (_selectedNavIndex) {
      case 0:
        return _buildMainContent();
      case 1:
        return _buildAllFilmsTab();
      case 2:
        return _buildFavoritesTab();
      case 3:
        return _buildProfileTab();
      default:
        return _buildMainContent();
    }
  }

  Widget _buildMainContent() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildAppBar(),
        if (_showSearch) _buildSearchBar(),
        if (!_showSearch && _searchQuery.isEmpty) ...[
          // Featured Carousel
          SliverToBoxAdapter(child: _buildFeaturedCarousel()),
          // Carousel indicator
          SliverToBoxAdapter(child: _buildCarouselIndicator()),
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
          // Top Rated Section
          SliverToBoxAdapter(child: _buildSectionHeader('TOP RATED', Icons.star_rounded)),
          SliverToBoxAdapter(child: _buildFilmRow(_topRatedFilms, isLarge: true)),
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
          // All Films Section
          SliverToBoxAdapter(child: _buildSectionHeader('SEMUA FILM', Icons.movie_outlined)),
          SliverToBoxAdapter(child: _buildFilmRow(_allFilms)),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ] else ...[
          // Search results
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Text(
                '${_filteredFilms.length} hasil ditemukan',
                style: GoogleFonts.raleway(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, i) => GestureDetector(
                  onTap: () => _goToDetail(_filteredFilms[i]),
                  child: FilmCard(
                    film: _filteredFilms[i],
                    onTap: () => _goToDetail(_filteredFilms[i]),
                  ),
                ),
                childCount: _filteredFilms.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.56,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ],
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: AppColors.background,
      floating: true,
      snap: true,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.goldLight, AppColors.goldDark],
                ),
              ),
              child: const Icon(Icons.movie_filter_rounded, color: Colors.black, size: 18),
            ),
          ],
        ),
      ),
      title: Text(
        'CINEMAX',
        style: GoogleFonts.cinzel(
          color: AppColors.gold,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: 4,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _showSearch ? Icons.close : Icons.search_rounded,
            color: AppColors.gold,
          ),
          onPressed: () {
            setState(() {
              _showSearch = !_showSearch;
              if (!_showSearch) {
                _searchQuery = '';
                _searchController.clear();
              }
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textSecondary),
          onPressed: () {},
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: TextField(
          controller: _searchController,
          autofocus: true,
          style: GoogleFonts.raleway(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Cari judul atau kategori...',
            hintStyle: GoogleFonts.raleway(color: AppColors.textMuted),
            prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
            ),
          ),
          onChanged: (val) => setState(() => _searchQuery = val),
        ),
      ),
    );
  }

  Widget _buildFeaturedCarousel() {
    if (_featuredFilms.isEmpty) return const SizedBox.shrink();
    return CarouselSlider(
      options: CarouselOptions(
        height: MediaQuery.of(context).size.height * 0.52,
        viewportFraction: 1.0,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 5),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.easeInOutCubic,
        onPageChanged: (index, _) =>
            setState(() => _activeCarouselIndex = index),
      ),
      items: _featuredFilms
          .map((film) => FeaturedBanner(
                film: film,
                onTap: () => _goToDetail(film),
              ))
          .toList(),
    );
  }

  Widget _buildCarouselIndicator() {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: AnimatedSmoothIndicator(
        activeIndex: _activeCarouselIndex,
        count: _featuredFilms.length,
        effect: WormEffect(
          dotHeight: 5,
          dotWidth: 5,
          activeDotColor: AppColors.gold,
          dotColor: AppColors.textMuted.withOpacity(0.4),
          spacing: 6,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.gold, size: 18),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.cinzel(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 1,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.gold, Colors.transparent],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilmRow(List<Film> films, {bool isLarge = false}) {
    return SizedBox(
      height: isLarge ? 300 : 265,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(left: 20, right: 6),
        itemCount: films.length,
        itemBuilder: (context, i) => FilmCard(
          film: films[i],
          onTap: () => _goToDetail(films[i]),
          isLarge: isLarge,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: MediaQuery.of(context).size.height * 0.52, color: AppColors.shimmerBase),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 120, height: 18, color: AppColors.shimmerBase),
                  const SizedBox(height: 16),
                  Row(
                    children: List.generate(
                      3,
                      (_) => Container(
                        width: 130,
                        height: 200,
                        margin: const EdgeInsets.only(right: 14),
                        decoration: BoxDecoration(
                          color: AppColors.shimmerBase,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 64, color: AppColors.cinemaRed.withOpacity(0.7)),
            const SizedBox(height: 20),
            Text(
              'GAGAL MEMUAT',
              style: GoogleFonts.cinzel(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _error ?? 'Terjadi kesalahan',
              style: GoogleFonts.raleway(color: AppColors.textSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: _loadFilms,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.gold, AppColors.goldDark],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'COBA LAGI',
                  style: GoogleFonts.cinzel(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Beranda'},
      {'icon': Icons.local_movies_outlined, 'label': 'Film'},
      {'icon': Icons.favorite_border_rounded, 'label': 'Favorit'},
      {'icon': Icons.person_outline_rounded, 'label': 'Profil'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          top: BorderSide(color: AppColors.divider, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final isActive = i == _selectedNavIndex;
              return GestureDetector(
                onTap: () => setState(() => _selectedNavIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.gold.withOpacity(0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        items[i]['icon'] as IconData,
                        color: isActive ? AppColors.gold : AppColors.textMuted,
                        size: 22,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items[i]['label'] as String,
                        style: GoogleFonts.raleway(
                          color: isActive ? AppColors.gold : AppColors.textMuted,
                          fontSize: 10,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // TAB 1: SEMUA FILM
  Widget _buildAllFilmsTab() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildAppBar(),
        if (_showSearch) _buildSearchBar(),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              'SEMUA FILM (${_filteredFilms.length})',
              style: GoogleFonts.cinzel(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, i) => GestureDetector(
                onTap: () => _goToDetail(_filteredFilms[i]),
                child: FilmCard(
                  film: _filteredFilms[i],
                  onTap: () => _goToDetail(_filteredFilms[i]),
                ),
              ),
              childCount: _filteredFilms.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.56,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  // TAB 2: FAVORIT
  Widget _buildFavoritesTab() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildAppBar(),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  Icon(
                    Icons.favorite_outline_rounded,
                    size: 80,
                    color: AppColors.cinemaRed.withOpacity(0.5),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'FAVORIT KOSONG',
                    style: GoogleFonts.cinzel(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tambahkan film favorit dengan mengklik icon hati',
                    style: GoogleFonts.raleway(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // TAB 3: PROFIL
  Widget _buildProfileTab() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildAppBar(),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Profile Avatar
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.gold, AppColors.goldDark],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 60,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Pengguna CineMax',
                  style: GoogleFonts.cinzel(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'user@cinemax.app',
                  style: GoogleFonts.raleway(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 40),
                // Menu Items
                ...[
                  {'icon': Icons.history_rounded, 'label': 'Riwayat Tonton'},
                  {'icon': Icons.download_rounded, 'label': 'Download'},
                  {'icon': Icons.settings_rounded, 'label': 'Pengaturan'},
                  {'icon': Icons.info_outline_rounded, 'label': 'Tentang Aplikasi'},
                ].map((item) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider, width: 1),
                    ),
                    child: ListTile(
                      leading: Icon(
                        item['icon'] as IconData,
                        color: AppColors.gold,
                      ),
                      title: Text(
                        item['label'] as String,
                        style: GoogleFonts.raleway(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: AppColors.textMuted,
                      ),
                      onTap: () {},
                    ),
                  );
                }).toList(),
                const SizedBox(height: 40),
                // Logout Button
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.cinemaRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.cinemaRed,
                      width: 1,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {},
                      child: Center(
                        child: Text(
                          'LOGOUT',
                          style: GoogleFonts.cinzel(
                            color: AppColors.cinemaRed,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}