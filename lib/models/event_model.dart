
/// ENUM & MODEL: Data Event

/// Kategori event fandom (K-pop, Jepang, dll)
enum EventCategory { kpop, jepang, lainnya }

/// Tipe/jenis event (Karaoke, Nobar, Photobooth, dll)
enum EventType { noraebang, nobar, photobooth, birthdayEvent, konser, lainnya }

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
  final EventType type;                 // Jenis event
  final String posterUrl;               // URL gambar poster
  final DateTime dateTime;              // Tanggal & waktu event
  final String location;                // Lokasi (kota)
  final String venue;                   // Nama tempat/venue
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
    this.registrationLink,
    required this.userId,
    this.isCompleted = false,
    this.bankAccount,
  });
}
