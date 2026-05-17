// lib/services/watchlist_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/film_model.dart';

class WatchlistService {
  static const String _key = 'watchlist';

  /// Ambil semua film di watchlist
  static Future<List<Map<String, dynamic>>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key) ?? '[]';
    final List<dynamic> list = json.decode(raw) as List<dynamic>;
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  /// Cek apakah film sudah ada di watchlist
  static Future<bool> isInWatchlist(String filmId) async {
    final list = await getAll();
    return list.any((item) => item['id'] == filmId);
  }

  /// Tambah film ke watchlist
  static Future<void> add(Film film) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getAll();

    // Hindari duplikat
    if (list.any((item) => item['id'] == film.id)) return;

    list.insert(0, {
      'id': film.id,
      'judul': film.judul,
      'gambar_poster': film.gambarPoster,
      'kategori': film.kategori,
      'tahun_rilis': film.tahunRilis,
      'rating_persen': film.ratingPersen,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    await prefs.setString(_key, json.encode(list));
  }

  /// Hapus film dari watchlist
  static Future<void> remove(String filmId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getAll();
    list.removeWhere((item) => item['id'] == filmId);
    await prefs.setString(_key, json.encode(list));
  }

  /// Toggle: tambah jika belum ada, hapus jika sudah ada
  static Future<bool> toggle(Film film) async {
    final already = await isInWatchlist(film.id);
    if (already) {
      await remove(film.id);
      return false; // dihapus dari watchlist
    } else {
      await add(film);
      return true; // ditambahkan ke watchlist
    }
  }
}