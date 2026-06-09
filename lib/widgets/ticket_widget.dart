import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/event_model.dart';

/// WIDGET: TicketWidget - Kartu tiket digital event
/// Terkoneksi dengan Database & Responsif Terhadap Mode Terang/Gelap
class TicketWidget extends StatelessWidget {
  final Event event;
  final String registrationId; // ID Registrasi asli dari Supabase
  final String status;         // 'pending' atau 'success'

  const TicketWidget({
    super.key, 
    required this.event,
    required this.registrationId,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    // Warna dinamis mengikuti tema
    final ticketBg = isDark ? const Color(0xFF1E1E28) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final subTextColor = isDark ? Colors.white60 : Colors.black54;
    final shadowColor = isDark ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.12);
    final dashColor = isDark ? Colors.white24 : Colors.grey.shade400;

    // Memendekkan UUID Supabase menjadi 8 karakter untuk tampilan Booking ID
    final shortId = registrationId.split('-').first.toUpperCase();
    final bookingId = 'EVG-$shortId';
    
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Cek status tiket
    final isVerified = status.toLowerCase() == 'success' || event.isFree;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: ticketBg,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: 2, // Memberikan efek timbul yang lebih jelas
          ),
        ],
      ),
      child: ClipPath(
        clipper: TicketClipper(),
        child: Container(
          color: ticketBg,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- Top Section: Poster and Info ---
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.network(
                        event.posterUrl,
                        width: 85,
                        height: 115,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 85,
                          height: 115,
                          color: isDark ? Colors.white12 : Colors.grey[200],
                          child: Icon(
                            Icons.image_not_supported,
                            color: isDark ? Colors.white38 : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              event.type.toString().split('.').last.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.calendar_month_rounded, size: 14, color: subTextColor),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('EEE, dd MMM | HH:mm', 'id_ID').format(event.dateTime),
                                style: TextStyle(fontSize: 13, color: subTextColor, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on_rounded, size: 14, color: subTextColor),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  event.venue,
                                  style: TextStyle(fontSize: 13, color: subTextColor),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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

              // --- Banner Status Tiket ---
              Container(
                width: double.infinity,
                color: isVerified 
                    ? (isDark ? Colors.green.withOpacity(0.2) : Colors.green.shade50)
                    : (isDark ? Colors.orange.withOpacity(0.2) : Colors.orange.shade50),
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isVerified ? Icons.check_circle_rounded : Icons.hourglass_top_rounded,
                      size: 16,
                      color: isVerified ? Colors.green.shade500 : Colors.orange.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isVerified 
                          ? 'TIKET AKTIF & TERVERIFIKASI' 
                          : 'MENUNGGU VERIFIKASI PEMBAYARAN',
                      style: TextStyle(
                        fontSize: 12,
                        color: isVerified 
                            ? (isDark ? Colors.greenAccent : Colors.green.shade700) 
                            : (isDark ? Colors.orangeAccent : Colors.orange.shade800),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              // --- QR Code and Booking Info ---
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    // Kotak QR Code
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white, // QR Code harus selalu punya background putih agar bisa discan
                        border: Border.all(color: Colors.grey.shade300, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: QrImageView(
                        data: '{"event_id": "${event.id}", "reg_id": "$registrationId"}',
                        version: QrVersions.auto,
                        size: 90.0,
                        foregroundColor: isVerified ? Colors.black : Colors.black26, 
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '1 Ticket(s)',
                            style: TextStyle(
                              fontSize: 13,
                              color: subTextColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            event.category.toString().split('.').last.toUpperCase(),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: colorScheme.primary,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white12 : Colors.black.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              event.isFree ? 'FREE ENTRY' : 'REGULAR TICKET',
                              style: TextStyle(
                                fontSize: 11,
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'BOOKING ID: $bookingId',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // --- Cancellation Notice ---
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Cancellation not available for this venue',
                  style: TextStyle(fontSize: 11, color: subTextColor),
                ),
              ),

              // --- Dashed Divider ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: DashedDivider(color: dashColor),
              ),

              // --- Total Amount ---
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Pembayaran',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: subTextColor,
                      ),
                    ),
                    Text(
                      event.isFree
                          ? 'Gratis'
                          : currencyFormatter.format(event.price),
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),

              // --- Find Venue Button ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2A2A36) : const Color(0xFFF8F8FA),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16.0),
                    bottomRight: Radius.circular(16.0),
                  ),
                  border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map_outlined,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Lihat Lokasi Venue',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// WIDGET BANTUAN DI BAWAH INI TETAP SAMA
// ============================================================================

class DashedDivider extends StatelessWidget {
  const DashedDivider({super.key, this.height = 1, this.color = Colors.grey});

  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 6.0;
        final dashHeight = height;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(decoration: BoxDecoration(color: color)),
            );
          }),
        );
      },
    );
  }
}

class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const radius = 16.0;
    const notchRadius = 14.0; // Sedikit dibesarkan agar lekukan tiket lebih tegas
    final notchY = size.height - 125.0; // Disesuaikan dengan tinggi baru area bawah

    path.moveTo(0, radius);
    path.arcToPoint(
      const Offset(radius, 0),
      radius: const Radius.circular(radius),
      clockwise: false,
    );
    path.lineTo(size.width - radius, 0);
    path.arcToPoint(
      Offset(size.width, radius),
      radius: const Radius.circular(radius),
      clockwise: false,
    );

    path.lineTo(size.width, notchY - notchRadius);
    path.arcToPoint(
      Offset(size.width, notchY + notchRadius),
      radius: const Radius.circular(notchRadius),
      clockwise: true,
    );

    path.lineTo(size.width, size.height - radius);
    path.arcToPoint(
      Offset(size.width - radius, size.height),
      radius: const Radius.circular(radius),
      clockwise: false,
    );
    path.lineTo(radius, size.height);
    path.arcToPoint(
      Offset(0, size.height - radius),
      radius: const Radius.circular(radius),
      clockwise: false,
    );

    path.lineTo(0, notchY + notchRadius);
    path.arcToPoint(
      Offset(0, notchY - notchRadius),
      radius: const Radius.circular(notchRadius),
      clockwise: true,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}