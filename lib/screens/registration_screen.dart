import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import 'package:image_picker/image_picker.dart'; // Untuk ambil foto
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

import '../models/event_model.dart'; // Model event kamu

/// SCREEN: RegistrationScreen - Layar pendaftaran user ke event
/// Terhubung langsung ke Supabase: upload bukti bayar & simpan ke tabel registrations
class RegistrationScreen extends StatefulWidget {
  final Event event;                      // Event yang didaftar

  const RegistrationScreen({super.key, required this.event});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>(); // Form validation
  
  bool _isLoading = false;                 // Indikator loading submit

  String _name = '';                       // Nama pendaftar
  String _email = '';
  String _phone = '';
  
  File? _paymentProofImage;                // File foto bukti bayar (Mobile)
  Uint8List? _paymentProofBytes;           // Byte foto bukti bayar (Web)

  // Fungsi untuk mengambil gambar dari galeri
  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() => _paymentProofBytes = bytes);
        } else {
          setState(() => _paymentProofImage = File(pickedFile.path));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil foto: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _submitRegistration() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      // Jika event berbayar, WAJIB upload bukti pembayaran
      if (!widget.event.isFree && _paymentProofImage == null && _paymentProofBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Harap upload bukti pembayaran terlebih dahulu!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        final supabase = Supabase.instance.client;
        final userId = supabase.auth.currentUser?.id;

        if (userId == null) {
          throw Exception('User belum login!');
        }

        // 1. UPLOAD BUKTI PEMBAYARAN KE STORAGE (Jika ada)
        String? paymentUrl;
        if (_paymentProofImage != null || _paymentProofBytes != null) {
          final fileExt = 'jpg';
          final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
          
          if (kIsWeb) {
            await supabase.storage
                .from('buktiPembayaran')
                .uploadBinary(fileName, _paymentProofBytes!);
          } else {
            await supabase.storage
                .from('buktiPembayaran')
                .upload(fileName, _paymentProofImage!);
          }
          
          paymentUrl = supabase.storage.from('buktiPembayaran').getPublicUrl(fileName);
        }

        // 2. SIMPAN DATA KE TABEL REGISTRATIONS
        await supabase.from('registrations').insert({
          'event_id': widget.event.id,
          'user_id': userId,
          'registrant_name': _name,
          'registrant_email': _email,
          'registrant_phone': _phone,
          'payment_proof_url': paymentUrl,
          'status': 'pending', // Default status menunggu verifikasi
        });

        if (mounted) {
          setState(() => _isLoading = false);
          
          // Tampilkan dialog sukses
          showDialog(
            context: context,
            barrierDismissible: false, // User harus tap OK
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Pendaftaran Berhasil', style: TextStyle(color: Color(0xFF9D4EDD))),
                content: Text(
                  'Terima kasih, $_name! Anda telah terdaftar untuk event "${widget.event.title}". '
                  '${widget.event.isFree ? 'Tiket Anda sudah aktif.' : 'Status tiket menunggu verifikasi pembayaran.'} '
                  'Anda bisa mengeceknya di menu Profil -> Tiket Saya.'
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.of(context).pop(); // Tutup dialog
                      Navigator.of(context).pop(true); // Kembali ke halaman sebelumnya dan kirim sinyal sukses
                    },
                  ),
                ],
              );
            },
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Pendaftaran gagal: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Registrasi', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Anda akan mendaftar untuk event:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              Text(
                widget.event.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(height: 32),
              
              // Field Nama
              TextFormField(
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  filled: true,
                  fillColor: const Color(0xFFFFF0F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.person, color: Color(0xFF9D4EDD)),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Nama tidak boleh kosong' : null,
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 16),

              // Field Email
              TextFormField(
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'Alamat Email',
                  filled: true,
                  fillColor: const Color(0xFFFFF0F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.email, color: Color(0xFF9D4EDD)),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value == null || value.isEmpty || !value.contains('@') ? 'Masukkan alamat email yang valid' : null,
                onSaved: (value) => _email = value!,
              ),
              const SizedBox(height: 16),

              // Field Telepon
              TextFormField(
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'Nomor Telepon',
                  filled: true,
                  fillColor: const Color(0xFFFFF0F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.phone, color: Color(0xFF9D4EDD)),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty ? 'Nomor telepon tidak boleh kosong' : null,
                onSaved: (value) => _phone = value!,
              ),
              const SizedBox(height: 24),

              // Upload Bukti Bayar (Hanya muncul jika event berbayar)
              if (!widget.event.isFree) ...[
                const Text('Upload Bukti Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _isLoading ? null : _pickImage,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE8D5F2), width: 2),
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                    ),
                    child: (_paymentProofImage != null || _paymentProofBytes != null)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: kIsWeb && _paymentProofBytes != null
                                ? Image.memory(_paymentProofBytes!, fit: BoxFit.cover)
                                : Image.file(_paymentProofImage!, fit: BoxFit.cover),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.upload_file_rounded, color: Color(0xFF9D4EDD), size: 48),
                              SizedBox(height: 12),
                              Text('Pilih File / Foto', style: TextStyle(color: Color(0xFF9D4EDD), fontWeight: FontWeight.w600)),
                            ],
                          ),
                  ),
                ),
              ],
              const SizedBox(height: 40),

              // Tombol Daftar
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitRegistration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9D4EDD),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24, width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Daftar Sekarang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}