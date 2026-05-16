import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/film_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class FilmFormScreen extends StatefulWidget {
  final Film? film;

  const FilmFormScreen({super.key, this.film});

  @override
  State<FilmFormScreen> createState() => _FilmFormScreenState();
}

class _FilmFormScreenState extends State<FilmFormScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _categoryController;
  late final TextEditingController _summaryController;
  late final TextEditingController _posterController;
  late final TextEditingController _coverController;
  late final TextEditingController _trailerController;
  late final TextEditingController _yearController;
  late final TextEditingController _ratingController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.film?.judul ?? '');
    _categoryController = TextEditingController(text: widget.film?.kategori ?? '');
    _summaryController = TextEditingController(text: widget.film?.ringkasan ?? '');
    _posterController = TextEditingController(text: widget.film?.gambarPoster ?? '');
    _coverController = TextEditingController(text: widget.film?.gambarSampul ?? '');
    _trailerController = TextEditingController(text: widget.film?.urlTrailer ?? '');
    _yearController = TextEditingController(text: widget.film?.tanggalRilis.toString() ?? '');
    _ratingController = TextEditingController(text: widget.film?.skorRating.toString() ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _summaryController.dispose();
    _posterController.dispose();
    _coverController.dispose();
    _trailerController.dispose();
    _yearController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.raleway(color: AppColors.textPrimary),
        ),
        backgroundColor: isError ? AppColors.cinemaRed : AppColors.surfaceVariant,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _saveFilm() async {
    final title = _titleController.text.trim();
    final category = _categoryController.text.trim();
    final summary = _summaryController.text.trim();
    final poster = _posterController.text.trim();
    final cover = _coverController.text.trim();
    final trailer = _trailerController.text.trim();
    final yearText = _yearController.text.trim();
    final ratingText = _ratingController.text.trim();

    if (title.isEmpty) {
      _showSnack('Judul film wajib diisi', isError: true);
      return;
    }

    int year = 0;
    if (yearText.isNotEmpty) {
      year = int.tryParse(yearText) ?? 0;
    }

    final int rating = ratingText.isEmpty ? 0 : int.tryParse(ratingText) ?? -1;
    if (rating < 0 || rating > 100) {
      _showSnack('Skor rating harus berupa angka antara 0 dan 100', isError: true);
      return;
    }

    final body = {
      'judul': title,
      'kategori': category,
      'ringkasan': summary,
      'gambar_poster': poster,
      'gambar_sampul': cover,
      'url_trailer': trailer,
      'tanggal_rilis': year,
      'skor_rating': rating,
    };

    setState(() => _isSaving = true);
    try {
      if (widget.film == null) {
        await ApiService.createFilm(body);
        _showSnack('Film baru berhasil disimpan');
      } else {
        await ApiService.updateFilm(widget.film!.id, body);
        _showSnack('Perubahan film berhasil disimpan');
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      _showSnack('Gagal menyimpan film: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: GoogleFonts.raleway(color: AppColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.raleway(color: AppColors.textSecondary),
          hintText: hint,
          hintStyle: GoogleFonts.raleway(color: AppColors.textMuted),
          prefixIcon: icon != null ? Icon(icon, color: AppColors.textMuted) : null,
          filled: true,
          fillColor: AppColors.surfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.film != null;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Film' : 'Tambah Film',
          style: GoogleFonts.cinzel(color: AppColors.gold),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: _titleController,
                label: 'Judul',
                hint: 'Masukkan judul film',
                icon: Icons.title_outlined,
              ),
              _buildTextField(
                controller: _categoryController,
                label: 'Kategori',
                hint: 'Contoh: Aksi, Drama, Komedi',
                icon: Icons.category_outlined,
              ),
              _buildTextField(
                controller: _summaryController,
                label: 'Ringkasan',
                hint: 'Masukkan sinopsis film',
                icon: Icons.notes_outlined,
                maxLines: 4,
              ),
              _buildTextField(
                controller: _posterController,
                label: 'URL Poster',
                hint: 'https://example.com/poster.jpg',
                icon: Icons.image_outlined,
                keyboardType: TextInputType.url,
              ),
              _buildTextField(
                controller: _coverController,
                label: 'URL Sampul',
                hint: 'https://example.com/sampul.jpg',
                icon: Icons.image_outlined,
                keyboardType: TextInputType.url,
              ),
              _buildTextField(
                controller: _trailerController,
                label: 'URL Trailer',
                hint: 'https://example.com/trailer.mp4',
                icon: Icons.play_circle_outline,
                keyboardType: TextInputType.url,
              ),
              _buildTextField(
                controller: _yearController,
                label: 'Tahun Rilis',
                hint: '2024',
                icon: Icons.calendar_today_outlined,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                controller: _ratingController,
                label: 'Skor Rating',
                hint: '0 - 100',
                icon: Icons.star_outline,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _isSaving ? null : _saveFilm,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.gold, AppColors.goldDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.black)
                        : Text(
                            'SIMPAN',
                            style: GoogleFonts.cinzel(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
