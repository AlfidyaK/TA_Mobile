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
  String? _bankAccount;
  String? _registrationLink;

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() => _posterImageBytes = bytes);
        } else {
          setState(() => _posterImage = File(pickedFile.path));
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    /// FIX: Warna field ditentukan berdasarkan mode, bukan hardcode putih
    final fieldFill = isDark ? const Color(0xFF2D1B4E) : Colors.white;
    final labelColor = isDark ? colorScheme.onSurface.withOpacity(0.7) : const Color(0xFF6B677A);
    final textColor = isDark ? colorScheme.onSurface : const Color(0xFF1C1C1E);
    final dropdownBg = isDark ? const Color(0xFF2D1B4E) : Colors.white;
    final cardBg = isDark ? const Color(0xFF1A1A22) : Colors.white;

    /// Helper: InputDecoration konsisten untuk semua field
    InputDecoration fieldDecor({
      required String label,
      required IconData icon,
      Color iconColor = const Color(0xFF9D4EDD),
    }) {
      return InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: labelColor),
        prefixIcon: Icon(icon, color: iconColor),
        filled: true,
        fillColor: fieldFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark
                ? colorScheme.primary.withOpacity(0.2)
                : const Color(0xFFE8D5F2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Buat Event Baru',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
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
                  // ── Nama Event ───────────────────────────────────────
                  TextFormField(
                    style: TextStyle(color: textColor),
                    decoration: fieldDecor(
                      label: 'Nama Event',
                      icon: Icons.title_rounded,
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Kuy isi judulnya dulu!' : null,
                    onSaved: (v) => _title = v!,
                  ),
                  const SizedBox(height: 20),

                  // ── Kategori Fandom ──────────────────────────────────
                  DropdownButtonFormField<EventCategory>(
                    value: _category,
                    style: TextStyle(
                      color: textColor,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: fieldDecor(
                      label: 'Kategori Fandom',
                      icon: Icons.category_rounded,
                      iconColor: const Color(0xFF00BFA5),
                    ),
                    items: EventCategory.values.map((c) {
                      return DropdownMenuItem(
                        value: c,
                        child: Text(c.toString().split('.').last.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _category = v!),
                    icon: Icon(Icons.keyboard_arrow_down_rounded,
                        color: colorScheme.primary),
                    dropdownColor: dropdownBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  if (_category == EventCategory.lainnya)
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: TextFormField(
                        style: TextStyle(color: textColor),
                        decoration: fieldDecor(
                          label: 'Sebutkan Kategori Lainnya',
                          icon: Icons.edit_note_rounded,
                          iconColor: const Color(0xFFE57373),
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? 'Diisi yaa untuk spesifikasinya'
                            : null,
                      ),
                    ),
                  const SizedBox(height: 20),

                  // ── Jenis Event ──────────────────────────────────────
                  DropdownButtonFormField<EventType>(
                    value: _type,
                    style: TextStyle(
                      color: textColor,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: fieldDecor(
                      label: 'Jenis Event',
                      icon: Icons.event_rounded,
                      iconColor: const Color(0xFF00D9FF),
                    ),
                    items: EventType.values.map((t) {
                      return DropdownMenuItem(
                        value: t,
                        child: Text(t.toString().split('.').last.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _type = v!),
                    icon: Icon(Icons.keyboard_arrow_down_rounded,
                        color: colorScheme.primary),
                    dropdownColor: dropdownBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  if (_type == EventType.lainnya)
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: TextFormField(
                        style: TextStyle(color: textColor),
                        decoration: fieldDecor(
                          label: 'Sebutkan Jenis Event Lainnya',
                          icon: Icons.edit_note_rounded,
                          iconColor: const Color(0xFFE57373),
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? 'Diisi yaa untuk jenis eventnya'
                            : null,
                      ),
                    ),
                  const SizedBox(height: 24),

                  // ── Upload Poster ────────────────────────────────────
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 280,
                      decoration: BoxDecoration(
                        /// FIX: Background poster ikut mode
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colorScheme.primary.withOpacity(0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: (_posterImage != null || _posterImageBytes != null)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: kIsWeb && _posterImageBytes != null
                                  ? Image.memory(_posterImageBytes!,
                                      fit: BoxFit.cover, width: double.infinity)
                                  : Image.file(_posterImage!,
                                      fit: BoxFit.cover, width: double.infinity),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo_rounded,
                                    size: 50, color: colorScheme.primary),
                                const SizedBox(height: 16),
                                Text(
                                  'Upload Poster Kekinianmu!',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    /// FIX: Teks upload pakai onSurface dengan opacity
                                    color: colorScheme.onSurface.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Tanggal & Waktu ──────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? colorScheme.primary.withOpacity(0.15)
                                    : const Color(0xFFE6E0F8),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.calendar_month_rounded,
                                  color: Color(0xFF00BFA5)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                _selectedDate == null
                                    ? 'Kapan nih eventnya?'
                                    : 'Tanggal: ${_selectedDate!.toLocal()}'.split(' ')[0],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  /// FIX: Warna teks tanggal tidak hardcode
                                  color: _selectedDate == null
                                      ? colorScheme.onSurface.withOpacity(0.4)
                                      : colorScheme.onSurface,
                                ),
                              ),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: colorScheme.primary.withOpacity(0.1),
                                foregroundColor: colorScheme.primary,
                              ),
                              onPressed: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                );
                                if (date != null) setState(() => _selectedDate = date);
                              },
                              child: const Text('Pilih Tanggal',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        Divider(height: 32, color: colorScheme.onSurface.withOpacity(0.1)),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? colorScheme.primary.withOpacity(0.15)
                                    : const Color(0xFFE6E0F8),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.access_time_filled_rounded,
                                  color: colorScheme.primary),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                _selectedTime == null
                                    ? 'Jam berapa mulai?'
                                    : 'Waktu: ${_selectedTime!.format(context)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _selectedTime == null
                                      ? colorScheme.onSurface.withOpacity(0.4)
                                      : colorScheme.onSurface,
                                ),
                              ),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: colorScheme.primary.withOpacity(0.1),
                                foregroundColor: colorScheme.primary,
                              ),
                              onPressed: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (time != null) setState(() => _selectedTime = time);
                              },
                              child: const Text('Pilih Waktu',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Lokasi & Venue ───────────────────────────────────
                  TextFormField(
                    style: TextStyle(color: textColor),
                    decoration: fieldDecor(
                      label: 'Kota / Daerah',
                      icon: Icons.location_on_rounded,
                      iconColor: const Color(0xFFE57373),
                    ),
                    validator: (v) => v == null || v.isEmpty
                        ? 'Lokasi ngga boleh kosong bos!'
                        : null,
                    onSaved: (v) => _location = v!,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    style: TextStyle(color: textColor),
                    decoration: fieldDecor(
                      label: 'Nama Venue',
                      icon: Icons.store_rounded,
                    ),
                    validator: (v) => v == null || v.isEmpty
                        ? 'Tempatnya di mana nih?'
                        : null,
                    onSaved: (v) => _venue = v!,
                  ),
                  const SizedBox(height: 24),

                  // ── Tipe Tiket ───────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.local_activity_rounded,
                            color: Color(0xFF00BFA5)),
                        const SizedBox(width: 12),
                        Text(
                          'Tipe Tiket:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Radio<bool>(
                                value: true,
                                groupValue: _isFree,
                                activeColor: const Color(0xFF00BFA5),
                                onChanged: (v) => setState(() => _isFree = v!),
                              ),
                              Text('Gratis',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  )),
                              Radio<bool>(
                                value: false,
                                groupValue: _isFree,
                                activeColor: colorScheme.primary,
                                onChanged: (v) => setState(() => _isFree = v!),
                              ),
                              Text('Berbayar',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Harga & Rekening (jika berbayar) ─────────────────
                  if (!_isFree) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: TextFormField(
                        style: TextStyle(color: textColor),
                        decoration: fieldDecor(
                          label: 'Harga Tiket (Rp) 💰',
                          icon: Icons.payments_rounded,
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (!_isFree && (v == null || v.isEmpty)) {
                            return 'Masukin aja tebak harganya';
                          }
                          return null;
                        },
                        onSaved: (v) => _price = double.tryParse(v ?? '0'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: TextFormField(
                        style: TextStyle(color: textColor),
                        decoration: fieldDecor(
                          label: 'Nomor Rekening (namaBank)',
                          icon: Icons.account_balance_wallet_rounded,
                          iconColor: const Color(0xFF00BFA5),
                        ),
                        validator: (v) {
                          if (!_isFree && (v == null || v.isEmpty)) {
                            return 'Nomor rekening wajib diisi';
                          }
                          return null;
                        },
                        onSaved: (v) => _bankAccount = v,
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // ── Tombol Submit ────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        /// FIX: foregroundColor putih agar teks tombol kelihatan
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shadowColor: colorScheme.primary.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();

                          if (_selectedDate == null || _selectedTime == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                    'Harap pilih tanggal dan waktu event ya! 🙏'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: const Color(0xFFE57373),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                            return;
                          }

                          final newEvent = Event(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            title: _title,
                            category: _category,
                            type: _type,
                            posterUrl: _posterImage?.path ??
                                'https://placehold.co/600x800/E8F3F1/4ECDC4?text=Foto+Keren+Nyusul',
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
                            bankAccount: _isFree ? null : _bankAccount,
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
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                            ),
                          );

                          widget.onEventCreated?.call();

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
                      child: const Text(
                        'Buat Event Sekarang',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
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