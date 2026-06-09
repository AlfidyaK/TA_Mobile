import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event_model.dart';
import '../widgets/event_card.dart';
import '../widgets/event_logo.dart';
import 'filter_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final _supabase = Supabase.instance.client;

  List<Event> _allEvents = [];
  List<Event> _filteredEvents = [];
  String _selectedChipFilter = 'Semua';
  FilterValues _advancedFilters = FilterValues();
  bool _isLoading = false;
  
  // FIX: Controller untuk fitur search ketik
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadEvents();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _loadEvents();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  void reloadEvents() => _loadEvents();

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase
          .from('events')
          .select()
          .order('created_at', ascending: false);

      final events = (response as List)
          .map((data) => Event.fromSupabase(data))
          .toList();

      if (mounted) {
        setState(() {
          _allEvents = events;
          _isLoading = false;
        });
        _applyAllFilters();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat events: $e')),
        );
      }
    }
  }

  void _applyAllFilters() {
    final now = DateTime.now();
    setState(() {
      List<Event> tempEvents = List.from(_allEvents);

      // 1. Filter dari Search Bar (Teks)
      if (_searchQuery.isNotEmpty) {
        tempEvents = tempEvents.where((e) => 
          e.title.toLowerCase().contains(_searchQuery.toLowerCase())
        ).toList();
      }

      // 2. Filter dari Chip
      switch (_selectedChipFilter) {
        case 'K-Pop':
          tempEvents = tempEvents.where((e) => e.category == EventCategory.kpop).toList();
          break;
        case 'Musik':
          tempEvents = tempEvents.where((e){
            final typeLower = e.type.toLowerCase();
            return typeLower.contains('konser') || typeLower.contains('musik') || typeLower.contains('noraebang');
          }).toList();
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

      // 3. Filter Lanjutan (Lokasi, Tipe, Harga)
      if (_advancedFilters.location != null) {
        final locFilter = _advancedFilters.location!.toLowerCase();
        tempEvents = tempEvents.where((e) {
          final loc = e.location.toLowerCase();
          if (locFilter == 'di yogyakarta') return loc.contains('yogyakarta') || loc.contains('jogja') || loc.contains('sleman') || loc.contains('bantul');
          if (locFilter == 'jawa tengah') return loc.contains('semarang') || loc.contains('solo') || loc.contains('surakarta') || loc.contains('jawa tengah') || loc.contains('jateng') || loc.contains('magelang') || loc.contains('purwokerto');
          if (locFilter == 'jawa barat') return loc.contains('bandung') || loc.contains('bogor') || loc.contains('bekasi') || loc.contains('depok') || loc.contains('jawa barat') || loc.contains('jabar') || loc.contains('cirebon');
          if (locFilter == 'jawa timur') return loc.contains('surabaya') || loc.contains('malang') || loc.contains('sidoarjo') || loc.contains('jawa timur') || loc.contains('jatim') || loc.contains('batu');
          if (locFilter == 'dki jakarta' || locFilter == 'jabodetabek') return loc.contains('jakarta') || loc.contains('bogor') || loc.contains('depok') || loc.contains('tangerang') || loc.contains('bekasi');
          if (locFilter == 'banten') return loc.contains('banten') || loc.contains('tangerang') || loc.contains('serang');
          if (locFilter == 'bali') return loc.contains('bali') || loc.contains('denpasar') || loc.contains('badung') || loc.contains('kuta');
          return loc.contains(locFilter);
        }).toList();
      }

      if (_advancedFilters.eventType != null) {
        // SESUAIKAN: Cocokkan kata dari filter lanjutan dengan ketikan user di database
        final typeFilter = _advancedFilters.eventType!.toLowerCase();
        tempEvents = tempEvents.where((e) => e.type.toLowerCase().contains(typeFilter)).toList();
      }

      if (_advancedFilters.price != null) {
        if (_advancedFilters.price == 'Gratis') tempEvents = tempEvents.where((e) => e.isFree).toList();
        else if (_advancedFilters.price == 'Berbayar') tempEvents = tempEvents.where((e) => !e.isFree).toList();
      }

      // Pengurutan
      tempEvents.sort((a, b) {
        final aCompleted = a.dateTime.isBefore(now);
        final bCompleted = b.dateTime.isBefore(now);
        if (aCompleted && !bCompleted) return 1;
        if (!aCompleted && bCompleted) return -1;
        return _selectedChipFilter == 'Terbaru' ? b.dateTime.compareTo(a.dateTime) : a.dateTime.compareTo(b.dateTime);
      });

      _filteredEvents = tempEvents;
    });
  }

  void _openFilterScreen() async {
    final newFilters = await Navigator.push<FilterValues>(
      context,
      MaterialPageRoute(builder: (context) => FilterScreen(initialFilters: _advancedFilters)),
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A10) : Colors.white,
      appBar: AppBar(
        title: const EventGoLogo(fontSize: 24), // Panggil widget logo buatan kita
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FIX: REAL SEARCH BAR & FILTER BUTTON
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _applyAllFilters(); // Filter otomatis saat ngetik
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari event...',
                      hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.grey.shade500, fontSize: 14),
                      prefixIcon: Icon(Icons.search, color: isDark ? Colors.white54 : Colors.grey.shade500),
                      suffixIcon: _searchQuery.isNotEmpty 
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                                _applyAllFilters();
                              });
                            },
                          )
                        : null,
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1A1A22) : const Color(0xFFF4F4F6),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Tombol Filter Spesifik
                InkWell(
                  onTap: _openFilterScreen,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.tune_rounded, color: colorScheme.primary, size: 22),
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Text(
              'Rekomendasi Teratas',
              style: textTheme.titleMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          
          _buildFilterChips(),
          
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
                : _filteredEvents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event_busy_rounded, size: 64, color: isDark ? Colors.white24 : Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada event\nyang cocok 😢',
                              textAlign: TextAlign.center,
                              style: textTheme.titleMedium?.copyWith(
                                fontSize: 16,
                                color: isDark ? Colors.white54 : Colors.grey.shade500,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadEvents,
                        color: colorScheme.primary,
                        backgroundColor: isDark ? const Color(0xFF1A1A22) : Colors.white,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _filteredEvents.length,
                          itemBuilder: (context, index) {
                            return EventCard(event: _filteredEvents[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['Semua', 'K-Pop', 'Musik', 'Segera', 'Terbaru'];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20.0), // Selaras dengan Rekomendasi Teratas
        children: filters.map((filter) {
          final isSelected = _selectedChipFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: ChoiceChip(
              label: Text(
                filter,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF6B677A)),
                  fontSize: 14,
                ),
              ),
              selected: isSelected,
              showCheckmark: false,
              backgroundColor: isDark ? const Color(0xFF1A1A22) : Colors.white,
              selectedColor: colorScheme.primary,
              elevation: 0,
              side: BorderSide(
                color: isSelected ? Colors.transparent : (isDark ? Colors.white12 : Colors.grey.shade300),
              ),
              shape: const StadiumBorder(), 
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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