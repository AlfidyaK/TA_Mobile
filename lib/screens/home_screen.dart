import 'package:eventgo/services/event_service.dart';
import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../widgets/event_card.dart';
import 'filter_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final EventService _eventService = EventService();
  late List<Event> _allEvents;
  List<Event> _filteredEvents = [];
  String _selectedChipFilter = 'Semua';
  FilterValues _advancedFilters = FilterValues();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _allEvents = _eventService.getAllEvents();
    _applyAllFilters();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _reloadEvents();
    }
  }

  void _reloadEvents() {
    setState(() {
      _allEvents = _eventService.getAllEvents();
      _applyAllFilters();
    });
  }

  // Public method to reload events (called from MainScreen)
  void reloadEvents() {
    _reloadEvents();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _applyAllFilters() {
    final now = DateTime.now();
    setState(() {
      List<Event> tempEvents = List.from(_allEvents);

      // Chip filters
      switch (_selectedChipFilter) {
        case 'K-Pop':
          tempEvents = tempEvents.where((e) => e.category == EventCategory.kpop).toList();
          break;
        case 'Musik':
          tempEvents = tempEvents.where((e) => e.type == EventType.konser).toList();
          break;
        case 'Segera':
          tempEvents = tempEvents.where((e) => e.dateTime.isAfter(now)).toList()
            ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
          break;
        case 'Terbaru':
          tempEvents = tempEvents.where((e) => e.dateTime.isBefore(now) || e.dateTime.isAtSameMomentAs(now)).toList()
            ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
          break;
      }

      // Advanced filters
      if (_advancedFilters.location != null) {
        final locFilter = _advancedFilters.location!.toLowerCase();
        tempEvents = tempEvents.where((e) {
          final loc = e.location.toLowerCase();
          if (locFilter == 'di yogyakarta') {
            return loc.contains('yogyakarta') || loc.contains('jogja') || loc.contains('sleman') || loc.contains('bantul');
          } else if (locFilter == 'jawa tengah') {
            return loc.contains('semarang') || loc.contains('solo') || loc.contains('surakarta') || loc.contains('jawa tengah') || loc.contains('jateng') || loc.contains('magelang') || loc.contains('purwokerto');
          } else if (locFilter == 'jawa barat') {
            return loc.contains('bandung') || loc.contains('bogor') || loc.contains('bekasi') || loc.contains('depok') || loc.contains('jawa barat') || loc.contains('jabar') || loc.contains('cirebon');
          } else if (locFilter == 'jawa timur') {
            return loc.contains('surabaya') || loc.contains('malang') || loc.contains('sidoarjo') || loc.contains('jawa timur') || loc.contains('jatim') || loc.contains('batu');
          } else if (locFilter == 'dki jakarta' || locFilter == 'jabodetabek') {
            return loc.contains('jakarta') || loc.contains('bogor') || loc.contains('depok') || loc.contains('tangerang') || loc.contains('bekasi');
          } else if (locFilter == 'banten') {
            return loc.contains('banten') || loc.contains('tangerang') || loc.contains('serang');
          } else if (locFilter == 'bali') {
            return loc.contains('bali') || loc.contains('denpasar') || loc.contains('badung') || loc.contains('kuta');
          }
          return loc.contains(locFilter);
        }).toList();
      }

      if (_advancedFilters.eventType != null) {
        final type = EventType.values.firstWhere(
          (e) => e.toString().split('.').last.toLowerCase() == _advancedFilters.eventType!.toLowerCase(),
          orElse: () => EventType.lainnya,
        );
        if (type != EventType.lainnya) {
          tempEvents = tempEvents.where((e) => e.type == type).toList();
        }
      }

      if (_advancedFilters.price != null) {
        if (_advancedFilters.price == 'Gratis') {
          tempEvents = tempEvents.where((e) => e.isFree).toList();
        } else if (_advancedFilters.price == 'Berbayar') {
          tempEvents = tempEvents.where((e) => !e.isFree).toList();
        }
      }

      // Sort events so that uncompleted are on top
      tempEvents.sort((a, b) {
        final now = DateTime.now();
        final aCompleted = a.dateTime.isBefore(now);
        final bCompleted = b.dateTime.isBefore(now);
        
        if (aCompleted && !bCompleted) return 1;
        if (!aCompleted && bCompleted) return -1;
        
        if (_selectedChipFilter == 'Terbaru') {
          return b.dateTime.compareTo(a.dateTime);
        } else {
          return a.dateTime.compareTo(b.dateTime);
        }
      });

      _filteredEvents = tempEvents;
    });
  }

  void _openFilterScreen() async {
    final newFilters = await Navigator.push<FilterValues>(
      context,
      MaterialPageRoute(
        builder: (context) => FilterScreen(initialFilters: _advancedFilters),
      ),
    );

    if (newFilters != null) {
      setState(() {
        _advancedFilters = newFilters;
        _applyAllFilters();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A10) : Colors.white,
      appBar: AppBar(
        title: const Text('eventGO', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24, letterSpacing: -0.5)),
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF0A0A10) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: isDark 
                  ? const Color(0xFF1A1A22)
                  : const Color(0xFFF0E6FF),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.tune_rounded, color: isDark ? Colors.white : const Color(0xFF9D4EDD)),
              onPressed: _openFilterScreen,
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark 
                ? const [Color(0xFF0A0A10), Color(0xFF1A1A22)]
                : const [Color(0xFFFAFAFC), Color(0xFFFFF0F5)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Text(
                'Temukan event seru di sekitarmu! ✨',
                style: TextStyle(
                  fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2F2F2F),
                letterSpacing: -0.5,
              ),
            ),
          ),
          _buildFilterChips(),
          Expanded(
            child: _filteredEvents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'Yah, tidak ada event\nyang cocok 😢',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                        )
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _filteredEvents.length,
                    itemBuilder: (context, index) {
                      return EventCard(event: _filteredEvents[index]);
                    },
                  ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['Semua', 'K-Pop', 'Musik', 'Segera', 'Terbaru'];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: 70,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        children: filters.map((filter) {
          final isSelected = _selectedChipFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: FilterChip(
              label: Text(
                filter,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF6B677A),
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
              selected: isSelected,
              showCheckmark: false,
              backgroundColor: isDark ? const Color(0xFF1A1A22) : const Color(0xFFFFF0F5),
              selectedColor: const Color(0xFF9D4EDD),
              elevation: isSelected ? 3 : 0,
              pressElevation: 0,
              shadowColor: const Color(0xFF9D4EDD).withOpacity(0.4),
              side: BorderSide(
                color: isSelected 
                    ? Colors.transparent 
                    : (isDark ? const Color(0xFF6B677A) : const Color(0xFFE8D5F2)),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedChipFilter = filter;
                    _applyAllFilters();
                  });
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
