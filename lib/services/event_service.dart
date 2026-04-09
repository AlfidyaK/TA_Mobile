import '../models/event_model.dart';

/// SERVICE: EventService - Mengelola data event aplikasi
/// Menggunakan Singleton pattern untuk akses global dari seluruh aplikasi
/// Menyimpan event dalam memory (bukan database)
class EventService {
  // Singleton pattern: Memastikan hanya ada 1 instance EventService
  static final EventService _instance = EventService._internal();
  factory EventService() {
    return _instance;
  }
  EventService._internal();

  // --- DATA STORE ---

  final List<Event> _allEvents = [
    Event(
      id: '1',
      title: 'Emeron Hijab Hunt 2024: Noraebang',
      category: EventCategory.kpop,
      type: EventType.noraebang,
      posterUrl: 'assets/hybeEmeron.png',
      dateTime: DateTime(2024, 8, 3, 16, 0),
      location: 'Solo',
      venue: 'Parkir Depan Solo Paragon Mall',
      isFree: true,
      userId: 'user1',
    ),
    Event(
      id: '2',
      title: 'ENHYPEN World Tour: Final - Nobar',
      category: EventCategory.kpop,
      type: EventType.nobar,
      posterUrl: 'https://i.imgur.com/Jz8v2bf.jpeg',
      dateTime: DateTime(2025, 10, 26, 14, 0),
      location: 'Solo',
      venue: 'Grand Larisae Hotel',
      isFree: false,
      price: 65000,
      registrationLink: 'https://wa.me/6287811210337',
      userId: 'user2',
    ),
    Event(
      id: '3',
      title: 'HYBE Cine Fest: Cinema Noraebang',
      category: EventCategory.kpop,
      type: EventType.noraebang,
      posterUrl: 'assets/enhyCINEFEST.png',
      dateTime: DateTime(2025, 7, 10),
      location: 'Solo',
      venue: 'CGV Transmart Solo',
      isFree: false,
      price: 55000,
      bankAccount: '8782212103727 (BCA)',
      // registrationLink: 'https://wa.me/6287811210337',
      userId: 'user3',
    ),
    Event(
      id: '4',
      title: 'WONna Be Your BOY! Photobooth Event',
      category: EventCategory.kpop,
      type: EventType.photobooth,
      posterUrl: 'https://i.imgur.com/sJ2a2so.jpeg',
      dateTime: DateTime(2026, 2, 1),
      location: 'Solo',
      venue: 'Photomatics (Detail on next post)',
      isFree: false,
      price: 0,
      userId: 'user4',
    ),
    Event(
      id: '5',
      title: "Dear Jay, On Every Page: Birthday Event",
      category: EventCategory.kpop,
      type: EventType.birthdayEvent,
      posterUrl: 'assets/eventJay.png',
      dateTime: DateTime(2026, 4, 19, 14, 0),
      location: 'Solo',
      venue: 'A&M Co. Solo',
      isFree: false,
      price: 50000,
      bankAccount: '123456789 (BCA - A/N: A&M Co.)',
      userId: 'user5',
    ),
  ];

  // Data events yang terdaftar
  final List<Event> _registeredEvents = [];
  // Data user yang mendaftar ke suatu event
  final List<Registration> _registrations = [];
  final String _currentUserId = 'currentUser';    // Current user ID

  // ============ PUBLIC API ============

  /// Getter: Mendapatkan ID user saat ini
  String get currentUserId => _currentUserId;

  /// Method: Ambil SEMUA events yang tersedia
  List<Event> getAllEvents() {
    return List<Event>.from(_allEvents);
  }

  /// Method: BUAT event baru
  /// Event baru ditambahkan ke paling awal (index 0)
  void createEvent(Event event) {
    _allEvents.insert(0, event);
  }

  /// Method: Ambil EVENT yang dibuat oleh user saat ini
  List<Event> getCreatedEvents() {
    return _allEvents.where((event) => event.userId == _currentUserId).toList();
  }

  /// Method: DAFTAR ke event (simpan ke registered events)
  /// Cegah duplikat dengan cek ID
  void registerForEvent(Event event, {String name = 'User', String email = '-', String phone = '-', String? paymentProofPath}) {
    if (!_registeredEvents.any((e) => e.id == event.id)) {
      _registeredEvents.add(event);
    }
    
    // Simpan data registrasi detail
    _registrations.add(
      Registration(
        eventId: event.id,
        userName: name,
        email: email,
        phone: phone,
        paymentProofPath: paymentProofPath,
        registeredAt: DateTime.now(),
      )
    );
  }

  /// Method: Ambil daftar registrasi untuk suatu event
  List<Registration> getRegistrationsForEvent(String eventId) {
    return _registrations.where((reg) => reg.eventId == eventId).toList();
  }

  /// Method: Ambil TIKET user (events yang user daftar)
  List<Event> getRegisteredEvents() {
    return List<Event>.from(_registeredEvents);
  }
}
