class Film {
  final String id;
  final String judul;
  final String ringkasan;
  final String gambarPoster;
  final String gambarSampul;
  final int tanggalRilis;
  final dynamic skorRating;
  final String kategori;
  final String urlTrailer;

  Film({
    required this.id,
    required this.judul,
    required this.ringkasan,
    required this.gambarPoster,
    required this.gambarSampul,
    required this.tanggalRilis,
    required this.skorRating,
    required this.kategori,
    required this.urlTrailer,
  });

  factory Film.fromJson(Map<String, dynamic> json) {
    return Film(
      id: json['id']?.toString() ?? '',
      judul: json['judul'] ?? json['title'] ?? 'Untitled',
      ringkasan: json['ringkasan'] ?? json['summary'] ?? json['description'] ?? 'Tidak ada deskripsi',
      gambarPoster: json['gambar_poster'] ?? json['poster'] ?? json['image'] ?? '',
      gambarSampul: json['gambar_sampul'] ?? json['banner'] ?? json['backdrop'] ?? '',
      tanggalRilis: json['tanggal_rilis'] is int
          ? json['tanggal_rilis']
          : int.tryParse(json['tanggal_rilis'].toString()) ?? 0,
      skorRating: json['skor_rating'] ?? json['rating'] ?? 0,
      kategori: json['kategori'] ?? json['genre'] ?? 'Unknown',
      urlTrailer: json['url_trailer'] ?? json['trailer'] ?? '',
    );
  }

  double get ratingValue {
    if (skorRating == null) return 0;
    double raw = double.tryParse(skorRating.toString()) ?? 0;
    // Convert 0-100 scale to 0-10
    return (raw / 10).clamp(0.0, 10.0);
  }

  int get ratingPersen {
    if (skorRating == null) return 0;
    int val = (double.tryParse(skorRating.toString()) ?? 0).toInt();
    // Jika nilai > 10, anggap sudah dalam persen
    if (val > 10) return val.clamp(0, 100);
    // Jika nilai <= 10, kalikan 10 untuk konversi ke persen
    return (val * 10).clamp(0, 100);
  }

  String get tahunRilis {
    if (tanggalRilis <= 9999) return tanggalRilis.toString();
    final dt = DateTime.fromMillisecondsSinceEpoch(tanggalRilis * 1000);
    return dt.year.toString();
  }

  bool get isValidPosterUrl {
    return gambarPoster.isNotEmpty && gambarPoster.startsWith('http');
  }

  bool get isValidSampulUrl {
    return gambarSampul.isNotEmpty && gambarSampul.startsWith('http');
  }

  // Getter untuk mengecek apakah film memiliki data minimal yang valid
  bool get isValid {
    return judul.isNotEmpty;
  }
}