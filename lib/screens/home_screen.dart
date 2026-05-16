// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../models/film_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/favorites_service.dart';
import '../theme/app_theme.dart';
import '../widgets/film_card.dart';
import '../widgets/featured_banner.dart';
import 'auth_screen.dart';
import 'detail_screen.dart';
import 'history_screen.dart';
import 'manage_films_screen.dart';

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
  UniqueKey _favoritesTabKey = UniqueKey();

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

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final notifications = [
          {
            'icon': Icons.movie_filter_rounded,
            'title': 'Premiere Malam Ini',
            'subtitle': 'Jangan lewatkan tayangan perdana film terbaru.',
            'time': 'Sekarang',
          },
          {
            'icon': Icons.local_offer_rounded,
            'title': 'Diskon Tiket VIP',
            'subtitle': 'Harga spesial untuk 2 tiket pertama hari ini.',
            'time': '2 jam lalu',
          },
          {
            'icon': Icons.event_seat_rounded,
            'title': 'Tempat Duduk Terbatas',
            'subtitle': 'Kursi premium hampir habis di CineMax 1.',
            'time': '6 jam lalu',
          },
          {
            'icon': Icons.movie_creation_outlined,
            'title': 'Trailer Baru Tersedia',
            'subtitle': 'Lihat trailer eksklusif untuk film aksi terbaru.',
            'time': '1 hari lalu',
          },
          {
            'icon': Icons.star_rounded,
            'title': 'Ulasan Penggemar',
            'subtitle': 'Film favoritmu mendapatkan rating tinggi.',
            'time': '2 hari lalu',
          },
        ];

        return Padding(
          padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textMuted,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Notifikasi CineMax',
                style: GoogleFonts.cinzel(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = notifications[index];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [AppColors.goldLight, AppColors.goldDark],
                              ),
                            ),
                            child: Icon(
                              item['icon'] as IconData,
                              color: Colors.black,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title'] as String,
                                  style: GoogleFonts.cinzel(
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['subtitle'] as String,
                                  style: GoogleFonts.raleway(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            item['time'] as String,
                            style: GoogleFonts.raleway(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _goToDetail(Film film) async {
    await Navigator.push(
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

    if (_selectedNavIndex == 2 && mounted) {
      setState(() {
        _favoritesTabKey = UniqueKey();
      });
    }
  }

  Future<void> _openManageFilms() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const ManageFilmsScreen()),
    );
    if (result == true) {
      await _loadFilms();
    }
  }

  void _openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HistoryScreen()),
    );
  }

  void _showDownloadNotice() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceVariant,
        content: Text(
          'Fitur download belum tersedia di versi mockup ini.',
          style: GoogleFonts.raleway(color: AppColors.textPrimary),
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _showSettingsDialog() async {
    final prefs = await SharedPreferences.getInstance();
    bool notifEnabled = prefs.getBool('settings_notif') ?? true;
    bool autoplayEnabled = prefs.getBool('settings_autoplay') ?? false;

    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                'Pengaturan',
                style: GoogleFonts.cinzel(color: AppColors.textPrimary, fontSize: 18),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: Text(
                      'Notifikasi',
                      style: GoogleFonts.raleway(color: AppColors.textPrimary),
                    ),
                    subtitle: Text(
                      'Aktifkan notifikasi terbaru dari CineMax',
                      style: GoogleFonts.raleway(color: AppColors.textSecondary, fontSize: 12),
                    ),
                    activeColor: AppColors.gold,
                    value: notifEnabled,
                    onChanged: (value) async {
                      setState(() => notifEnabled = value);
                      await prefs.setBool('settings_notif', value);
                    },
                  ),
                  SwitchListTile(
                    title: Text(
                      'Auto-play trailer',
                      style: GoogleFonts.raleway(color: AppColors.textPrimary),
                    ),
                    subtitle: Text(
                      'Putar trailer otomatis saat membuka detail film',
                      style: GoogleFonts.raleway(color: AppColors.textSecondary, fontSize: 12),
                    ),
                    activeColor: AppColors.gold,
                    value: autoplayEnabled,
                    onChanged: (value) async {
                      setState(() => autoplayEnabled = value);
                      await prefs.setBool('settings_autoplay', value);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'TUTUP',
                    style: GoogleFonts.raleway(color: AppColors.gold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAboutApp() {
    showAboutDialog(
      context: context,
      applicationName: 'CineMax',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [AppColors.goldLight, AppColors.goldDark],
          ),
        ),
        child: const Icon(Icons.movie_filter_rounded, color: Colors.black),
      ),
      children: [
        Text(
          'CineMax adalah mockup aplikasi bioskop premium untuk menemukan dan menyimpan film favorit Anda.',
          style: GoogleFonts.raleway(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 12),
        Text(
          'Nikmati rekomendasi film, sejarah tontonan, dan pengalaman elegan dalam tampilan modern ala CineMax.',
          style: GoogleFonts.raleway(color: AppColors.textSecondary, fontSize: 13),
        ),
      ],
    );
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Konfirmasi Logout',
            style: GoogleFonts.cinzel(color: AppColors.textPrimary),
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar dari akun ini?',
            style: GoogleFonts.raleway(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('BATAL', style: GoogleFonts.raleway(color: AppColors.textMuted)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('KELUAR', style: GoogleFonts.raleway(color: AppColors.cinemaRed)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await AuthService.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
        (route) => false,
      );
    }
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
            padding: const EdgeInsets.symmetric(horizontal: 12),
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
                crossAxisCount: 3,
                childAspectRatio: 0.55,
                crossAxisSpacing: 10,
                mainAxisSpacing: 12,
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
          onPressed: _showNotifications,
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
        itemBuilder: (context, i) => Padding(
          padding: const EdgeInsets.only(right: 14),
          child: FilmCard(
            film: films[i],
            onTap: () => _goToDetail(films[i]),
            isLarge: isLarge,
          ),
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
                onTap: () => setState(() {
                      _selectedNavIndex = i;
                      if (i == 2) {
                        _favoritesTabKey = UniqueKey();
                      }
                    }),
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
          padding: const EdgeInsets.symmetric(horizontal: 12),
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
              crossAxisCount: 3,
              childAspectRatio: 0.55,
              crossAxisSpacing: 10,
              mainAxisSpacing: 12,
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
      key: _favoritesTabKey,
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildAppBar(),
        SliverToBoxAdapter(
          child: FutureBuilder<List<Film>>(
            future: FavoritesService.getFavorites(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(height: 220, child: Center(child: CircularProgressIndicator()));
              }
              final favorites = snapshot.data ?? [];
              if (favorites.isEmpty) {
                return Padding(
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
                );
              }

              return Padding(
                padding: const EdgeInsets.fromLTRB(12, 20, 12, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FAVORIT',
                      style: GoogleFonts.cinzel(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 14),
                    GridView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: favorites.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.55,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 12,
                      ),
                      itemBuilder: (context, index) {
                        final film = favorites[index];
                        return GestureDetector(
                          onTap: () => _goToDetail(film),
                          child: FilmCard(
                            film: film,
                            onTap: () => _goToDetail(film),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              );
            },
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
          child: FutureBuilder<UserModel?>(
            future: AuthService.getCurrentUser(),
            builder: (context, snapshot) {
              final user = snapshot.data;
              final displayName = user?.name.isNotEmpty == true
                  ? user!.name
                  : 'Pengguna CineMax';
              final displayEmail = user?.email.isNotEmpty == true
                  ? user!.email
                  : 'guest@cinemax.app';

              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
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
                      displayName,
                      style: GoogleFonts.cinzel(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      displayEmail,
                      style: GoogleFonts.raleway(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 40),
                    ...[
                      {
                        'icon': Icons.movie_creation_outlined,
                        'label': 'Kelola Film',
                        'action': _openManageFilms,
                      },
                      {
                        'icon': Icons.history_rounded,
                        'label': 'Riwayat Tonton',
                        'action': _openHistory,
                      },
                      {
                        'icon': Icons.download_rounded,
                        'label': 'Download',
                        'action': _showDownloadNotice,
                      },
                      {
                        'icon': Icons.settings_rounded,
                        'label': 'Pengaturan',
                        'action': _showSettingsDialog,
                      },
                      {
                        'icon': Icons.info_outline_rounded,
                        'label': 'Tentang Aplikasi',
                        'action': _showAboutApp,
                      },
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
                          onTap: item['action'] as void Function(),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 40),
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
                          onTap: _confirmLogout,
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
              );
            },
          ),
        ),
      ],
    );
  }
}