import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Wajib ada untuk fitur Favorit
import '../models/event_model.dart';
import 'registration_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool _isFavorite = false;
  bool _isLoadingFav = true;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  // Cek apakah event ini sudah difavoritkan
  Future<void> _checkFavoriteStatus() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) {
        if (mounted) setState(() => _isLoadingFav = false);
        return;
      }

      final res = await supabase
          .from('favorites')
          .select()
          .eq('user_id', user.id)
          .eq('event_id', widget.event.id)
          .maybeSingle();

      if (mounted) {
        setState(() {
          _isFavorite = res != null;
          _isLoadingFav = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingFav = false);
    }
  }

  // Fungsi saat tombol Love ditekan
  // Fungsi saat tombol Love ditekan
  Future<void> _toggleFavorite() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Silakan login terlebih dahulu'),
        ));
        return;
      }

      setState(() => _isFavorite = !_isFavorite); // Optimistic UI update

      if (_isFavorite) {
        await supabase.from('favorites').insert({
          'user_id': user.id,
          'event_id': widget.event.id,
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Berhasil ditambahkan ke Favorit! ❤️'),
            duration: Duration(seconds: 1),
          ));
        }
      } else {
        await supabase
            .from('favorites')
            .delete()
            .eq('user_id', user.id)
            .eq('event_id', widget.event.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Dihapus dari Favorit 💔'),
            duration: Duration(seconds: 1),
          ));
        }
      }
    } catch (e) {
      // Jika gagal, kembalikan status love-nya dan tampilkan pesan error
      if (mounted) {
        setState(() => _isFavorite = !_isFavorite); 
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'), 
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd MMM yyyy • HH:mm', 'id_ID').format(widget.event.dateTime);
    final bool isCompleted = widget.event.dateTime.isBefore(DateTime.now());
    
    // Ambil ID user yang sedang login untuk mengecek apakah ini event miliknya
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final bool isMyEvent = widget.event.userId == currentUserId;

    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0A0A10) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          // HEADER: Full Image Banner
          SliverAppBar(
            expandedHeight: 320.0,
            pinned: true,
            backgroundColor: bgColor,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Colors.black38, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_rounded, size: 20, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                // PERBAIKAN: Menggunakan onPressed, BUKAN onTap
                onPressed: _isLoadingFav ? null : _toggleFavorite, 
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Colors.black38, shape: BoxShape.circle),
                  child: _isLoadingFav
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Icon(
                          _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          size: 20,
                          color: _isFavorite ? Colors.pinkAccent : Colors.white,
                        ),
                ),
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Colors.black38, shape: BoxShape.circle),
                  child: const Icon(Icons.share_rounded, size: 20, color: Colors.white),
                ),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: widget.event.id,
                child: widget.event.posterUrl.startsWith('assets/')
                    ? Image.asset(widget.event.posterUrl, fit: BoxFit.cover)
                    : CachedNetworkImage(
                        imageUrl: widget.event.posterUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: Colors.grey.shade200),
                        errorWidget: (context, url, error) => Container(color: Colors.grey.shade300, child: const Icon(Icons.broken_image)),
                      ),
              ),
            ),
          ),

          // KONTEN
          SliverToBoxAdapter(
            child: Container(
              transform: Matrix4.translationValues(0.0, -30.0, 0.0), // Menarik kontainer ke atas overlap gambar
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    // Kategori Tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.event.category.toString().split('.').last.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Judul
                    Text(
                      widget.event.title,
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Informasi Lengkap
                    _buildIconLabel(
                      icon: Icons.calendar_month_rounded,
                      text: '$formattedDate WIB',
                      colorScheme: colorScheme,
                    ),
                    const SizedBox(height: 16),
                    _buildIconLabel(
                      icon: Icons.location_on_rounded,
                      text: '${widget.event.venue}, ${widget.event.location}',
                      colorScheme: colorScheme,
                    ),
                    const SizedBox(height: 16),
                    _buildIconLabel(
                      icon: Icons.local_activity_rounded,
                      text: widget.event.isFree
                          ? 'IDR 0 (Free Entry)'
                          : 'IDR ${NumberFormat.decimalPattern('id_ID').format(widget.event.price)}',
                      colorScheme: colorScheme,
                    ),
                    const SizedBox(height: 16),
                    _buildIconLabel(
                      icon: Icons.person_pin_circle_rounded,
                      text: 'Hosted by ${widget.event.organizeName}',
                      colorScheme: colorScheme,
                    ),
                    
                    if (!widget.event.isFree && widget.event.bankAccount != null) ...[
                      const SizedBox(height: 16),
                      _buildIconLabel(
                         icon: Icons.account_balance_wallet_rounded,
                         text: 'Transfer ke: ${widget.event.bankAccount}',
                         colorScheme: colorScheme,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // BOTTOM NAVIGATION BUTTON
      bottomNavigationBar: !isCompleted
          ? Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: bgColor,
                border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200)),
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (isMyEvent) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Kelola event bisa dilakukan di menu Profil.')),
                        );
                      } else {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => RegistrationScreen(event: widget.event)),
                        );
                        if (result == true) Navigator.pop(context, true);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text(
                      isMyEvent ? 'Ini Event Kamu' : 'Register Now',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildIconLabel({required IconData icon, required String text, required ColorScheme colorScheme}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.onSurface.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: colorScheme.onSurface.withOpacity(0.7), size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: colorScheme.onSurface.withOpacity(0.85),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}