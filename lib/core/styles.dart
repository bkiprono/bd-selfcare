import 'package:flutter/material.dart';

// App Color Palette
class AppColors {
  static const Color primary = Color.fromARGB(255, 255, 0, 47) ;
  static const Color primaryDark =  Color(0xFF7F0000);
  static const Color secondary = Color(0xFF4CAF50);
  static const Color secondaryDark = Color(0xFF388E3C);
  static const Color accent = Color(0xFF1B3A2B);
  static const Color background = Colors.white;
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFB00020);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);

  static const Color textPrimary = Color(0xFF222222);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textOnPrimary = Colors.white;
  static const Color border = Color(0xFFE0E0E0);
}

// Spacing Scale
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

// Border Radius Scale
class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 9999.0;
}

/// Responsive text scale helper
double responsiveFontSize(BuildContext context, double baseSize) {
  final width = MediaQuery.of(context).size.width;
  // Example breakpoints: <360: small, <480: medium, else: large
  if (width < 360) {
    return baseSize * 0.82;
  } else if (width < 480) {
    return baseSize * 0.92;
  } else {
    return baseSize;
  }
}

/// Responsive Text Styles
class AppTextStyles {
  static TextStyle headline1(BuildContext context) => TextStyle(
    fontSize: responsiveFontSize(context, 22),
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  static TextStyle headline2(BuildContext context) => TextStyle(
    fontSize: responsiveFontSize(context, 18),
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  static TextStyle subtitle1(BuildContext context) => TextStyle(
    fontSize: responsiveFontSize(context, 15),
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static TextStyle body1(BuildContext context) => TextStyle(
    fontSize: responsiveFontSize(context, 13),
    color: AppColors.textPrimary,
  );
  static TextStyle body2(BuildContext context) => TextStyle(
    fontSize: responsiveFontSize(context, 12),
    color: AppColors.textSecondary,
  );
  static TextStyle button(BuildContext context) => TextStyle(
    fontSize: responsiveFontSize(context, 13),
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
    letterSpacing: 1.0,
  );
  static TextStyle caption(BuildContext context) => TextStyle(
    fontSize: responsiveFontSize(context, 10),
    color: AppColors.textSecondary,
  );
}

// Responsive ThemeData builder
ThemeData appTheme(BuildContext context) {
  return ThemeData(
    useMaterial3: true,
    visualDensity: VisualDensity.compact,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.textOnPrimary,
      primaryContainer: AppColors.primaryDark,
      onPrimaryContainer: AppColors.textOnPrimary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.textOnPrimary,
      secondaryContainer: AppColors.secondaryDark,
      onSecondaryContainer: AppColors.textOnPrimary,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
      onError: AppColors.textOnPrimary,
    ),
    scaffoldBackgroundColor: AppColors.background,
    textTheme: TextTheme(
      displayLarge: AppTextStyles.headline1(context),
      displayMedium: AppTextStyles.headline2(context),
      titleMedium: AppTextStyles.subtitle1(context),
      bodyLarge: AppTextStyles.body1(context),
      bodyMedium: AppTextStyles.body2(context),
      labelLarge: AppTextStyles.button(context),
      bodySmall: AppTextStyles.caption(context),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      elevation: 0,
      titleTextStyle: AppTextStyles.headline2(context),
      iconTheme: const IconThemeData(color: AppColors.textOnPrimary, size: 20),
      toolbarHeight: 40,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(64, 32),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        textStyle: AppTextStyles.button(context),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      border: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.border),
      ),
      labelStyle: TextStyle(
        color: AppColors.textSecondary,
        fontSize: responsiveFontSize(context, 12),
      ),
    ),
  );
}
