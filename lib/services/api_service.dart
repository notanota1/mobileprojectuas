import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/film_model.dart';

class ApiService {
  static const String baseUrl =
      'https://68ff8dfbe02b16d1753e765d.mockapi.io/film';

  static Future<List<Film>> fetchFilms() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final films = data.map((json) => Film.fromJson(json)).toList();
        // Filter hanya film dengan poster URL valid
        return films.where((f) => f.isValidPosterUrl).toList();
      } else {
        throw Exception('Gagal memuat data film: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error koneksi: $e');
    }
  }

  static Future<Film> fetchFilmById(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$id'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Film.fromJson(data);
      } else {
        throw Exception('Film tidak ditemukan');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}