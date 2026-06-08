import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/event_model.dart';
import '../screens/event_detail_screen.dart';

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({super.key, required this.event});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = event.dateTime.isBefore(DateTime.now());
    final formattedDate = DateFormat('d MMMM yyyy', 'id_ID').format(event.dateTime);
    final formattedTime = DateFormat('HH:mm').format(event.dateTime);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    /// Warna card: tetap pink di light, gelap di dark
    final cardColor = isDark ? const Color(0xFF1A1A22) : const Color(0xFFFECAF2);

    /// Warna container info (tanggal & lokasi)
    final infoBg = isDark ? const Color(0xFF2D1B4E) : const Color(0xFFFFF6FA);
    final infoBorder = isDark
        ? colorScheme.primary.withOpacity(0.2)
        : const Color(0xFFFFE5F0);

    /// Warna teks utama di dalam card
    final titleColor = isDark ? const Color(0xFFE2E2E3) : const Color(0xFF50316B);
    final infoTextColor = isDark ? const Color(0xFFE2E2E3) : const Color(0xFF2F2F2F);
    final subTextColor = isDark
        ? const Color(0xFFE2E2E3).withOpacity(0.6)
        : Colors.grey.shade600;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: isDark ? 2 : 4,
      color: cardColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EventDetailScreen(event: event),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Poster ──────────────────────────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Hero(
                    tag: event.id,
                    child: event.posterUrl.startsWith('assets/')
                        ? Image.asset(
                            event.posterUrl,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : CachedNetworkImage(
                            imageUrl: event.posterUrl,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: isDark
                                  ? const Color(0xFF2D1B4E)
                                  : Colors.grey[200],
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      colorScheme.primary),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: isDark
                                  ? const Color(0xFF2D1B4E)
                                  : Colors.grey[200],
                              child: const Icon(Icons.broken_image,
                                  size: 50, color: Colors.grey),
                            ),
                          ),
                  ),
                ),

                // Overlay "Selesai"
                if (isCompleted)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24)),
                      ),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.2)),
                          ),
                          child: const Text(
                            'Selesai',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Badge tipe event
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? null
                          : const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 172, 2, 140),
                                Color.fromARGB(255, 225, 114, 162),
                                Color.fromARGB(255, 235, 197, 226),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      color: isDark ? const Color(0xFFB01AFF) : null,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      event.type.toString().split('.').last.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ── Konten bawah poster ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul
                  Text(
                    event.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      letterSpacing: -0.5,
                      color: titleColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),

                  // Info tanggal & lokasi
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: infoBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: infoBorder),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? colorScheme.primary.withOpacity(0.15)
                                    : const Color(0xFFFFE5F0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.calendar_month_rounded,
                                  size: 18, color: colorScheme.primary),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '$formattedDate • $formattedTime WIB',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: infoTextColor,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF00D9FF).withOpacity(0.1)
                                    : const Color(0xFFE5F9FF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.location_on_rounded,
                                  size: 18, color: Color(0xFF00D9FF)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event.venue,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: infoTextColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    event.location,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: subTextColor,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Harga + Tombol
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Harga
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Harga Tiket',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            event.isFree
                                ? 'Gratis'
                                : 'Rp ${NumberFormat.decimalPattern('id_ID').format(event.price)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: event.isFree
                                  ? const Color(0xFF02A855)
                                  : (isDark
                                      ? colorScheme.primary
                                      : const Color(0xFF6B4C9A)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),

                      // ── Tombol ───────────────────────────────────────
                      Expanded(
                        child: _buildButton(
                          context,
                          isCompleted: isCompleted,
                          isDark: isDark,
                          colorScheme: colorScheme,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required bool isCompleted,
    required bool isDark,
    required ColorScheme colorScheme,
  }) {
    // Tombol "Daftar Yuk!" jika ada link registrasi dan event belum selesai
    if (event.registrationLink != null && !isCompleted) {
      return _gradientButton(
        context,
        label: 'Daftar Yuk!',
        isDark: isDark,
        colorScheme: colorScheme,
        onPressed: () => _launchUrl(event.registrationLink!),
      );
    }

    // Tombol "Lihat Detail" — event selesai
    if (isCompleted) {
      return ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EventDetailScreen(event: event),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          /// FIX: Tidak lagi pakai warna hampir-sama dengan background card.
          /// Pakai warna abu-abu netral agar kontras di semua mode.
          backgroundColor: isDark
              ? Colors.white.withOpacity(0.15)
              : Colors.black.withOpacity(0.18),
          foregroundColor: isDark ? Colors.white : const Color(0xFF3D1A5C),
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30)),
        ),
        child: const Text(
          'Lihat Detail',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      );
    }

    // Tombol "Lihat Detail" — event aktif
    return _gradientButton(
      context,
      label: 'Lihat Detail',
      isDark: isDark,
      colorScheme: colorScheme,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EventDetailScreen(event: event),
          ),
        );
      },
    );
  }

  /// Tombol dengan gradient di dark mode, solid primary di light mode
  Widget _gradientButton(
    BuildContext context, {
    required String label,
    required bool isDark,
    required ColorScheme colorScheme,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: isDark
          ? BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6BC5E7), Color(0xFF8B7CFF)],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B7CFF).withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            )
          : null,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isDark ? Colors.transparent : colorScheme.primary,
          foregroundColor: Colors.white,
          shadowColor: isDark
              ? Colors.transparent
              : colorScheme.primary.withOpacity(0.5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30)),
        ),
        child: Text(
          label,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
        ),
      ),
    );
  }
}