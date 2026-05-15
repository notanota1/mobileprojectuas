import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/film_model.dart';

class ApiService {
  static const String baseUrl =
      'https://68ff8dfbe02b16d1753e765d.mockapi.io/film';

  static bool _isValidHttpUrl(String url) {
    try {
      if (url.isEmpty) return false;
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  static Future<List<Film>> fetchFilms() async {
    try {
      final response = await http
          .get(Uri.parse(baseUrl))
          .timeout(const Duration(seconds: 15), onTimeout: () {
        throw Exception('API request timeout setelah 15 detik');
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        if (data.isEmpty) {
          throw Exception('API mengembalikan data kosong');
        }

        final films = data.map((json) {
          try {
            return Film.fromJson(json);
          } catch (e) {
            rethrow;
          }
        }).toList();

        final validFilms = films.where((f) => f.isValid).toList();

        if (validFilms.isEmpty) {
          throw Exception('Tidak ada film dengan data valid ditemukan');
        }

        return validFilms;
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