import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/home_screen.dart';
import 'screens/add_event_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EventGo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: 'Poppins',
        primaryColor: const Color(0xFF9D4EDD),
        scaffoldBackgroundColor: const Color(0xFFFAFAFC),
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
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: const Color(0xFF1C1C1E),
          displayColor: const Color(0xFF1C1C1E),
        ).copyWith(
          titleMedium: const TextStyle(color: Color(0xFF1C1C1E)),
          titleLarge: const TextStyle(color: Color(0xFF1C1C1E), fontWeight: FontWeight.bold),
          bodyMedium: const TextStyle(color: Color(0xFF6B677A)),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF9D4EDD),
          foregroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF9D4EDD),
            foregroundColor: Colors.white,
            elevation: 6,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
        ),
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
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Poppins',
        primaryColor: const Color(0xFFB01AFF),
        scaffoldBackgroundColor: const Color(0xFF0A0A10),
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
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: const Color(0xFFE2E2E3),
          displayColor: const Color(0xFFE2E2E3),
        ).copyWith(
          bodyMedium: const TextStyle(color: Color(0xFFA29BFE)),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFB01AFF),
          foregroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB01AFF),
            foregroundColor: Colors.white,
            elevation: 6,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
        ),
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
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1A1A22),
          selectedItemColor: Color(0xFFB01AFF),
          unselectedItemColor: Color(0xFF6B677A),
          elevation: 20,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const LoginScreen(),
      routes: {
        '/home': (context) => const MainScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final GlobalKey<State<HomeScreen>> homeScreenKey = GlobalKey();
  final GlobalKey<State<ProfileScreen>> profileScreenKey = GlobalKey();

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
    final screens = <Widget>[
      HomeScreen(key: homeScreenKey),
      AddEventScreen(onEventCreated: _onEventCreated),
      ProfileScreen(key: profileScreenKey),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
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
