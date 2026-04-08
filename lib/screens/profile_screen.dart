import 'package:eventgo/services/event_service.dart';
import 'package:eventgo/widgets/ticket_widget.dart';
import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../widgets/event_card.dart';
import 'login_screen.dart';

/// SCREEN: ProfileScreen - Layar profil user & event yang dibuat/didaftar
/// Tab 1: Event yang dibuat | Tab 2: Tiket yang dimiliki
/// Fitur: Dark mode toggle, logout, edit profil
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final EventService _eventService = EventService();
  late TabController _tabController;    // Controller untuk 2 tab

  // User info (dummy data)
  final String _userName = 'Pengguna EventGo';
  final String _userEmail = 'user@eventgo.com';
  final String _userAvatarUrl = 'https://i.pravatar.cc/150?u=a042581f4e29026704d';
  
  // Data events
  late List<Event> _createdEvents;       // Event yang user buat
  late List<Event> _registeredEvents;    // Event yang user daftar

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadData();
  }

  void _onTabChanged() {
    if (_tabController.index == 1) {
      // Reload data when switching to "Tiket Saya" tab
      _loadData();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadData();
    }
  }

  void _loadData() {
    setState(() {
      _createdEvents = _eventService.getCreatedEvents();
      _registeredEvents = _eventService.getRegisteredEvents();
    });
  }

  // Public method to reload data (called from MainScreen)
  void reloadData() {
    _loadData();
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to LoginScreen and remove all previous routes
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Fungsi untuk menampilkan dialog pengaturan dark mode
  void _showThemeDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pengaturan Tema'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Tema saat ini: ${isDark ? "Dark Mode" : "Light Mode"}'),
              const SizedBox(height: 20),
              const Text('Catatan: Tema mengikuti pengaturan sistem device Anda'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profil'),
        elevation: 0,
        actions: [
          // Button untuk dark mode settings
          IconButton(
            icon: Theme.of(context).brightness == Brightness.dark
                ? const Icon(Icons.light_mode)
                : const Icon(Icons.dark_mode),
            onPressed: _showThemeDialog,
            tooltip: 'Pengaturan Tema',
          ),
          // Button logout
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
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
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(child: _buildProfileHeader()),
              SliverToBoxAdapter(child: _buildStats()),
              SliverPersistentHeader(
                delegate: _SliverTabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Event Dibuat'),
                      Tab(text: 'Tiket Saya'),
                    ],
                  ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildEventList(_createdEvents),
            _buildTicketList(_registeredEvents),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        // User profile info
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(_userAvatarUrl),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userName,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _userEmail,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // TODO: Implement edit profile logic
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fitur edit profil belum diimplementasikan.')),
                  );
                },
              ),
            ],
          ),
        ),
        // Settings section - Dark mode toggle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A22) : const Color(0xFFFFF0F5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.grey[800]! : const Color(0xFFE8D5F2),
              ),
            ),
            child: ListTile(
              leading: Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
                color: const Color(0xFF9D4EDD),
              ),
              title: const Text('Tema Tampilan'),
              subtitle: Text(isDark ? 'Dark Mode' : 'Light Mode'),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[500],
              ),
              onTap: _showThemeDialog,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Event Dibuat', _createdEvents.length.toString()),
          _buildStatItem('Tiket Saya', _registeredEvents.length.toString()),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildEventList(List<Event> events) {
    if (events.isEmpty) {
      return const Center(
        child: Text('Tidak ada event untuk ditampilkan.'),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: events.length,
      itemBuilder: (context, index) {
        return EventCard(event: events[index]);
      },
    );
  }

  Widget _buildTicketList(List<Event> events) {
    if (events.isEmpty) {
      return const Center(
        child: Text('Anda belum memiliki tiket.'),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: events.length,
      itemBuilder: (context, index) {
        return TicketWidget(event: events[index]);
      },
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
