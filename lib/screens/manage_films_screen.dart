// lib/screens/manage_films_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/film_model.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import 'film_form_screen.dart';

class ManageFilmsScreen extends StatefulWidget {
  const ManageFilmsScreen({super.key});

  @override
  State<ManageFilmsScreen> createState() => _ManageFilmsScreenState();
}

class _ManageFilmsScreenState extends State<ManageFilmsScreen> {
  late Future<List<Film>> _filmsFuture;
  bool _hasMutatedData = false;

  @override
  void initState() {
    super.initState();
    _filmsFuture = ApiService.fetchFilms();
  }

  Future<void> _refreshFilms() async {
    setState(() {
      _filmsFuture = ApiService.fetchFilms();
    });
    await _filmsFuture;
  }

  Future<void> _deleteFilm(Film film) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Hapus Film',
            style: GoogleFonts.cinzel(color: AppColors.textPrimary),
          ),
          content: Text(
            'Yakin ingin menghapus "${film.judul}" dari daftar?',
            style: GoogleFonts.raleway(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('BATAL', style: GoogleFonts.raleway(color: AppColors.textMuted)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('HAPUS', style: GoogleFonts.raleway(color: AppColors.cinemaRed)),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await ApiService.deleteFilm(film.id);
      _hasMutatedData = true;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Film berhasil dihapus',
            style: GoogleFonts.raleway(color: AppColors.textPrimary),
          ),
          backgroundColor: AppColors.surfaceVariant,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
      try {
        await _refreshFilms();
      } catch (_) {}
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menghapus film: $e',
            style: GoogleFonts.raleway(color: AppColors.textPrimary),
          ),
          backgroundColor: AppColors.cinemaRed,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Future<void> _openForm({Film? film}) async {
    final isNewFilm = film == null;

    // FilmFormScreen sekarang mengembalikan String (judul) bukan bool
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => FilmFormScreen(film: film)),
    );

    if (result != null && result.isNotEmpty) {
      _hasMutatedData = true;

      // Simpan notifikasi hanya saat film BARU ditambahkan
      if (isNewFilm) {
        await NotificationService.add(AppNotification(
          title: 'Film Baru Ditambahkan',
          subtitle: '"$result" berhasil ditambahkan ke CineMax.',
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ));
      }

      await _refreshFilms();
    }
  }

  Future<bool> _onWillPop() async {
    Navigator.of(context).pop(_hasMutatedData);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            'Kelola Film',
            style: GoogleFonts.cinzel(color: AppColors.gold),
          ),
          backgroundColor: AppColors.background,
          elevation: 0,
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.gold,
          onPressed: () => _openForm(),
          child: const Icon(Icons.add, color: Colors.black),
        ),
        body: FutureBuilder<List<Film>>(
          future: _filmsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Tidak dapat memuat film: ${snapshot.error}',
                    style: GoogleFonts.raleway(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            final films = snapshot.data ?? [];
            if (films.isEmpty) {
              return Center(
                child: Text(
                  'Belum ada film tersedia',
                  style: GoogleFonts.raleway(color: AppColors.textSecondary),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: _refreshFilms,
              color: AppColors.gold,
              backgroundColor: AppColors.surface,
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: films.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final film = films[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: film.gambarPoster,
                          width: 56,
                          height: 80,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 56,
                            height: 80,
                            color: AppColors.shimmerBase,
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 56,
                            height: 80,
                            color: AppColors.surface,
                            child: const Icon(Icons.movie, color: AppColors.textMuted),
                          ),
                        ),
                      ),
                      title: Text(
                        film.judul,
                        style: GoogleFonts.cinzel(color: AppColors.textPrimary, fontSize: 14),
                      ),
                      subtitle: Text(
                        film.kategori,
                        style: GoogleFonts.raleway(color: AppColors.textSecondary, fontSize: 12),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: AppColors.gold),
                            onPressed: () => _openForm(film: film),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_forever, color: AppColors.cinemaRed),
                            onPressed: () => _deleteFilm(film),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}