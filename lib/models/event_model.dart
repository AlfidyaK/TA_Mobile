
/// ENUM & MODEL: Data Event

/// Kategori event fandom (K-pop, Jepang, dll)
enum EventCategory { kpop, jepang, lainnya }

class Registration {
  final String eventId;
  final String userName;
  final String email;
  final String phone;
  final String? paymentProofPath; // path ke bukti pembayaran kalau ada
  final DateTime registeredAt;

  Registration({
    required this.eventId,
    required this.userName,
    required this.email,
    required this.phone,
    this.paymentProofPath,
    required this.registeredAt,
  });
}

/// Model Event: Struktur data untuk setiap event
/// Menyimpan informasi lengkap event dari ID hingga harga tiket
class Event {
  final String id;                      // ID unik event
  final String title;                   // Nama event
  final EventCategory category;         // Kategori fandom
  final String type;                    // Jenis event (Contoh: noraebang, nobar, dll)
  final String posterUrl;               // URL gambar poster
  final DateTime dateTime;              // Tanggal & waktu event
  final String location;                // Lokasi (kota)
  final String venue;                   // Nama tempat/venue
  final String organizeName;           // Nama penyelenggara
  final bool isFree;                    // Gratis atau berbayar
  final double? price;                  // Harga tiket (opsional)
  final String? registrationLink;       // Link daftar (opsional)
  final String userId;                  // ID user pembuat event
  final bool isCompleted;               // Apakah event sudah selesai
  final String? bankAccount;            // Nomor rekening (opsional, untuk event berbayar)

  Event({
    required this.id,
    required this.title,
    required this.category,
    required this.type,
    required this.posterUrl,
    required this.dateTime,
    required this.location,
    required this.venue,
    this.isFree = true,
    this.price,
    this.organizeName = 'EventGo User',
    this.registrationLink,
    required this.userId,
    this.isCompleted = false,
    this.bankAccount,
  });
  factory Event.fromSupabase(Map<String, dynamic> data) {
  // Parse EventCategory dari string
  EventCategory parseCategory(String? val) {
    switch (val?.toLowerCase()) {
      case 'kpop': return EventCategory.kpop;
      case 'jepang': return EventCategory.jepang;
      default: return EventCategory.lainnya;
    }
  }

  final price = (data['ticket_price'] as num?)?.toDouble() ?? 0;

  return Event(
    id: data['id'].toString(),
    title: data['title'] ?? '',
    category: parseCategory(data['fandom_category']),
    type: data['event_type'] ?? '',
    posterUrl: data['poster_url'] ?? 'https://placehold.co/600x800',
    dateTime: DateTime.parse(data['event_date']),
    location: data['location_region'] ?? '',
    venue: data['location_name'] ?? '',
    isFree: price == 0,
    price: price > 0 ? price : null,
    organizeName: data['organize_name'] ?? 'Penyelenggara Anonim',
    bankAccount: data['bank_account_info'],
    userId: data['creator_id'] ?? '',
  );
}
}
