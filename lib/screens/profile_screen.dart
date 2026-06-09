import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event_model.dart';
import '../widgets/event_card.dart';
import '../widgets/ticket_widget.dart';
import '../widgets/theme_switcher.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with WidgetsBindingObserver {
  bool _isLoading = true;
  String _userName = 'Memuat...';
  String _userEmail = 'Memuat...';
  String? _userAvatarUrl;

  List<Event> _createdEvents = [];
  List<Map<String, dynamic>> _registeredTickets = [];

  String? _activePage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final profileRes = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      if (profileRes != null) {
        _userName = profileRes['full_name'] ?? 'Pengguna EventGo';
        _userEmail = profileRes['email'] ?? user.email ?? '';
        _userAvatarUrl = profileRes['avatar_url'];
      }

      final createdRes = await supabase
          .from('events')
          .select()
          .eq('creator_id', user.id)
          .order('created_at', ascending: false);

      final registeredRes = await supabase
          .from('registrations')
          .select('id, status, events(*)')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _createdEvents =
              (createdRes as List).map((d) => _parseEvent(d)).toList();
          _registeredTickets = (registeredRes as List)
              .map((d) => {
                    'registration_id': d['id'],
                    'status': d['status'],
                    'event': _parseEvent(d['events']),
                  })
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Event _parseEvent(Map<String, dynamic> data) {
    return Event(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      category: EventCategory.values.firstWhere(
        (e) =>
            e.toString().split('.').last.toUpperCase() ==
            data['fandom_category'],
        orElse: () => EventCategory.lainnya,
      ),
      type: EventType.values.firstWhere(
        (e) =>
            e.toString().split('.').last.toUpperCase() == data['event_type'],
        orElse: () => EventType.lainnya,
      ),
      posterUrl: data['poster_url'] ?? '',
      dateTime: data['event_date'] != null
          ? DateTime.parse(data['event_date'])
          : DateTime.now(),
      location: data['location_region'] ?? '',
      venue: data['location_name'] ?? '',
      isFree: (data['ticket_price'] == 0 || data['ticket_price'] == null),
      price: (data['ticket_price'] ?? 0).toDouble(),
      bankAccount: data['bank_account_info'],
      userId: data['creator_id'] ?? '',
      isCompleted: false,
    );
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
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (mounted) {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showManageParticipants(Event event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ManageParticipantsSheet(event: event),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  double get _profileCompletion => 0.75;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final scaffoldBg =
        isDark ? const Color(0xFF0D0D14) : const Color(0xFFF5F5F8);

    if (_activePage == 'registrations') {
      return _SubPageScaffold(
        title: 'My Registrations',
        primaryColor: colorScheme.primary,
        onBack: () => setState(() => _activePage = null),
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
            : _buildTicketList(_registeredTickets),
      );
    }

    if (_activePage == 'events') {
      return _SubPageScaffold(
        title: 'My Events',
        primaryColor: colorScheme.primary,
        onBack: () => setState(() => _activePage = null),
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
            : _buildEventList(_createdEvents),
      );
    }

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Column(
        children: [
          _buildHeader(isDark: isDark, colorScheme: colorScheme),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildMenuCard(isDark: isDark, colorScheme: colorScheme),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader({required bool isDark, required ColorScheme colorScheme}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF3D1D72), const Color(0xFF4A2490)]
              : [const Color(0xFF6B3FA0), const Color(0xFF7C4DBC)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const ThemeToggleButton(),
                ],
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white24,
                      backgroundImage: (_userAvatarUrl != null &&
                              _userAvatarUrl!.isNotEmpty)
                          ? NetworkImage(_userAvatarUrl!)
                          : null,
                      child: (_userAvatarUrl == null || _userAvatarUrl!.isEmpty)
                          ? const Icon(Icons.person_rounded,
                              size: 40, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isLoading ? 'Memuat...' : _userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isLoading ? '' : _userEmail,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Profile Completion',
                            style:
                                TextStyle(color: Colors.white, fontSize: 13)),
                        Text(
                          '${(_profileCompletion * 100).toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _profileCompletion,
                        minHeight: 6,
                        backgroundColor: Colors.white.withOpacity(0.25),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
      {required bool isDark, required ColorScheme colorScheme}) {
    // ── Semua warna card ikut tema aktif ──────────────────────────────────
    final cardBg = isDark ? const Color(0xFF1C1C26) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF222222);
    final iconColor = isDark ? Colors.white70 : const Color(0xFF444444);
    final chevronColor =
        isDark ? Colors.white.withOpacity(0.3) : Colors.grey.shade400;
    final dividerColor =
        isDark ? Colors.white.withOpacity(0.07) : Colors.grey.shade100;

    Widget item({
      required IconData icon,
      required String label,
      required VoidCallback onTap,
      bool isDestructive = false,
    }) {
      final color = isDestructive ? Colors.red : textColor;
      final icolor = isDestructive ? Colors.red : iconColor;
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: colorScheme.primary.withOpacity(0.08),
        highlightColor: colorScheme.primary.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: icolor, size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Text(label,
                    style: TextStyle(
                        fontSize: 15,
                        color: color,
                        fontWeight: FontWeight.w500)),
              ),
              if (!isDestructive)
                Icon(Icons.chevron_right, color: chevronColor, size: 20),
            ],
          ),
        ),
      );
    }

    Widget div() => Divider(
        height: 1, thickness: 1, color: dividerColor, indent: 56, endIndent: 20);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.4)
                : Colors.black.withOpacity(0.06),
            blurRadius: isDark ? 16 : 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: isDark
            ? Border.all(color: Colors.white.withOpacity(0.06))
            : null,
      ),
      child: Column(
        children: [
          item(
              icon: Icons.confirmation_number_outlined,
              label: 'My Registrations',
              onTap: () => setState(() => _activePage = 'registrations')),
          div(),
          item(
              icon: Icons.event_outlined,
              label: 'My Events',
              onTap: () => setState(() => _activePage = 'events')),
          div(),
          item(
              icon: Icons.favorite_border_rounded,
              label: 'Favorite Events',
              onTap: () {}),
          div(),
          item(
              icon: Icons.edit_outlined,
              label: 'Edit Profile',
              onTap: () {}),
          div(),
          item(
              icon: Icons.settings_outlined,
              label: 'Settings',
              onTap: () {}),
          div(),
          item(
              icon: Icons.logout_rounded,
              label: 'Logout',
              onTap: _handleLogout,
              isDestructive: true),
        ],
      ),
    );
  }

  Widget _buildEventList(List<Event> events) {
    final colorScheme = Theme.of(context).colorScheme;
    if (events.isEmpty) {
      return Center(
          child: Text('Tidak ada event untuk ditampilkan.',
              style:
                  TextStyle(color: colorScheme.onSurface.withOpacity(0.5))));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Column(
          children: [
            EventCard(event: event),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 24, left: 4, right: 4),
              child: ElevatedButton.icon(
                onPressed: () => _showManageParticipants(event),
                icon: const Icon(Icons.how_to_reg_rounded),
                label: const Text('Kelola & Validasi Pendaftar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary.withOpacity(0.1),
                  foregroundColor: colorScheme.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                        color: colorScheme.primary.withOpacity(0.3)),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTicketList(List<Map<String, dynamic>> tickets) {
    final colorScheme = Theme.of(context).colorScheme;
    if (tickets.isEmpty) {
      return Center(
          child: Text('Anda belum memiliki tiket.',
              style:
                  TextStyle(color: colorScheme.onSurface.withOpacity(0.5))));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        final ticket = tickets[index];
        return TicketWidget(
          event: ticket['event'],
          registrationId: ticket['registration_id'],
          status: ticket['status'],
        );
      },
    );
  }
}

// ─── Sub-page scaffold ────────────────────────────────────────────────────────
class _SubPageScaffold extends StatelessWidget {
  final String title;
  final Color primaryColor;
  final VoidCallback onBack;
  final Widget child;

  const _SubPageScaffold({
    required this.title,
    required this.primaryColor,
    required this.onBack,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: child,
    );
  }
}

// ─── Sliver delegate ─────────────────────────────────────────────────────────
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate(this._tabBar, this.backgroundColor);
  final TabBar _tabBar;
  final Color backgroundColor;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) =>
      Container(color: backgroundColor, child: _tabBar);

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}

