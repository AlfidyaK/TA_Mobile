// Import library yang diperlukan
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/home_screen.dart';
import 'screens/add_event_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';

/// Fungsi main: Entry point aplikasi
/// - Memastikan Flutter binding sudah initialized
/// - Menginisialisasi format tanggal ke bahasa Indonesia
/// - Menjalankan aplikasi
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

/// Kelas MyApp: Root widget aplikasi
/// Mengatur tema global dan screen awal aplikasi
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EventGo',
      debugShowCheckedModeBanner: false,
      
      /// TEMA LIGHT MODE (Gelap ke Terang)
      /// Menggunakan palet warna vibrant dengan primary ungu (#9D4EDD)
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: 'Poppins',
        primaryColor: const Color(0xFF9D4EDD),
        scaffoldBackgroundColor: const Color(0xFFFAFAFC),
        
        /// ColorScheme: Mendefinisikan palet warna utama
        /// - Primary: Ungu vibrant (#9D4EDD)
        /// - Secondary: Magenta (#FF006E)
        /// - Tertiary: Cyan (#00D9FF)
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9D4EDD),
          primary: const Color(0xFF9D4EDD),
          secondary: const Color(0xFFFF006E),
          tertiary: const Color(0xFF00D9FF),
          background: const Color(0xFFFAFAFC),
          surface: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onBackground: const Color(0xFF1C1C1E),
          onSurface: const Color(0xFF1C1C1E),
        ),
        
        /// TextTheme: Styling untuk semua teks di aplikasi
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: const Color(0xFF1C1C1E),
          displayColor: const Color(0xFF1C1C1E),
        ).copyWith(
          titleMedium: const TextStyle(color: Color(0xFF1C1C1E)),
          titleLarge: const TextStyle(color: Color(0xFF1C1C1E), fontWeight: FontWeight.bold),
          bodyMedium: const TextStyle(color: Color(0xFF6B677A)),
        ),
        
        /// AppBarTheme: Styling untuk AppBar (header navigasi)
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF9D4EDD),
          foregroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        
        /// ElevatedButtonTheme: Styling untuk tombol yang menonjol
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF9D4EDD),
            foregroundColor: Colors.white,
            elevation: 6,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
        ),
        
        /// ChipTheme: Styling untuk chip/filter pills
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFFFFF0F5),
          selectedColor: const Color(0xFF9D4EDD),
          labelStyle: const TextStyle(color: Color(0xFF1C1C1E), fontWeight: FontWeight.w600),
          secondaryLabelStyle: const TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: const Color(0xFF9D4EDD).withOpacity(0.3)),
          ),
        ),
        
        /// InputDecorationTheme: Styling untuk input fields (text form)
        /// Background putih dengan border ungu muda
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFFFF0F5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE8D5F2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE8D5F2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF9D4EDD), width: 2),
          ),
          hintStyle: TextStyle(color: Colors.grey.shade500),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
      /// TEMA DARK MODE (Cahaya ke Gelap)
      /// Menggunakan palet warna ungu pekat dengan primary #B01AFF
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Poppins',
        primaryColor: const Color(0xFFB01AFF),
        scaffoldBackgroundColor: const Color(0xFF0A0A10),
        
        /// ColorScheme Dark: Palet warna untuk dark mode
        /// - Primary: Ungu cerah (#B01AFF)
        /// - Secondary: Magenta (#FF006E)
        /// - Tertiary: Cyan (#00D9FF)
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color(0xFFB01AFF),
          primary: const Color(0xFFB01AFF),
          secondary: const Color(0xFFFF006E),
          tertiary: const Color(0xFF00D9FF),
          background: const Color(0xFF0A0A10),
          surface: const Color(0xFF1A1A22),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onBackground: const Color(0xFFE2E2E3),
          onSurface: const Color(0xFFE2E2E3),
        ),
        
        /// TextTheme Dark: Styling teks untuk dark mode (warna terang)
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: const Color(0xFFE2E2E3),
          displayColor: const Color(0xFFE2E2E3),
        ).copyWith(
          bodyMedium: const TextStyle(color: Color(0xFFA29BFE)),
        ),
        
        /// AppBarTheme Dark: Header dengan ungu cerah
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFB01AFF),
          foregroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        
        /// ElevatedButtonTheme Dark: Tombol dengan ungu cerah
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB01AFF),
            foregroundColor: Colors.white,
            elevation: 6,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
        ),
        
        /// ChipTheme Dark: Filter pills dengan background gelap
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFF2D1B4E),
          selectedColor: const Color(0xFFB01AFF),
          labelStyle: const TextStyle(color: Color(0xFFE2E2E3), fontWeight: FontWeight.w600),
          secondaryLabelStyle: const TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: const Color(0xFFB01AFF).withOpacity(0.5)),
          ),
        ),
        
        /// InputDecorationTheme Dark: Input fields dengan background ungu gelap
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2D1B4E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: const Color(0xFFB01AFF).withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: const Color(0xFFB01AFF).withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFB01AFF), width: 2),
          ),
          hintStyle: const TextStyle(color: Color(0xFFB01AFF)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        
        /// BottomNavigationBarTheme Dark: Navigation bar bawah untuk dark mode
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1A1A22),
          selectedItemColor: Color(0xFFB01AFF),
          unselectedItemColor: Color(0xFF6B677A),
          elevation: 20,
        ),
      ),
      
      /// themeMode: Mengikuti sistem device (light/dark)
      themeMode: ThemeMode.system,
      
      /// home: Screen pertama yang ditampilkan (Login Screen)
      home: const LoginScreen(),
      
      /// routes: Penyimpanan named routes untuk navigasi
      routes: {
        '/home': (context) => const MainScreen(),
      },
    );
  }
}

