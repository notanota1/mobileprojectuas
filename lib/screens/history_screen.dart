import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<Map<String, dynamic>>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _loadHistory();
  }

  Future<List<Map<String, dynamic>>> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('watch_history') ?? '[]';
    final list = json.decode(raw) as List<dynamic>;
    return list
        .map((item) => Map<String, dynamic>.from(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> _refresh() async {
    setState(() {
      _historyFuture = _loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Riwayat Tonton',
          style: GoogleFonts.cinzel(color: AppColors.gold),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final history = snapshot.data ?? [];
          if (history.isEmpty) {
            return Center(
              child: Text(
                'Belum ada riwayat tontonan',
                style: GoogleFonts.raleway(color: AppColors.textSecondary),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.gold,
            backgroundColor: AppColors.surface,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final entry = history[index];
                final ts = entry['timestamp'] as int? ?? 0;
                final time = DateTime.fromMillisecondsSinceEpoch(ts);
                final elapsed = '${time.day}/${time.month}/${time.year} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                final poster = entry['gambar_poster'] as String? ?? '';

                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: poster.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: poster,
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
                          )
                        : Container(
                            width: 56,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.movie, color: AppColors.textMuted),
                          ),
                    title: Text(
                      entry['judul'] as String? ?? 'Film tidak dikenal',
                      style: GoogleFonts.cinzel(color: AppColors.textPrimary, fontSize: 14),
                    ),
                    subtitle: Text(
                      elapsed,
                      style: GoogleFonts.raleway(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
