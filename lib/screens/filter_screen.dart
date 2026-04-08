import 'package:flutter/material.dart';

/// MODEL: FilterValues - Menyimpan nilai filter yang dipilih user
class FilterValues {
  final String? location;                 // Lokasi/kota pilihan
  final String? eventType;                // Tipe event pilihan
  final String? price;                    // Range harga pilihan

  FilterValues({this.location, this.eventType, this.price});
}

/// SCREEN: FilterScreen - Layar pengaturan filter event lanjutan
/// Opsi: Lokasi, Tipe Event, Range Harga
class FilterScreen extends StatefulWidget {
  final FilterValues initialFilters;      // Filter awal

  const FilterScreen({super.key, required this.initialFilters});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  // Selected filter values
  String? _selectedLocation;              // Lokasi dipilih
  String? _selectedEventType;             // Tipe event dipilih
  String? _selectedPrice;                 // Harga dipilih

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialFilters.location;
    _selectedEventType = widget.initialFilters.eventType;
    _selectedPrice = widget.initialFilters.price;
  }

  final List<String> _locations = [
    'Jabodetabek', 'Jawa Tengah', 'DI Yogyakarta', 'Riau', 'Sumatera Barat',
    'DKI Jakarta', 'Jawa Barat', 'Jawa Timur', 'Kepulauan Riau', 'Banten',
    'Sumatera Utara', 'Bali', 'Lampung', 'Sumatera Selatan', 'Sulawesi Selatan',
    'Jambi', 'Kalimantan Timur', 'Kalimantan Selatan', 'Dalam Negeri'
  ];

  final List<String> _eventTypes = [
    'Musik', 'Pameran', 'Konferensi', 'Workshop', 'Olahraga', 'Seni & Budaya',
    'Noraebang', 'Nobar', 'Photobooth', 'Konser'
  ];

  final List<String> _prices = ['Gratis', 'Berbayar'];

  Widget _buildChipSection(String title, List<String> items, String? selectedItem, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: items.map((item) {
              return ChoiceChip(
                label: Text(item),
                selected: selectedItem == item,
                onSelected: (selected) {
                  onChanged(selected ? item : null);
                },
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Pilih Preferensi'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: Theme.of(context).brightness == Brightness.dark
                ? const [Color(0xFF0A0A10), Color(0xFF141420)]
                : const [Color(0xFFFCFAFF), Color(0xFFF5E6FF)],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildChipSection('Lokasi', _locations, _selectedLocation, (value) {
                    setState(() => _selectedLocation = value);
                  }),
                  _buildChipSection('Jenis Event', _eventTypes, _selectedEventType, (value) {
                    setState(() => _selectedEventType = value);
                  }),
                  _buildChipSection('Harga', _prices, _selectedPrice, (value) {
                    setState(() => _selectedPrice = value);
                  }),
                ],
              ),
            ),
          ),
          _buildBottomButtons(),
        ],
      ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _resetFilters,
              child: const Text('Atur Ulang'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(),
              child: const Text('Terapkan'),
            ),
          ),
        ],
      ),
    );
  }
}
