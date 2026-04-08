import 'package:eventgo/services/event_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/event_model.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class AddEventScreen extends StatefulWidget {
  final VoidCallback? onEventCreated;

  const AddEventScreen({super.key, this.onEventCreated});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _eventService = EventService();
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  EventCategory _category = EventCategory.kpop;
  EventType _type = EventType.noraebang;
  File? _posterImage;
  Uint8List? _posterImageBytes;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _location = '';
  String _venue = '';
  bool _isFree = true;
  double? _price;
  String? _registrationLink;

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        if (kIsWeb) {
          // For web, read as bytes
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _posterImageBytes = bytes;
          });
        } else {
          // For mobile, use File
          setState(() {
            _posterImage = File(pickedFile.path);
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Buat Event Baru', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Nama Event',
                  prefixIcon: const Icon(Icons.title_rounded, color: Color(0xFF9D4EDD)),
                  labelStyle: const TextStyle(color: Color(0xFF6B677A)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) => value == null || value.isEmpty ? 'Kuy isi judulnya dulu!' : null,
                onSaved: (value) => _title = value!,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<EventCategory>(
                value: _category,
                decoration: InputDecoration(
                  labelText: 'Kategori Fandom',
                  labelStyle: const TextStyle(color: Color(0xFF6B677A)),
                  prefixIcon: const Icon(Icons.category_rounded, color: Color(0xFF00BFA5)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: EventCategory.values.map((category) {
                  return DropdownMenuItem(value: category, child: Text(category.toString().split('.').last.toUpperCase()));
                }).toList(),
                onChanged: (value) => setState(() => _category = value!),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF9D4EDD)),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              if (_category == EventCategory.lainnya)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Sebutkan Kategori Lainnya',
                      labelStyle: const TextStyle(color: Color(0xFF6B677A)),
                      prefixIcon: const Icon(Icons.edit_note_rounded, color: Color(0xFFE57373)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Diisi yaa untuk spesifikasinya' : null,
                  ),
                ),
              const SizedBox(height: 20),
              DropdownButtonFormField<EventType>(
                value: _type,
                decoration: InputDecoration(
                  labelText: 'Jenis Event',
                  labelStyle: const TextStyle(color: Color(0xFF6B677A)),
                  prefixIcon: const Icon(Icons.event_rounded, color: Color(0xFF00D9FF)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: EventType.values.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type.toString().split('.').last.toUpperCase()));
                }).toList(),
                onChanged: (value) => setState(() => _type = value!),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF9D4EDD)),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              if (_type == EventType.lainnya)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Sebutkan Jenis Event Lainnya',
                      labelStyle: const TextStyle(color: Color(0xFF6B677A)),
                      prefixIcon: const Icon(Icons.edit_note_rounded, color: Color(0xFFE57373)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Diisi yaa untuk jenis eventnya' : null,
                  ),
                ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 280,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: (_posterImage != null || _posterImageBytes != null)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: kIsWeb && _posterImageBytes != null
                              ? Image.memory(_posterImageBytes!, fit: BoxFit.cover, width: double.infinity)
                              : Image.file(_posterImage!, fit: BoxFit.cover, width: double.infinity),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add_a_photo_rounded, size: 50, color: Color(0xFF9D4EDD)),
                            ),
                            const SizedBox(height: 16),
                            const Text('Upload Poster Kekinianmu!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: const Color(0xFFE6E0F8), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.calendar_month_rounded, color: Color(0xFF00BFA5)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _selectedDate == null ? 'Kapan nih eventnya?' : 'Tanggal: ${_selectedDate!.toLocal()}'.split(' ')[0],
                            style: TextStyle(fontWeight: FontWeight.bold, color: _selectedDate == null ? Colors.grey : const Color(0xFF2F2F2F)),
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF00D9FF)),
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) setState(() => _selectedDate = date);
                          },
                          child: const Text('Pilih Tanggal', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: const Color(0xFFE6E0F8), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.access_time_filled_rounded, color: Color(0xFF9D4EDD)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _selectedTime == null ? 'Jam berapa mulai?' : 'Waktu: ${_selectedTime!.format(context)}',
                            style: TextStyle(fontWeight: FontWeight.bold, color: _selectedTime == null ? Colors.grey : const Color(0xFF2F2F2F)),
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF9D4EDD)),
                          onPressed: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (time != null) setState(() => _selectedTime = time);
                          },
                          child: const Text('Pilih Waktu', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Kota / Daerah',
                  labelStyle: const TextStyle(color: Color(0xFF6B677A)),
                  prefixIcon: const Icon(Icons.location_on_rounded, color: Color(0xFFE57373)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) => value == null || value.isEmpty ? 'Lokasi ngga boleh kosong bos!' : null,
                onSaved: (value) => _location = value!,
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Nama Venue',
                  labelStyle: const TextStyle(color: Color(0xFF6B677A)),
                  prefixIcon: const Icon(Icons.store_rounded, color: Color(0xFF9D4EDD)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) => value == null || value.isEmpty ? 'Tempatnya di mana nih?' : null,
                onSaved: (value) => _venue = value!,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_activity_rounded, color: Color(0xFF00BFA5)),
                    const SizedBox(width: 12),
                    const Text('Tipe Tiket:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Radio<bool>(
                            value: true,
                            groupValue: _isFree,
                            activeColor: const Color(0xFF00BFA5),
                            onChanged: (value) => setState(() => _isFree = value!),
                          ),
                          const Text('Gratis', style: TextStyle(fontWeight: FontWeight.bold)),
                          Radio<bool>(
                            value: false,
                            groupValue: _isFree,
                            activeColor: const Color(0xFF00D9FF),
                            onChanged: (value) => setState(() => _isFree = value!),
                          ),
                          const Text('Berbayar', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (!_isFree)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Harga Tiket (Rp) 💰',
                      labelStyle: const TextStyle(color: Color(0xFF6B677A)),
                      prefixIcon: const Icon(Icons.payments_rounded, color: Color(0xFF9D4EDD)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (!_isFree && (value == null || value.isEmpty)) {
                        return 'Masukin aja tebak harganya';
                      }
                      return null;
                    },
                    onSaved: (value) => _price = double.tryParse(value ?? '0'),
                  ),
                ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Link Registrasi (Opsional)',
                  labelStyle: const TextStyle(color: Color(0xFF6B677A)),
                  prefixIcon: const Icon(Icons.link_rounded, color: Color(0xFF9D4EDD)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onSaved: (value) => _registrationLink = value,
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 8,
                    shadowColor: const Color(0xFF9D4EDD).withOpacity(0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      if (_selectedDate == null || _selectedTime == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Harap pilih tanggal dan waktu event ya! 🙏'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: const Color(0xFFE57373),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                        return;
                      }

                      final newEvent = Event(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: _title,
                        category: _category,
                        type: _type,
                        posterUrl: _posterImage?.path ?? 'https://placehold.co/600x800/E8F3F1/4ECDC4?text=Foto+Keren+Nyusul',
                        dateTime: DateTime(
                          _selectedDate!.year,
                          _selectedDate!.month,
                          _selectedDate!.day,
                          _selectedTime!.hour,
                          _selectedTime!.minute,
                        ),
                        location: _location,
                        venue: _venue,
                        isFree: _isFree,
                        price: _isFree ? 0 : _price,
                        registrationLink: _registrationLink,
                        userId: _eventService.currentUserId,
                        isCompleted: false,
                      );
                      _eventService.createEvent(newEvent);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Yay! Event berhasil dibuat!'),
                          backgroundColor: const Color(0xFF00BFA5),
                          behavior: SnackBarBehavior.floating,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                        ),
                      );

                      // Trigger callback to refresh other screens
                      widget.onEventCreated?.call();
                      
                      // Reset form
                      _formKey.currentState?.reset();
                      setState(() {
                        _title = '';
                        _posterImage = null;
                        _posterImageBytes = null;
                        _selectedDate = null;
                        _selectedTime = null;
                        _location = '';
                        _venue = '';
                      });
                    }
                  },
                  child: const Text('Buat Event Sekarang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
