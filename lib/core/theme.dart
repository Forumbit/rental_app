import 'dart:math' as math;

import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

/// Deep forest green: calm, natural, readable on light and dark surfaces.
const brandSeed = Color(0xFF1E7A52);

abstract final class AppTheme {
  /// Tests turn this off: Google Fonts are downloaded at runtime.
  static bool useGoogleFonts = true;

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: brandSeed,
      brightness: brightness,
      dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
    );
    final base = ThemeData(colorScheme: scheme, useMaterial3: true);
    final text = !useGoogleFonts
        ? base.textTheme
        : GoogleFonts.manropeTextTheme(base.textTheme).copyWith(
            displaySmall: GoogleFonts.manrope(textStyle: base.textTheme.displaySmall, fontWeight: FontWeight.w800),
            headlineMedium: GoogleFonts.manrope(textStyle: base.textTheme.headlineMedium, fontWeight: FontWeight.w800),
            headlineSmall: GoogleFonts.manrope(textStyle: base.textTheme.headlineSmall, fontWeight: FontWeight.w700),
            titleLarge: GoogleFonts.manrope(textStyle: base.textTheme.titleLarge, fontWeight: FontWeight.w700),
            titleMedium: GoogleFonts.manrope(textStyle: base.textTheme.titleMedium, fontWeight: FontWeight.w700),
          );
    final rounded = RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));

    return base.copyWith(
      textTheme: text,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: text.titleLarge?.copyWith(color: scheme.onSurface),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: rounded,
          textStyle: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(minimumSize: const Size(64, 52), shape: rounded),
      ),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(shape: rounded)),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: rounded,
        extendedTextStyle: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
      chipTheme: ChipThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      snackBarTheme: SnackBarThemeData(behavior: SnackBarBehavior.floating, shape: rounded),
      dialogTheme: DialogThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: WidgetStatePropertyAll(text.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        indicatorColor: scheme.primaryContainer,
      ),
    );
  }
}

/// Window size classes from Material 3.
enum WindowSize {
  compact,
  medium,
  expanded;

  static WindowSize of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 600) return compact;
    if (width < 1024) return medium;
    return expanded;
  }
}

/// Limits line length on wide screens.
class ContentWidth extends StatelessWidget {
  const ContentWidth({super.key, required this.child, this.maxWidth = 1200});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    ),
  );
}

/// Centers a sliver and caps its width; [padding] is the minimum side gap.
class CenteredSliver extends StatelessWidget {
  const CenteredSliver({super.key, required this.sliver, this.maxWidth = 1400, this.padding = 16});

  final Widget sliver;
  final double maxWidth;
  final double padding;

  @override
  Widget build(BuildContext context) => SliverLayoutBuilder(
    builder: (context, constraints) {
      final side = math.max(padding, (constraints.crossAxisExtent - maxWidth) / 2);
      return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: side),
        sliver: sliver,
      );
    },
  );
}
