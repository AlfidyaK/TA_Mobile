import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/event_model.dart';
import '../screens/event_detail_screen.dart';

/// WIDGET: EventCard - Kartu event untuk listing
/// Menampilkan: poster, badge, judul, lokasi, jam, harga, & tombol
class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({super.key, required this.event});

  /// Fungsi untuk membuka URL registrasi di browser/WhatsApp
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

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      color: const Color.fromARGB(255, 254, 202, 242),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailScreen(event: event),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9D4EDD)),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                            ),
                          ),
                  ),
                ),
                if (isCompleted)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                      ),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
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
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: Theme.of(context).brightness == Brightness.dark
                          ? null
                          : const LinearGradient(
                              colors: [Color.fromARGB(255, 235, 43, 200), Color.fromARGB(255, 242, 156, 193), Color.fromARGB(255, 255, 255, 255)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFB01AFF) : null,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFFB01AFF).withOpacity(0.6)
                              : Theme.of(context).colorScheme.primary.withOpacity(0.4),
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
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      letterSpacing: -0.5,
                      color: Color.fromARGB(255, 80, 49, 105),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 246, 250),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFFE5F0)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFE5F0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.calendar_month_rounded, size: 18, color: Color(0xFF9D4EDD)),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '$formattedDate • $formattedTime WIB',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2F2F2F),
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
                                color: const Color(0xFFE5F9FF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.location_on_rounded, size: 18, color: Color(0xFF00D9FF)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event.venue,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF2F2F2F),
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    event.location,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Harga Tiket',
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(0xFF9D4EDD),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            event.isFree ? 'Gratis' : 'Rp ${NumberFormat.decimalPattern('id_ID').format(event.price)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: event.isFree ? const Color.fromARGB(255, 2, 138, 64): const Color(0xFF6B4C9A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      if (event.registrationLink != null && !isCompleted)
                        Expanded(
                          child: Container(
                            decoration: Theme.of(context).brightness == Brightness.dark ? BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFF6BC5E7), Color(0xFF8B7CFF)]),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF8B7CFF).withOpacity(0.5),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ) : null,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Theme.of(context).colorScheme.primary,
                                shadowColor: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Theme.of(context).colorScheme.primary.withOpacity(0.5),
                              ),
                              onPressed: () => _launchUrl(event.registrationLink!),
                              child: const Text(
                                'Daftar Yuk!',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                              ),
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: Container(
                            decoration: (!isCompleted && Theme.of(context).brightness == Brightness.dark) ? BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFF6BC5E7), Color(0xFF8B7CFF)]),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF8B7CFF).withOpacity(0.5),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ) : null,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EventDetailScreen(event: event),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isCompleted ? const Color.fromARGB(255, 240, 222, 245) : (Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Theme.of(context).colorScheme.primary),
                                shadowColor: (isCompleted || Theme.of(context).brightness == Brightness.dark) ? Colors.transparent : Theme.of(context).colorScheme.primary.withOpacity(0.5),
                                foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                              ),
                              child: const Text('Lihat Detail', style: TextStyle(fontSize: 13)),
                            ),
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
}
