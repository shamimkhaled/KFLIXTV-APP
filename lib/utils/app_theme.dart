import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens matching the KFLIX TV dark UI mockup.
class KColors {
  KColors._();

  // ── Brand ──────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF6C5CE7);
  static const Color secondary = Color(0xFF00B4D8);
  static const List<Color> brandGradient = [primary, secondary];

  // ── Backgrounds ────────────────────────────────────────────────────────
  static const Color background = Color(0xFF0B0A14);
  static const Color surface = Color(0xFF16141F);
  static const Color surfaceVariant = Color(0xFF1C1A28);
  static const Color surfaceHighest = Color(0xFF211E2E);

  // ── Text ───────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF4F3F8);
  static const Color textSecondary = Color(0xFFCFCADA);
  static const Color textMuted = Color(0xFF8A8497);

  // ── Navigation ──────────────────────────────────────────────────────────
  static const Color navSelected = Color(0xFFA78BFA);
  static const Color navInactive = Color(0xFF6E6D7C);

  // ── Status ──────────────────────────────────────────────────────────────
  static const Color online = Color(0xFF2ECC71);
  static const Color offline = Color(0xFFE74C3C);
  static const Color checking = Color(0xFFF39C12);
  static const Color liveRed = Color(0xFFFF2D55);

  // ── Borders ─────────────────────────────────────────────────────────────
  static const Color borderSubtle = Color(0x0FFFFFFF);   // 6% white
  static const Color borderMedium = Color(0x1AFFFFFF);   // 10% white

  // ── Card accent gradients (cycled by index) ──────────────────────────────
  static const List<List<Color>> cardAccents = [
    [Color(0x616C5CE7), Color(0x00141220)],  // purple
    [Color(0x5700B4D8), Color(0x00141220)],  // cyan
    [Color(0x50E74C3C), Color(0x00141220)],  // red
    [Color(0x50F39C12), Color(0x00141220)],  // orange
    [Color(0x502ECC71), Color(0x00141220)],  // green
  ];

  static List<Color> accentFor(int index) =>
      cardAccents[index % cardAccents.length];

  // ── World Cup header gradient ─────────────────────────────────────────────
  static const List<Color> wcGradient = [
    Color(0xFF7B0E12),
    Color(0xFFC62828),
    Color(0xFFE11D2A),
  ];
}

/// Kept for backward compatibility — existing code that imports AppColors still works.
class AppColors {
  AppColors._();

  static const Color seed = KColors.primary;
  static const List<Color> brandGradient = KColors.brandGradient;
  static const Color online = KColors.online;
  static const Color offline = KColors.offline;
  static const Color checking = KColors.checking;
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _buildDark();

