import 'package:flutter/material.dart';

class FilterValues {
  final String? location;
  final String? eventType;
  final String? price;

  FilterValues({this.location, this.eventType, this.price});
}

class FilterScreen extends StatefulWidget {
  final FilterValues initialFilters;

  const FilterScreen({super.key, required this.initialFilters});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  String? _selectedLocation;
  String? _selectedEventType;
  String? _selectedPrice;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialFilters.location;
    _selectedEventType = widget.initialFilters.eventType;
    _selectedPrice = widget.initialFilters.price;
  }

  final List<String> _locations = [
    'Semua',
    'Jabodetabek',
    'DKI Jakarta',
    'Jawa Barat',
    'Jawa Tengah',
    'DI Yogyakarta',
    'Jawa Timur',
    'Banten',
    'Bali',
    'Aceh',
    'Sumatera',
    'Riau',
    'Jambi',
    'Bengkulu',
    'Lampung',
    'Kalimantan',
    'Gorontalo',
    'Sulawesi',
    'Maluku',
    'Papua',
    'NTB',
    'NTT',
    'Lainnya'
  ];

  final List<String> _eventTypes = [
    'Semua', 'Musik', 'Seminar', 'Competition', 'Workshop', 'Art', 
    'Sport', 'Festival', 'Noraebang', 'Nobar'
  ];

  final List<String> _prices = ['Semua', 'Gratis', 'Berbayar'];

  Widget _buildChipSection(String title, List<String> items, String? selectedItem, ValueChanged<String?> onChanged) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Text(
            title, 
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Wrap(
            spacing: 10.0,
            runSpacing: 10.0,
            children: items.map((item) {
              final isSelected = selectedItem == item || (selectedItem == null && item == 'Semua');
              return ChoiceChip(
                label: Text(item),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                selected: isSelected,
                showCheckmark: false,
                backgroundColor: isDark ? const Color(0xFF1A1A22) : Colors.white,
                selectedColor: colorScheme.primary,
                shape: const StadiumBorder(),
                side: BorderSide(
                  color: isSelected ? Colors.transparent : (isDark ? Colors.white12 : Colors.grey.shade300),
                ),
                onSelected: (selected) {
                  onChanged(item == 'Semua' ? null : item);
                },
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedLocation = null;
      _selectedEventType = null;
      _selectedPrice = null;
    });
  }

  void _applyFilters() {
    final newFilters = FilterValues(
      location: _selectedLocation,
      eventType: _selectedEventType,
      price: _selectedPrice,
    );
    Navigator.pop(context, newFilters);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A10) : Colors.white,
      appBar: AppBar(
        title: Text('Filter Preferences', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? Colors.white : Colors.black87)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        // FIX: Memastikan tombol back terlihat di light mode (hitam) dan dark mode (putih)
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              // FIX: Menghilangkan padding atas yang bikin jarak terlalu jauh
              padding: const EdgeInsets.only(top: 4, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildChipSection('Categories', _eventTypes, _selectedEventType, (value) {
                    setState(() => _selectedEventType = value);
                  }),
                  _buildChipSection('Locations', _locations, _selectedLocation, (value) {
                    setState(() => _selectedLocation = value);
                  }),
                  _buildChipSection('Price Range', _prices, _selectedPrice, (value) {
                    setState(() => _selectedPrice = value);
                  }),
                ],
              ),
            ),
          ),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0A10) : Colors.white,
        border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: _resetFilters,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  side: BorderSide(color: colorScheme.primary),
                  foregroundColor: colorScheme.primary,
                ),
                child: const Text('Reset', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Apply Filter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}