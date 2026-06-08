import 'package:flutter/material.dart';

/// WIDGET: ThemeBackground - Background gradient sesuai theme
class ThemeBackground extends StatelessWidget {
  final Widget child;

  const ThemeBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF0F0F14), Color(0xFF1A1A22)]
              : const [Color(0xFFFFFFFF), Color(0xFFF0E6FF)],
        ),
      ),
      child: child,
    );
  }
}

/// WIDGET: ThemedButton - Tombol dengan styling dinamis
class ThemedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final bool isCompleted;

  const ThemedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isCompleted) {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          /// FIX: Gunakan colorScheme.primary agar konsisten dengan tema
          backgroundColor: colorScheme.primary.withOpacity(0.5),
          disabledBackgroundColor: Colors.grey.shade400,
          disabledForegroundColor: Colors.white,
        ),
        child: child,
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: isDark
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
              gradient: const LinearGradient(
                colors: [Color(0xFF9D4EDD), Color(0xFFFF006E), Color(0xFF00D9FF)],
              ),
            )
          : null,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? Colors.transparent : colorScheme.primary,
          foregroundColor: Colors.white,
          shadowColor: isDark ? Colors.transparent : null,
        ),
        child: child,
      ),
    );
  }
}