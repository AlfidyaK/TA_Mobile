import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../models/event_model.dart';

class AddEventScreen extends StatefulWidget {
  final VoidCallback? onEventCreated;

  const AddEventScreen({super.key, this.onEventCreated});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _venueController = TextEditingController();
  final _priceController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _customCategoryController = TextEditingController();
  final _customTypeController = TextEditingController();

  bool _isLoading = false;

  EventCategory _category = EventCategory.kpop;
  EventType _type = EventType.noraebang;

  File? _posterImage;
  Uint8List? _posterImageBytes;

  // ── PERBAIKAN: Simpan tanggal & waktu di state, dan gunakan controller
  //    terpisah agar widget InputDecorator langsung re-render ──
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  bool _isFree = true;

  // Format tanggal ke string yang tampil di field
  String get _dateLabel {
    if (_selectedDate == null) return 'DD / MM / YYYY';
    return '${_selectedDate!.day.toString().padLeft(2, '0')} / '
        '${_selectedDate!.month.toString().padLeft(2, '0')} / '
        '${_selectedDate!.year}';
  }

  // Format waktu ke string yang tampil di field
  String get _timeLabel {
    if (_selectedTime == null) return 'HH : MM';
    final h = _selectedTime!.hour.toString().padLeft(2, '0');
    final m = _selectedTime!.minute.toString().padLeft(2, '0');
    return '$h : $m';
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() => _selectedDate = date); // setState langsung update UI
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => _selectedTime = time); // setState langsung update UI
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() => _posterImageBytes = bytes);
        } else {
          setState(() => _posterImage = File(pickedFile.path));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  Future<void> _publishEvent() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Harap pilih tanggal dan waktu!'),
          backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User belum login!');

      String? posterUrl;
      if (_posterImage != null || _posterImageBytes != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        if (kIsWeb) {
          await supabase.storage
              .from('posters')
              .uploadBinary(fileName, _posterImageBytes!);
        } else {
          await supabase.storage
              .from('posters')
              .upload(fileName, _posterImage!);
        }
        posterUrl =
            supabase.storage.from('posters').getPublicUrl(fileName);
      }

      final eventDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      ).toIso8601String();

      final finalCategory = _category == EventCategory.lainnya
          ? (_customCategoryController.text.trim().toUpperCase())
          : _category.toString().split('.').last.toUpperCase();

      final finalType = _type == EventType.lainnya
          ? (_customTypeController.text.trim().toUpperCase())
          : _type.toString().split('.').last.toUpperCase();

      await supabase.from('events').insert({
        'creator_id': userId,
        'title': _titleController.text.trim(),
        'fandom_category': finalCategory,
        'event_type': finalType,
        'event_date': eventDateTime,
        'location_region': _locationController.text.trim(),
        'location_name': _venueController.text.trim(),
        'ticket_price': _isFree ? 0 : (double.tryParse(_priceController.text) ?? 0),
        'bank_account_info': _isFree ? null : _bankAccountController.text.trim(),
        'poster_url': posterUrl ??
            'https://placehold.co/600x800/E8F3F1/4ECDC4?text=Tanpa+Poster',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Event berhasil dipublish!'),
            backgroundColor: Colors.green));
        widget.onEventCreated?.call();
        _resetForm();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _titleController.clear();
    _locationController.clear();
    _venueController.clear();
    _priceController.clear();
    _bankAccountController.clear();
    _customCategoryController.clear();
    _customTypeController.clear();
    setState(() {
      _posterImage = null;
      _posterImageBytes = null;
      _selectedDate = null;
      _selectedTime = null;
      _category = EventCategory.kpop;
      _type = EventType.noraebang;
      _isFree = true;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _venueController.dispose();
    _priceController.dispose();
    _bankAccountController.dispose();
    _customCategoryController.dispose();
    _customTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    // ── Token warna ──────────────────────────────────────────────────────────
    final scaffoldBg =
        isDark ? const Color(0xFF0D0D14) : const Color(0xFFF7F7FB);
    final cardBg = isDark ? const Color(0xFF1C1C26) : Colors.white;
    final fieldBg = isDark ? const Color(0xFF252530) : const Color(0xFFF2F2F7);
    final labelColor =
        isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final valueColor = isDark ? Colors.white : Colors.black87;
    final borderColor =
        isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200;
    final hintColor =
        isDark ? Colors.grey.shade600 : Colors.grey.shade400;
    final primaryColor = colorScheme.primary; // ungu dari theme

    // ── Input decoration factory ─────────────────────────────────────────────
    InputDecoration fieldDecor({
      String? hint,
      Widget? suffix,
      Widget? prefix,
    }) {
      return InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: hintColor, fontSize: 14),
        suffixIcon: suffix,
        prefixIcon: prefix,
        filled: true,
        fillColor: fieldBg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primaryColor, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.8),
        ),
      );
    }

    // ── Label atas field ─────────────────────────────────────────────────────
    Widget sectionLabel(String text) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        );

    // ── Tap-able date/time field ─────────────────────────────────────────────
    Widget tapField({
      required String label,
      required String value,
      required VoidCallback onTap,
      required IconData icon,
    }) {
      final bool filled = value != label; // ada isinya
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: fieldBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: filled ? valueColor : hintColor,
                  ),
                ),
              ),
              Icon(icon, size: 18, color: filled ? primaryColor : hintColor),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text(
          'Create New Event',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: scaffoldBg,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              size: 18,
              color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Event Name ────────────────────────────────────────────────
              sectionLabel('Event Name'),
              TextFormField(
                controller: _titleController,
                style: TextStyle(color: valueColor, fontSize: 14),
                decoration:
                    fieldDecor(hint: 'Your Event Name'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 20),

              // ── Category ──────────────────────────────────────────────────
              sectionLabel('Category'),
              DropdownButtonFormField<EventCategory>(
                value: _category,
                style: TextStyle(color: valueColor, fontSize: 14),
                decoration: fieldDecor(hint: 'Select Category'),
                dropdownColor: cardBg,
                borderRadius: BorderRadius.circular(14),
                icon: Icon(Icons.keyboard_arrow_down_rounded,
                    color: hintColor),
                items: EventCategory.values
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(
                            c.toString().split('.').last.toUpperCase(),
                            style: TextStyle(color: valueColor),
                          ),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              if (_category == EventCategory.lainnya) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _customCategoryController,
                  style: TextStyle(color: valueColor, fontSize: 14),
                  decoration: fieldDecor(hint: 'Specify category'),
                  validator: (v) => _category == EventCategory.lainnya &&
                          (v == null || v.trim().isEmpty)
                      ? 'Wajib diisi'
                      : null,
                ),
              ],
              const SizedBox(height: 20),

              // ── Event Type ────────────────────────────────────────────────
              sectionLabel('Event Type'),
              DropdownButtonFormField<EventType>(
                value: _type,
                style: TextStyle(color: valueColor, fontSize: 14),
                decoration: fieldDecor(hint: 'Select Type'),
                dropdownColor: cardBg,
                borderRadius: BorderRadius.circular(14),
                icon: Icon(Icons.keyboard_arrow_down_rounded,
                    color: hintColor),
                items: EventType.values
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(
                            t.toString().split('.').last.toUpperCase(),
                            style: TextStyle(color: valueColor),
                          ),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _type = v!),
              ),
              if (_type == EventType.lainnya) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _customTypeController,
                  style: TextStyle(color: valueColor, fontSize: 14),
                  decoration: fieldDecor(hint: 'Specify type'),
                  validator: (v) => _type == EventType.lainnya &&
                          (v == null || v.trim().isEmpty)
                      ? 'Wajib diisi'
                      : null,
                ),
              ],
              const SizedBox(height: 20),

              // ── Location ──────────────────────────────────────────────────
              sectionLabel('Location / City'),
              TextFormField(
                controller: _locationController,
                style: TextStyle(color: valueColor, fontSize: 14),
                decoration: fieldDecor(
                  hint: 'Select Location',
                  suffix: Icon(Icons.location_on_outlined,
                      size: 18, color: hintColor),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 20),

              // ── Venue ─────────────────────────────────────────────────────
              sectionLabel('Venue Details'),
              TextFormField(
                controller: _venueController,
                style: TextStyle(color: valueColor, fontSize: 14),
                decoration:
                    fieldDecor(hint: 'Enter specific venue name'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 20),

              // ── Date & Time ───────────────────────────────────────────────
              sectionLabel('Date & Time'),
              Row(
                children: [
                  Expanded(
                    child: tapField(
                      label: 'DD / MM / YYYY',
                      value: _dateLabel,
                      onTap: _pickDate,
                      icon: Icons.calendar_today_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: tapField(
                      label: 'HH : MM',
                      value: _timeLabel,
                      onTap: _pickTime,
                      icon: Icons.access_time_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Ticket Price ──────────────────────────────────────────────
              sectionLabel('Ticket Price'),
              Container(
                decoration: BoxDecoration(
                  color: fieldBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    // Toggle Free / Paid
                    Row(
                      children: [
                        Expanded(
                          child: _TicketTypeButton(
                            label: 'Free',
                            selected: _isFree,
                            primaryColor: Color.fromARGB(239, 255, 53, 140),
                            isDark: isDark,
                            onTap: () => setState(() => _isFree = true),
                          ),
                        ),
                        Expanded(
                          child: _TicketTypeButton(
                            label: 'Paid',
                            selected: !_isFree,
                            primaryColor: Color.fromARGB(239, 255, 53, 140),
                            isDark: isDark,
                            onTap: () => setState(() => _isFree = false),
                          ),
                        ),
                      ],
                    ),

                    // Price input jika Paid
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      child: _isFree
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _priceController,
                                    style:
                                        TextStyle(color: valueColor, fontSize: 14),
                                    keyboardType: TextInputType.number,
                                    decoration: fieldDecor(
                                      hint: 'Ticket Price (Rp)',
                                      prefix: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Text('Rp',
                                            style: TextStyle(
                                                color: primaryColor,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                    validator: (v) => !_isFree &&
                                            (v == null || v.trim().isEmpty)
                                        ? 'Wajib diisi'
                                        : null,
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _bankAccountController,
                                    style:
                                        TextStyle(color: valueColor, fontSize: 14),
                                    decoration: fieldDecor(
                                        hint: 'Bank Account Info (e.g. BCA 1234)'),
                                    validator: (v) => !_isFree &&
                                            (v == null || v.trim().isEmpty)
                                        ? 'Wajib diisi'
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── Upload Banner ─────────────────────────────────────────────
              GestureDetector(
                onTap: _pickImage,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    color: (_posterImage != null || _posterImageBytes != null)
                        ? Colors.transparent
                        : (isDark
                            ? primaryColor.withOpacity(0.08)
                            : primaryColor.withOpacity(0.05)),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: (_posterImage != null || _posterImageBytes != null)
                          ? primaryColor.withOpacity(0.5)
                          : primaryColor.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: (_posterImage != null || _posterImageBytes != null)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: kIsWeb && _posterImageBytes != null
                              ? Image.memory(_posterImageBytes!,
                                  fit: BoxFit.cover, width: double.infinity)
                              : Image.file(_posterImage!,
                                  fit: BoxFit.cover, width: double.infinity),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.camera_alt_outlined,
                                  size: 28, color: primaryColor),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Upload Event Banner',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: primaryColor,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap to choose from gallery',
                              style: TextStyle(
                                  color: hintColor, fontSize: 12),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 32),

              // ── Publish Button ────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: primaryColor.withOpacity(0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: _isLoading ? null : _publishEvent,
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text(
                          'Publish Event',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Tombol toggle Free / Paid ────────────────────────────────────────────────
class _TicketTypeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final Color primaryColor;
  final bool isDark;
  final VoidCallback onTap;

  const _TicketTypeButton({
    required this.label,
    required this.selected,
    required this.primaryColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? primaryColor
              : (isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: selected
                  ? Colors.white
                  : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
            ),
          ),
        ),
      ),
    );
  }
}