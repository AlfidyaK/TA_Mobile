import '../models/event_model.dart';

/// A singleton service to manage event data across the app.
/// This acts as a centralized in-memory database.
class EventService {
  // Singleton pattern setup
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
      posterUrl: 'https://i.imgur.com/Y1tOPtF.jpeg',
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
      posterUrl: 'https://i.imgur.com/04sYj1c.jpeg',
      dateTime: DateTime(2025, 7, 10),
      location: 'Solo',
      venue: 'CGV Transmart Solo',
      isFree: false,
      price: 60000,
      registrationLink: 'https://wa.me/6287811210337',
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
      userId: 'user5',
    ),
  ];

  final List<Event> _registeredEvents = [];
  final String _currentUserId = 'currentUser'; // Placeholder for logged-in user ID

  // --- PUBLIC API ---

  /// Get current user ID
  String get currentUserId => _currentUserId;

  /// Returns a copy of all available events.
  List<Event> getAllEvents() {
    return List<Event>.from(_allEvents);
  }

  /// Adds a new event to the master list.
  void createEvent(Event event) {
    _allEvents.insert(0, event);
  }

  /// Returns events created by the current user.
  List<Event> getCreatedEvents() {
    return _allEvents.where((event) => event.userId == _currentUserId).toList();
  }

  /// Adds an event to the user's registered list.
  void registerForEvent(Event event) {
    if (!_registeredEvents.any((e) => e.id == event.id)) {
      _registeredEvents.add(event);
    }
  }

  /// Returns events the current user has registered for.
  List<Event> getRegisteredEvents() {
    return List<Event>.from(_registeredEvents);
  }
}
