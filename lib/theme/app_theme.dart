import 'package:flutter/material.dart';

/// GiyÇık uygulaması için sade ve modern tema.
class AppTheme {
  AppTheme._();

  // Ana renk paleti - Safir ve Platin Şıklığı (Açık Mod)
  static const Color _primary = Color(0xFF0D224D);      // Derin Safir Mavisi (Butonlar ve Vurgular)
  static const Color _primaryLight = Color(0xFF1A3263); // Safir açığı
  static const Color _surface = Color(0xFFF8F9FA);      // Kırık Beyaz (Arka Plan)
  static const Color _surfaceVariant = Color(0xFFFFFFFF); // Yüzeyler (Saf Beyaz Kartlar)
  static const Color _onSurface = Color(0xFF0D224D);   // Koyu Safir (Ana Metin)
  static const Color _onSurfaceVariant = Color(0xFF607D8B); // Gri/Mavi (ikincil metin)
  static const Color _outline = Color(0xFFE0E0E0); // Platin/Gümüş (Çerçeveler)

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: _primary,
        primaryContainer: _primaryLight,
        surface: _surface,
        surfaceContainerHighest: _surfaceVariant,
        onSurface: _onSurface,
        onSurfaceVariant: _onSurfaceVariant,
        outline: _outline,
      ),
      scaffoldBackgroundColor: _surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: _onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: _onSurface),
      ),
      cardTheme: CardThemeData(
        color: _surfaceVariant,
        elevation: 8,
        shadowColor: _primary.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: _primary.withValues(alpha: 0.3)),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: _primary.withValues(alpha: 0.25),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: _primary.withValues(alpha: 0.3)),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: _primary.withValues(alpha: 0.25),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: _primary.withValues(alpha: 0.3)),
          ),
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: _onSurface,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        titleMedium: TextStyle(
          color: _onSurface,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: TextStyle(
          color: _onSurfaceVariant,
          fontSize: 14,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          color: _onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _surface,
        indicatorColor: _primary.withValues(alpha: 0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return const IconThemeData(color: _primary);
          return IconThemeData(color: _onSurfaceVariant.withValues(alpha: 0.7));
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return const TextStyle(color: _primary, fontWeight: FontWeight.bold, fontSize: 12);
          return TextStyle(color: _onSurfaceVariant.withValues(alpha: 0.7), fontSize: 12, fontWeight: FontWeight.w500);
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFB00020)),
        ),
        labelStyle: const TextStyle(color: _onSurfaceVariant),
        hintStyle: const TextStyle(color: _onSurfaceVariant),
      ),
    );
  }

  // ── Koyu Tema ──────────────────────────────────────────────
  static const Color _darkPrimary = Color(0xFFE0E0E0);       // Platin/Gümüş (Karanlık Modda Vurgu)
  static const Color _darkPrimaryContainer = Color(0xFFFFFFFF); // Parlak Gümüş
  static const Color _darkSurface = Color(0xFF0A1939);        // Daha Derin Safir Mavisi arka plan
  static const Color _darkSurfaceVariant = Color(0xFF12234B); // Yüzeyler
  static const Color _darkOnSurface = Color(0xFFFFFFFF);     // Saf Beyaz metin
  static const Color _darkOnSurfaceVariant = Color(0xFFB0BEC5); // Gümüş/Gri
  static const Color _darkOutline = Color(0xFF2C4A87);       // Safir Çerçeve
  static const Color _darkCardColor = Color(0xFF12234B);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: _darkPrimary,
        primaryContainer: _darkPrimaryContainer,
        surface: _darkSurface,
        surfaceContainerHighest: _darkSurfaceVariant,
        onSurface: _darkOnSurface,
        onSurfaceVariant: _darkOnSurfaceVariant,
        outline: _darkOutline,
      ),
      scaffoldBackgroundColor: _darkSurface,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: _darkOnSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: _darkOnSurface),
      ),
      cardTheme: CardThemeData(
        color: _darkCardColor,
        elevation: 8,
        shadowColor: _darkPrimary.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: _darkPrimary.withValues(alpha: 0.3)),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkPrimary,
          foregroundColor: _darkSurface,
          elevation: 4,
          shadowColor: _darkPrimary.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: _darkPrimary.withValues(alpha: 0.4)),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _darkPrimary,
          foregroundColor: _darkSurface,
          elevation: 4,
          shadowColor: _darkPrimary.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: _darkPrimary.withValues(alpha: 0.4)),
          ),
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: _darkOnSurface,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        titleMedium: TextStyle(
          color: _darkOnSurface,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: TextStyle(
          color: _darkOnSurfaceVariant,
          fontSize: 14,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          color: _darkOnSurface,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _darkSurface,
        indicatorColor: _darkPrimary.withValues(alpha: 0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return const IconThemeData(color: _darkPrimary);
          return IconThemeData(color: _darkOnSurfaceVariant.withValues(alpha: 0.7));
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return const TextStyle(color: _darkPrimary, fontWeight: FontWeight.bold, fontSize: 12);
          return TextStyle(color: _darkOnSurfaceVariant.withValues(alpha: 0.7), fontSize: 12, fontWeight: FontWeight.w500);
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkCardColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCF6679)),
        ),
        labelStyle: const TextStyle(color: _darkOnSurfaceVariant),
        hintStyle: const TextStyle(color: _darkOnSurfaceVariant),
      ),
    );
  }
}
