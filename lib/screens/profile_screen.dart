import 'package:eventgo/services/event_service.dart';
import 'package:eventgo/widgets/ticket_widget.dart';
import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../widgets/event_card.dart';
import '../widgets/theme_switcher.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final EventService _eventService = EventService();
  late TabController _tabController;

  final String _userName = 'Pengguna EventGo';
  final String _userEmail = 'user@eventgo.com';
  final String _userAvatarUrl = 'https://i.pravatar.cc/150?u=a042581f4e29026704d';

  late List<Event> _createdEvents;
  late List<Event> _registeredEvents;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadData();
  }

  void _onTabChanged() {
    if (_tabController.index == 1) _loadData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _loadData();
  }

  void _loadData() {
    setState(() {
      _createdEvents = _eventService.getCreatedEvents();
      _registeredEvents = _eventService.getRegisteredEvents();
    });
  }

  void reloadData() => _loadData();

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// FIX: Dialog tema sekarang menampilkan ThemeSwitcher yang fungsional
  /// bukan lagi pesan statis "tema mengikuti sistem"
  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pengaturan Tema'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Pilih tampilan yang Anda inginkan:'),
            const SizedBox(height: 20),
            /// Widget ThemeSwitcher langsung di dalam dialog
            const ThemeSwitcher(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Selesai'),
          ),
        ],
      ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profil'),
        elevation: 0,
        actions: [
          /// ThemeToggleButton sudah fungsional (toggle light/dark)
          const ThemeToggleButton(),
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
            colors: isDark
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
                    indicatorColor: colorScheme.primary,
                    labelColor: colorScheme.primary,
                    /// FIX: unselectedLabelColor pakai onSurface agar kontras
                    /// di dark mode (tidak lagi gelap di atas gelap)
                    unselectedLabelColor: colorScheme.onSurface.withOpacity(0.5),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
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
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        /// FIX: Warna nama user dari colorScheme
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _userEmail,
                      style: TextStyle(
                        fontSize: 16,
                        /// FIX: Warna email dari onSurface dengan opacity
                        /// agar tetap terbaca di light maupun dark mode
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit, color: colorScheme.onSurface),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Fitur edit profil belum diimplementasikan.')),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    final colorScheme = Theme.of(context).colorScheme;

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
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            /// FIX: Angka stat pakai colorScheme.onSurface
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            /// FIX: Label stat pakai opacity, bukan Colors.grey[600] hardcode
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildEventList(List<Event> events) {
    final colorScheme = Theme.of(context).colorScheme;

    if (events.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada event untuk ditampilkan.',
          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: events.length,
      itemBuilder: (context, index) => EventCard(event: events[index]),
    );
  }

  Widget _buildTicketList(List<Event> events) {
    final colorScheme = Theme.of(context).colorScheme;

    if (events.isEmpty) {
      return Center(
        child: Text(
          'Anda belum memiliki tiket.',
          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: events.length,
      itemBuilder: (context, index) => TicketWidget(event: events[index]),
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
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}