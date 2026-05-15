// lib/services/favorites_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/film_model.dart';

class FavoritesService {
  static const _prefKey = 'favorite_films';

  static Future<List<Film>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefKey) ?? '[]';
    try {
      final List<dynamic> list = json.decode(raw);
      return list.map((e) => Film.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> addFavorite(Film film) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    if (!favorites.any((f) => f.id == film.id)) {
      favorites.add(film);
      await prefs.setString(_prefKey, json.encode(favorites.map(_filmToJson).toList()));
    }
  }

  static Future<void> removeFavorite(String filmId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    favorites.removeWhere((f) => f.id == filmId);
    await prefs.setString(_prefKey, json.encode(favorites.map(_filmToJson).toList()));
  }

  static Future<bool> isFavorite(String filmId) async {
    final favorites = await getFavorites();
    return favorites.any((f) => f.id == filmId);
  }

  static Future<void> toggleFavorite(Film film) async {
    if (await isFavorite(film.id)) {
      await removeFavorite(film.id);
    } else {
      await addFavorite(film);
    }
  }

  static Map<String, dynamic> _filmToJson(Film f) => {
        'id': f.id,
        'judul': f.judul,
        'ringkasan': f.ringkasan,
        'gambar_poster': f.gambarPoster,
        'gambar_sampul': f.gambarSampul,
        'tanggal_rilis': f.tanggalRilis,
        'skor_rating': f.skorRating,
        'kategori': f.kategori,
        'url_trailer': f.urlTrailer,
      };
}