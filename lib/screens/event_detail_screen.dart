import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';
import 'registration_screen.dart';
import 'view_registrants_screen.dart';
import '../services/event_service.dart';

/// SCREEN: EventDetailScreen - Layar detail lengkap event
/// Menampilkan: poster besar, info lengkap, dan tombol daftar
class EventDetailScreen extends StatefulWidget {
  final Event event;                      // Event yang ditampilkan

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(widget.event.dateTime);
    final formattedTime = DateFormat('HH:mm').format(widget.event.dateTime);
    final bool isCompleted = widget.event.dateTime.isBefore(DateTime.now());
    final eventService = EventService();
    final bool isMyEvent = widget.event.userId == eventService.currentUserId;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 48.0, right: 16.0, bottom: 16.0), // give space for back button on left
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
                maxLines: 2, // Allow up to 2 lines
                overflow: TextOverflow.ellipsis,
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: widget.event.id, // Use a unique tag for the Hero animation
                    child: widget.event.posterUrl.startsWith('assets/')
                        ? Image.asset(
                            widget.event.posterUrl,
                            fit: BoxFit.cover,
                          )
                        : CachedNetworkImage(
                            imageUrl: widget.event.posterUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9D4EDD)),
                              ),
                            ),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          ),
                  ),
                  // Gradient shadow supaya judul lebih mudah dibaca meskipun poster terang
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(Icons.calendar_today, 'Tanggal & Waktu', '$formattedDate - $formattedTime WIB'),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.location_on, 'Lokasi', '${widget.event.venue}\n${widget.event.location}'),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.category, 'Jenis Event', widget.event.type.toString().split('.').last),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    Icons.confirmation_number,
                    'Tiket',
                    widget.event.isFree ? 'Gratis' : 'Rp ${NumberFormat.decimalPattern('id_ID').format(widget.event.price)}',
                    color: widget.event.isFree ? const Color(0xFF00BFA5) : const Color(0xFFE57373),
                  ),
                  if (!widget.event.isFree && widget.event.bankAccount != null) ...[
                    const SizedBox(height: 16),
                    _buildDetailRow(
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
        ],
      ),
      bottomNavigationBar: (!isCompleted) // Show button if the event is not completed
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () async {
                  if (isMyEvent) {
                    // Navigate to check registrants list 
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewRegistrantsScreen(event: widget.event),
                      ),
                    );
                  } else {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegistrationScreen(event: widget.event),
                      ),
                    );
                    if (result == true) {
                      Navigator.pop(context, true);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: Text(isMyEvent ? 'Lihat Pendaftar' : 'Registrasi Sekarang'),
              ),
            )
          : null,
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String content, {Color? color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(content, style: TextStyle(fontSize: 16, color: color)),
            ],
          ),
        ),
      ],
    );
  }
}
