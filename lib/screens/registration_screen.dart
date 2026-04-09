import 'package:eventgo/services/event_service.dart';
import 'package:flutter/material.dart';
import '../models/event_model.dart';

/// SCREEN: RegistrationScreen - Layar pendaftaran user ke event
/// Mengumpulkan data user dan menyimpan ke registered events
class RegistrationScreen extends StatefulWidget {
  final Event event;                      // Event yang didaftar

  const RegistrationScreen({super.key, required this.event});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _eventService = EventService();   // Service untuk register event
  final _formKey = GlobalKey<FormState>(); // Form validation
  String _name = '';                      // Nama pemberi daftar
  String _email = '';
  String _phone = '';
  String? _paymentProofPath;              // TODO: tambahkan path file 

  void _submitRegistration() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      // Use the service to register the event with details
      _eventService.registerForEvent(
        widget.event,
        name: _name,
        email: _email,
        phone: _phone,
        paymentProofPath: _paymentProofPath,
      );

      // Show a confirmation dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Pendaftaran Berhasil'),
            content: Text('Terima kasih, $_name. Anda telah terdaftar untuk event ${widget.event.title}. Tiket Anda sekarang tersedia di halaman profil.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  // Pop dialog
                  Navigator.of(context).pop();
                  // Pop registration screen and return result
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Registrasi'),
        
        
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Anda akan mendaftar untuk event:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                widget.event.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Alamat Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Masukkan alamat email yang valid';
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value!;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Nomor Telepon',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nomor telepon tidak boleh kosong';
                  }
                  return null;
                },
                onSaved: (value) {
                  _phone = value!;
                },
              ),
              if (!widget.event.isFree) ...[
                const SizedBox(height: 16),
                const Text('Upload Bukti Pembayaran', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    // TODO: Implement image/file picker logic here
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fitur upload bukti pembayaran belum siap')),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade50,
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.upload_file, color: Colors.blue, size: 40),
                          SizedBox(height: 8),
                          Text('Pilih File / Foto', style: TextStyle(color: Colors.blue)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitRegistration,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    
                  ),
                  child: const Text('Daftar Sekarang'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
