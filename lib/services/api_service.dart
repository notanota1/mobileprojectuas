import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/film_model.dart';

class ApiService {
  static const String baseUrl =
      'https://68ff8dfbe02b16d1753e765d.mockapi.io/film';

  static Future<List<Film>> fetchFilms() async {
    try {
      final response = await http
          .get(Uri.parse(baseUrl))
          .timeout(const Duration(seconds: 15), onTimeout: () {
        throw Exception('API request timeout setelah 15 detik');
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        final films = data.map((json) {
          try {
            return Film.fromJson(json);
          } catch (e) {
            rethrow;
          }
        }).toList();

        final validFilms = films.where((f) => f.isValid).toList();
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

  static Future<Film> createFilm(Map<String, dynamic> body) async {
    try {
      final response = await http
          .post(Uri.parse(baseUrl),
              headers: {'Content-Type': 'application/json'},
              body: json.encode(body))
          .timeout(const Duration(seconds: 15), onTimeout: () {
        throw Exception('API request timeout setelah 15 detik');
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        return Film.fromJson(data);
      }
      throw Exception('Gagal membuat film: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error koneksi: $e');
    }
  }

  static Future<Film> updateFilm(String id, Map<String, dynamic> body) async {
    try {
      final response = await http
          .put(Uri.parse('$baseUrl/$id'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode(body))
          .timeout(const Duration(seconds: 15), onTimeout: () {
        throw Exception('API request timeout setelah 15 detik');
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Film.fromJson(data);
      }
      throw Exception('Gagal memperbarui film: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error koneksi: $e');
    }
  }

  static Future<void> deleteFilm(String id) async {
    try {
      final response = await http
          .delete(Uri.parse('$baseUrl/$id'))
          .timeout(const Duration(seconds: 15), onTimeout: () {
        throw Exception('API request timeout setelah 15 detik');
      });

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Gagal menghapus film: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error koneksi: $e');
    }
  }
}