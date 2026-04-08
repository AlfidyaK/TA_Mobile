
enum EventCategory { kpop, jepang, lainnya }
enum EventType { noraebang, nobar, photobooth, birthdayEvent, konser, lainnya }

class Event {
  final String id;
  final String title;
  final EventCategory category;
  final EventType type;
  final String posterUrl;
  final DateTime dateTime;
  final String location;
  final String venue;
  final bool isFree;
  final double? price;
  final String? registrationLink;
  final String userId;
  final bool isCompleted;

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
  });
}
