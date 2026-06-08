import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

/// WIDGET: ThemeSwitcher
/// Menampilkan 3 pilihan tema: Light, Dark, System
/// Letakkan di ProfileScreen atau Settings agar user bisa ganti tema
class ThemeSwitcher extends StatelessWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D1B4E) : const Color(0xFFF0E6FF),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ThemeOption(
            icon: Icons.light_mode_rounded,
            label: 'Terang',
            isSelected: themeProvider.isLight,
            onTap: () => themeProvider.setTheme(ThemeMode.light),
            colorScheme: colorScheme,
          ),
          _ThemeOption(
            icon: Icons.dark_mode_rounded,
            label: 'Gelap',
            isSelected: themeProvider.isDark,
            onTap: () => themeProvider.setTheme(ThemeMode.dark),
            colorScheme: colorScheme,
          ),
          _ThemeOption(
            icon: Icons.brightness_auto_rounded,
            label: 'Auto',
            isSelected: themeProvider.isSystem,
            onTap: () => themeProvider.setTheme(ThemeMode.system),
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// WIDGET: ThemeToggleButton
/// Versi ringkas (hanya ikon) untuk diletakkan di AppBar
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IconButton(
      icon: Icon(
        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
        color: isDark ? Colors.white : const Color(0xFF1C1C1E),
      ),
      tooltip: isDark ? 'Mode Terang' : 'Mode Gelap',
      onPressed: themeProvider.toggleTheme,
    );
  }
}