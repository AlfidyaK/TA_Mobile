import 'package:flutter/material.dart';

class EventGoLogo extends StatelessWidget {
  final double fontSize;

  const EventGoLogo({super.key, this.fontSize = 22});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Warna teks "EVENT" berubah otomatis mengikuti tema
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A22);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Ikon Kalender
        Icon(
          Icons.calendar_month_rounded, 
          color: const Color(0xFF9D4EDD), // Ungu khas EventGo
          size: fontSize * 1.2,
        ),
        const SizedBox(width: 8),
        
        // Teks "EVENT"
        Text(
          'EVENT',
          style: TextStyle(
            fontWeight: FontWeight.w900, // Sangat tebal
            fontSize: fontSize,
            letterSpacing: -0.5,
            color: textColor,
          ),
        ),
        
        // Teks "GO" dengan efek Gradasi (Gradient)
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFF9D4EDD), // Ungu
              Color(0xFFFF006E), // Pink
              Color(0xFFFF9E00), // Oranye kekuningan
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(
            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
          ),
          child: Text(
            'GO',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: fontSize,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ],
    );
  }
}