/// Kelas MainScreen: Widget utama navigasi aplikasi
/// Menggunakan BottomNavigationBar untuk switching antar 3 screen:
/// - HomeScreen: Daftar event
/// - AddEventScreen: Membuat event baru
/// - ProfileScreen: Data profil user
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  /// Index tab yang aktif (0=Home, 1=Add Event, 2=Profile)
  int _selectedIndex = 0;
  
  /// GlobalKey untuk mengakses state HomeScreen dan ProfileScreen
  /// Memungkinkan refresh data ketika switching tab
  final GlobalKey<State<HomeScreen>> homeScreenKey = GlobalKey();
  final GlobalKey<State<ProfileScreen>> profileScreenKey = GlobalKey();

  /// Fungsi untuk handle ketika user tap item di BottomNavigationBar
  /// - Update index tab yang aktif
  /// - Refresh data sesuai tab yang dipilih (home atau profile)
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    // Refresh data setelah switching tab
    if (index == 0) {
      Future.delayed(const Duration(milliseconds: 100), () {
        final homeState = homeScreenKey.currentState;
        if (homeState != null) {
          (homeState as dynamic).reloadEvents();
        }
      });
    } else if (index == 2) {
      Future.delayed(const Duration(milliseconds: 100), () {
        final profileState = profileScreenKey.currentState;
        if (profileState != null) {
          (profileState as dynamic).reloadData();
        }
      });
    }
  }

  /// Fungsi callback ketika event baru berhasil dibuat
  /// Merefresh data di HomeScreen dan ProfileScreen agar muncul event terbaru
  void _onEventCreated() {
    // Refresh both HomeScreen and ProfileScreen
    final homeState = homeScreenKey.currentState;
    final profileState = profileScreenKey.currentState;
    
    if (homeState != null) {
      (homeState as dynamic).reloadEvents();
    }
    if (profileState != null) {
      (profileState as dynamic).reloadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    /// Daftar 3 screen utama aplikasi
    /// IndexedStack digunakan untuk menjaga state setiap screen
    final screens = <Widget>[
      HomeScreen(key: homeScreenKey),
      AddEventScreen(onEventCreated: _onEventCreated),
      ProfileScreen(key: profileScreenKey),
    ];

    return Scaffold(
      /// Body: Menampilkan screen sesuai tab yang dipilih
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      
      /// BottomNavigationBar: Navigation bar bawah dengan 3 tab
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Buat Event',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
