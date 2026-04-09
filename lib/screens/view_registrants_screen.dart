import 'package:eventgo/models/event_model.dart';
import 'package:eventgo/services/event_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// SCREEN: ViewRegistrantsScreen
/// Berfungsi untuk melihat data pendaftar dari event yang dibuat current user.
class ViewRegistrantsScreen extends StatefulWidget {
  final Event event;

  const ViewRegistrantsScreen({super.key, required this.event});

  @override
  State<ViewRegistrantsScreen> createState() => _ViewRegistrantsScreenState();
}

class _ViewRegistrantsScreenState extends State<ViewRegistrantsScreen> {
  final _eventService = EventService();
  late List<Registration> _registrations;

  @override
  void initState() {
    super.initState();
    _registrations = _eventService.getRegistrationsForEvent(widget.event.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Pendaftar'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.event.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total Pendaftar: ${_registrations.length} Orang',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          Expanded(
            child: _registrations.isEmpty
                ? const Center(
                    child: Text('Belum ada yang mendaftar ke event ini.'),
                  )
                : ListView.separated(
                    itemCount: _registrations.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final reg = _registrations[index];
                      // Format tanggal daftar
                      final formattedDate =
                          DateFormat('dd MMM yyyy - HH:mm').format(reg.registeredAt);

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            reg.userName.isNotEmpty
                                ? reg.userName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(reg.userName,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Email: ${reg.email}'),
                            Text('Telp: ${reg.phone}'),
                            Text('Daftar: $formattedDate WIB'),
                            if (!widget.event.isFree) ...[
                              const SizedBox(height: 4),
                              Text(
                                reg.paymentProofPath != null
                                    ? 'Status: Menunggu Konfirmasi (Kirim Bukti)'
                                    : 'Status: Belum Mengirim Bukti Pembayaran',
                                style: TextStyle(
                                  color: reg.paymentProofPath != null
                                      ? Colors.orange
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ]
                          ],
                        ),
                        isThreeLine: true,
                        onTap: () {
                          // TODO: fitur tambahan misalnya melihat bukti tf yang diupload
                          if (!widget.event.isFree && reg.paymentProofPath != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('File belum bisa di-view saat ini'),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