// ─── Bottom Sheet: Kelola Peserta ─────────────────────────────────────────────
class _ManageParticipantsSheet extends StatefulWidget {
  final Event event;
  const _ManageParticipantsSheet({required this.event});

  @override
  State<_ManageParticipantsSheet> createState() =>
      _ManageParticipantsSheetState();
}

class _ManageParticipantsSheetState extends State<_ManageParticipantsSheet> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _participants = [];
  List<Map<String, dynamic>> _filteredParticipants = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchParticipants();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchParticipants() async {
    try {
      final res = await Supabase.instance.client
          .from('registrations')
          .select()
          .eq('event_id', widget.event.id)
          .order('created_at', ascending: false);
      if (mounted) {
        setState(() {
          _participants = List<Map<String, dynamic>>.from(res);
          _filteredParticipants = _participants;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _runFilter(String keyword) {
    setState(() {
      _filteredParticipants = keyword.isEmpty
          ? _participants
          : _participants.where((p) {
              final name =
                  (p['registrant_name'] ?? '').toString().toLowerCase();
              final email =
                  (p['registrant_email'] ?? '').toString().toLowerCase();
              return name.contains(keyword.toLowerCase()) ||
                  email.contains(keyword.toLowerCase());
            }).toList();
    });
  }

  Future<void> _validatePayment(String regId) async {
    try {
      await Supabase.instance.client
          .from('registrations')
          .update({'status': 'success'}).eq('id', regId);
      await _fetchParticipants();
      _searchController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Peserta berhasil divalidasi!'),
            backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Gagal memvalidasi'),
            backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = isDark ? const Color(0xFF1C1C26) : Colors.white;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Daftar Pendaftar',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87)),
                IconButton(
                  icon: Icon(Icons.close,
                      color: isDark ? Colors.white70 : Colors.black54),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Total: ${_participants.length} Orang mendaftar',
              style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              onChanged: _runFilter,
              decoration: InputDecoration(
                hintText: 'Cari nama atau email pendaftar...',
                hintStyle: TextStyle(
                    color:
                        isDark ? Colors.white38 : Colors.grey.shade400),
                prefixIcon: Icon(Icons.search,
                    color: isDark ? Colors.white38 : Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear,
                            color:
                                isDark ? Colors.white38 : Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          _runFilter('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark
                    ? Colors.white.withOpacity(0.07)
                    : Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Divider(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.grey.withOpacity(0.2),
              height: 1),
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                        color: colorScheme.primary))
                : _filteredParticipants.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded,
                                size: 48,
                                color: colorScheme.onSurface
                                    .withOpacity(0.3)),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isNotEmpty
                                  ? 'Peserta tidak ditemukan'
                                  : 'Belum ada yang mendaftar 🥲',
                              style: TextStyle(
                                  color: colorScheme.onSurface
                                      .withOpacity(0.5)),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: _filteredParticipants.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final p = _filteredParticipants[index];
                          final isSuccess = p['status'] == 'success';
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.05)
                                  : const Color(0xFFFEF5E7),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: colorScheme.primary
                                      .withOpacity(0.2)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        p['registrant_name'] ?? 'Tanpa Nama',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black87),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isSuccess
                                            ? Colors.green.withOpacity(0.15)
                                            : Colors.orange
                                                .withOpacity(0.15),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        isSuccess ? 'LUNAS' : 'PENDING',
                                        style: TextStyle(
                                            color: isSuccess
                                                ? Colors.green
                                                : Colors.orange,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(p['registrant_email'] ?? '',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: isDark
                                            ? Colors.white54
                                            : Colors.grey)),
                                Text(p['registrant_phone'] ?? '',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: isDark
                                            ? Colors.white54
                                            : Colors.grey)),
                                if (!widget.event.isFree &&
                                    p['payment_proof_url'] != null) ...[
                                  const SizedBox(height: 12),
                                  GestureDetector(
                                    onTap: () => showDialog(
                                      context: context,
                                      builder: (_) => Dialog(
                                        child: InteractiveViewer(
                                          child: Image.network(
                                              p['payment_proof_url'],
                                              fit: BoxFit.contain),
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.image,
                                            size: 16,
                                            color: colorScheme.primary),
                                        const SizedBox(width: 4),
                                        Text('Lihat Bukti Transfer',
                                            style: TextStyle(
                                                color: colorScheme.primary,
                                                fontWeight:
                                                    FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ],
                                if (!isSuccess) ...[
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          _validatePayment(p['id']),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      ),
                                      child: const Text(
                                          'Validasi & Aktifkan Tiket'),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}