  // ── Full custom dark theme matching the mockup ──────────────────────────
  static ThemeData _buildDark() {
    const cs = ColorScheme(
      brightness: Brightness.dark,
      primary: KColors.primary,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF2D2660),
      onPrimaryContainer: KColors.navSelected,
      secondary: KColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFF003B4A),
      onSecondaryContainer: Color(0xFF80DFFF),
      tertiary: KColors.liveRed,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFF5C0014),
      onTertiaryContainer: Color(0xFFFFB3BE),
      error: KColors.offline,
      onError: Colors.white,
      errorContainer: Color(0xFF4A1010),
      onErrorContainer: Color(0xFFF1C9C4),
      surface: KColors.surface,
      onSurface: KColors.textPrimary,
      surfaceContainerHighest: KColors.surfaceHighest,
      surfaceContainerHigh: KColors.surfaceVariant,
      surfaceContainerLow: KColors.surface,
      surfaceContainer: KColors.background,
      onSurfaceVariant: KColors.textMuted,
      outline: Color(0xFF3D3950),
      outlineVariant: Color(0xFF2C2940),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: KColors.textPrimary,
      onInverseSurface: KColors.background,
      inversePrimary: KColors.primary,
    );

    final textTheme = GoogleFonts.manropeTextTheme(
      const TextTheme(
        displayLarge: TextStyle(color: KColors.textPrimary),
        displayMedium: TextStyle(color: KColors.textPrimary),
        displaySmall: TextStyle(color: KColors.textPrimary),
        headlineLarge: TextStyle(color: KColors.textPrimary, fontWeight: FontWeight.w700),
        headlineMedium: TextStyle(color: KColors.textPrimary, fontWeight: FontWeight.w700),
        headlineSmall: TextStyle(color: KColors.textPrimary, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(color: KColors.textPrimary, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(color: KColors.textPrimary, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: KColors.textPrimary, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: KColors.textPrimary),
        bodyMedium: TextStyle(color: KColors.textSecondary),
        bodySmall: TextStyle(color: KColors.textMuted),
        labelLarge: TextStyle(color: KColors.textSecondary, fontWeight: FontWeight.w600),
        labelMedium: TextStyle(color: KColors.textMuted),
        labelSmall: TextStyle(color: KColors.textMuted),
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: cs,
      scaffoldBackgroundColor: KColors.background,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: KColors.background,
        foregroundColor: KColors.textPrimary,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          color: KColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: KColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: KColors.borderSubtle),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: KColors.surfaceVariant,
        selectedColor: KColors.primary,
        labelStyle: const TextStyle(color: KColors.textSecondary, fontSize: 13),
        secondaryLabelStyle: const TextStyle(color: Colors.white, fontSize: 13),
        shape: const StadiumBorder(),
        side: BorderSide.none,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xF20D0C16),
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            color: selected ? KColors.navSelected : KColors.navInactive,
            fontSize: 10,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? KColors.navSelected : KColors.navInactive,
            size: 23,
          );
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: KColors.borderSubtle,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: KColors.surface,
        hintStyle: const TextStyle(color: KColors.textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: KColors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: KColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: KColors.primary),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: ZoomPageTransitionsBuilder(),
          TargetPlatform.linux: ZoomPageTransitionsBuilder(),
        },
      ),
    );
  }

  // ── Light theme ──────────────────────────────────────────────────────────
  static ThemeData _build(Brightness brightness) {
    const cs = ColorScheme(
      brightness: Brightness.light,
      primary: KColors.primary,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFEDE9FF),
      onPrimaryContainer: Color(0xFF3D1D9E),
      secondary: KColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFD0F4FF),
      onSecondaryContainer: Color(0xFF003849),
      tertiary: Color(0xFFE11D2A),
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFFFDADB),
      onTertiaryContainer: Color(0xFF5C0010),
      error: Color(0xFFBA1A1A),
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      surface: Color(0xFFFAF8FF),
      onSurface: Color(0xFF1C1B22),
      surfaceContainerHighest: Color(0xFFE8E4F8),
      surfaceContainerHigh: Color(0xFFF0EDF8),
      surfaceContainerLow: Color(0xFFF6F3FE),
      surfaceContainer: Color(0xFFFFFFFF),
      onSurfaceVariant: Color(0xFF49454F),
      outline: Color(0xFFCBC4D4),
      outlineVariant: Color(0xFFE6E0F0),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: Color(0xFF313033),
      onInverseSurface: Color(0xFFF4EFF4),
      inversePrimary: Color(0xFFCBBEFF),
    );

    final base = ThemeData(brightness: Brightness.light);
    final textTheme = GoogleFonts.manropeTextTheme(base.textTheme).copyWith(
      headlineLarge: GoogleFonts.spaceGrotesk(
          fontSize: 28, fontWeight: FontWeight.w700, color: const Color(0xFF1C1B22)),
      headlineMedium: GoogleFonts.spaceGrotesk(
          fontSize: 22, fontWeight: FontWeight.w700, color: const Color(0xFF1C1B22)),
      titleLarge: GoogleFonts.spaceGrotesk(
          fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF1C1B22)),
      titleMedium: GoogleFonts.manrope(
          fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF1C1B22)),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: cs,
      scaffoldBackgroundColor: const Color(0xFFF6F3FE),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF1C1B22),
        titleTextStyle: GoogleFonts.spaceGrotesk(
          color: const Color(0xFF1C1B22),
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE8E4F8)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFEDE9FF),
        selectedColor: KColors.primary,
        labelStyle: const TextStyle(color: Color(0xFF49454F), fontSize: 13),
        secondaryLabelStyle: const TextStyle(color: Colors.white, fontSize: 13),
        shape: const StadiumBorder(),
        side: BorderSide.none,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final sel = states.contains(WidgetState.selected);
          return TextStyle(
            color: sel ? KColors.primary : const Color(0xFF79747E),
            fontSize: 10,
            fontWeight: sel ? FontWeight.w700 : FontWeight.w600,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final sel = states.contains(WidgetState.selected);
          return IconThemeData(
            color: sel ? KColors.primary : const Color(0xFF79747E),
            size: 23,
          );
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE8E4F8),
        thickness: 1,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: ZoomPageTransitionsBuilder(),
          TargetPlatform.linux: ZoomPageTransitionsBuilder(),
        },
      ),
    );
  }
}
