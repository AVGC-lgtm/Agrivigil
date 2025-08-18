import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary Colors - Modern Green Palette
  static const Color primaryColor = Color(0xFF10B981); // Emerald
  static const Color primaryLight = Color(0xFF34D399); // Light Emerald
  static const Color primaryDark = Color(0xFF059669); // Dark Emerald
  
  // Secondary Colors - Modern Blue Palette
  static const Color secondaryColor = Color(0xFF0EA5E9); // Sky Blue
  static const Color secondaryLight = Color(0xFF38BDF8); // Light Sky
  static const Color secondaryDark = Color(0xFF0284C7); // Dark Sky
  
  // Background Colors
  static const Color backgroundColor = Color(0xFFF9FAFB);
  static const Color surfaceColor = Colors.white;
  static const Color surfaceVariant = Color(0xFFF3F4F6);
  
  // Status Colors
  static const Color errorColor = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFCA5A5);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color successColor = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color infoColor = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textLight = Color(0xFFD1D5DB);
  
  // Border Colors
  static final Color borderColor = Colors.grey.shade200;
  static final Color borderLight = Colors.grey.shade100;
  static final Color borderDark = Colors.grey.shade300;
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondaryColor, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFFBFBFB)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Shadow Configurations
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.02),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: primaryColor.withOpacity(0.2),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      background: backgroundColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimary,
      onBackground: textPrimary,
      onError: Colors.white,
    ),
    
    textTheme: GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: textPrimary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: textPrimary,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: textSecondary,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: textSecondary,
      ),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.disabled)) {
            return Colors.grey.shade300;
          }
          if (states.contains(MaterialState.pressed)) {
            return primaryDark;
          }
          if (states.contains(MaterialState.hovered)) {
            return primaryLight;
          }
          return primaryColor;
        }),
        foregroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.disabled)) {
            return Colors.grey.shade500;
          }
          return Colors.white;
        }),
        elevation: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.pressed)) {
            return 0;
          }
          if (states.contains(MaterialState.hovered)) {
            return 4;
          }
          return 2;
        }),
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        textStyle: MaterialStateProperty.all(
          GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        overlayColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.pressed)) {
            return Colors.white.withOpacity(0.1);
          }
          return null;
        }),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.pressed)) {
            return primaryColor.withOpacity(0.05);
          }
          if (states.contains(MaterialState.hovered)) {
            return primaryColor.withOpacity(0.02);
          }
          return Colors.transparent;
        }),
        foregroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.disabled)) {
            return Colors.grey.shade400;
          }
          return primaryColor;
        }),
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        side: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.disabled)) {
            return BorderSide(color: Colors.grey.shade300);
          }
          if (states.contains(MaterialState.pressed)) {
            return BorderSide(color: primaryDark, width: 2);
          }
          return const BorderSide(color: primaryColor, width: 1.5);
        }),
        textStyle: MaterialStateProperty.all(
          GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceVariant,
      hoverColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: errorColor, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: GoogleFonts.inter(
        fontSize: 14,
        color: textMuted,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: GoogleFonts.inter(
        fontSize: 14,
        color: textSecondary,
        fontWeight: FontWeight.w500,
      ),
      helperStyle: GoogleFonts.inter(
        fontSize: 12,
        color: textMuted,
      ),
      errorStyle: GoogleFonts.inter(
        fontSize: 12,
        color: errorColor,
        fontWeight: FontWeight.w500,
      ),
      prefixIconColor: MaterialStateColor.resolveWith((states) {
        if (states.contains(MaterialState.focused)) {
          return primaryColor;
        }
        return textMuted;
      }),
      suffixIconColor: MaterialStateColor.resolveWith((states) {
        if (states.contains(MaterialState.focused)) {
          return primaryColor;
        }
        return textMuted;
      }),
    ),
    
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: surfaceColor,
      surfaceTintColor: Colors.transparent,
      clipBehavior: Clip.antiAliasWithSaveLayer,
    ),
    
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: surfaceColor,
      foregroundColor: textPrimary,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      iconTheme: const IconThemeData(
        color: textPrimary,
      ),
    ),
    
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surfaceColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 12),
    ),
    
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade200,
      thickness: 1,
      space: 1,
    ),
    
    chipTheme: ChipThemeData(
      backgroundColor: Colors.grey.shade100,
      disabledColor: Colors.grey.shade50,
      selectedColor: primaryColor.withOpacity(0.2),
      secondarySelectedColor: secondaryColor.withOpacity(0.2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      labelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      secondaryLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: primaryColor,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    // Additional theme customizations
    snackBarTheme: SnackBarThemeData(
      backgroundColor: textPrimary,
      contentTextStyle: GoogleFonts.inter(
        fontSize: 14,
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 4,
    ),
    
    dialogTheme: DialogThemeData(
      backgroundColor: surfaceColor,
      elevation: 16,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      contentTextStyle: GoogleFonts.inter(
        fontSize: 14,
        color: textSecondary,
      ),
    ),
    
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryColor,
      linearTrackColor: surfaceVariant,
      circularTrackColor: surfaceVariant,
      refreshBackgroundColor: surfaceColor,
    ),
    
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      hoverElevation: 6,
      focusElevation: 6,
      highlightElevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryColor;
        }
        return Colors.grey.shade400;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryLight.withOpacity(0.5);
        }
        return Colors.grey.shade300;
      }),
    ),
    
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryColor;
        }
        return Colors.transparent;
      }),
      checkColor: MaterialStateProperty.all(Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),
    
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryColor;
        }
        return textMuted;
      }),
    ),
  );
  
  // Custom decoration methods
  static BoxDecoration gradientDecoration({
    LinearGradient? gradient,
    double radius = 12,
    List<BoxShadow>? boxShadow,
  }) {
    return BoxDecoration(
      gradient: gradient ?? primaryGradient,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: boxShadow ?? cardShadow,
    );
  }
  
  static BoxDecoration cardDecoration({
    Color? color,
    double radius = 12,
    Border? border,
    List<BoxShadow>? boxShadow,
  }) {
    return BoxDecoration(
      color: color ?? surfaceColor,
      borderRadius: BorderRadius.circular(radius),
      border: border ?? Border.all(color: borderLight),
      boxShadow: boxShadow ?? cardShadow,
    );
  }
}
