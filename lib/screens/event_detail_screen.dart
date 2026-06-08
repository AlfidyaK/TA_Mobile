import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';
import 'registration_screen.dart';
import 'view_registrants_screen.dart';
import '../services/event_service.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(widget.event.dateTime);
    final formattedTime = DateFormat('HH:mm').format(widget.event.dateTime);
    final bool isCompleted = widget.event.dateTime.isBefore(DateTime.now());
    final eventService = EventService();
    final bool isMyEvent = widget.event.userId == eventService.currentUserId;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar dengan poster ──────────────────────────────
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: const EdgeInsets.only(
                  left: 48.0, right: 16.0, bottom: 16.0),
              title: Text(
                widget.event.title,
                style: const TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 8.0,
                      color: Colors.black,
                      offset: Offset(2.0, 2.0),
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: widget.event.id,
                    child: widget.event.posterUrl.startsWith('assets/')
                        ? Image.asset(widget.event.posterUrl, fit: BoxFit.cover)
                        : CachedNetworkImage(
                            imageUrl: widget.event.posterUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    colorScheme.primary),
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Detail konten ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                /// FIX: Background body mengikuti scaffoldBackground theme
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                      context,
                      Icons.calendar_today,
                      'Tanggal & Waktu',
                      '$formattedDate - $formattedTime WIB',
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      context,
                      Icons.location_on,
                      'Lokasi',
                      '${widget.event.venue}\n${widget.event.location}',
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      context,
                      Icons.category,
                      'Jenis Event',
                      widget.event.type.toString().split('.').last,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      context,
                      Icons.confirmation_number,
                      'Tiket',
                      widget.event.isFree
                          ? 'Gratis'
                          : 'Rp ${NumberFormat.decimalPattern('id_ID').format(widget.event.price)}',
                      valueColor: widget.event.isFree
                          ? const Color(0xFF00BFA5)
                          : const Color(0xFFE57373),
                    ),
                    if (!widget.event.isFree &&
                        widget.event.bankAccount != null) ...[
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        context,
                        Icons.account_balance_wallet,
                        'Nomor Rekening (namaBank)',
                        widget.event.bankAccount!,
                      ),
                    ],
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // ── Tombol bawah ─────────────────────────────────────────────────
      bottomNavigationBar: !isCompleted
          ? Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: BoxDecoration(
                /// FIX: Background bottom bar mengikuti surface theme
                color: isDark
                    ? const Color(0xFF1A1A22)
                    : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    if (isMyEvent) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ViewRegistrantsScreen(event: widget.event),
                        ),
                      );
                    } else {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              RegistrationScreen(event: widget.event),
                        ),
                      );
                      if (result == true) Navigator.pop(context, true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    /// FIX: foregroundColor putih agar teks tombol selalu kelihatan
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  child: Text(isMyEvent ? 'Lihat Pendaftar' : 'Registrasi Sekarang'),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String title,
    String content, {
    Color? valueColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// FIX: Icon warna dari onSurface dengan opacity, bukan Colors.grey[600] hardcode
        Icon(icon, color: colorScheme.onSurface.withOpacity(0.5), size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  /// FIX: Warna judul dari colorScheme.onSurface
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: TextStyle(
                  fontSize: 15,
                  /// FIX: Jika tidak ada valueColor khusus, pakai onSurface dengan opacity
                  color: valueColor ?? colorScheme.onSurface.withOpacity(0.75),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}