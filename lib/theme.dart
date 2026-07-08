import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const ink = Color(0xFF16231F);
  static const paper = Color(0xFFF6F4EE);
  static const paper2 = Color(0xFFEEEBE1);
  static const line = Color(0xFFD9D4C4);
  static const brand = Color(0xFF136F4B);
  static const brandDim = Color(0xFF0E5A3C);
  static const brandTint = Color(0xFFE2F0E9);
  static const amber = Color(0xFFC98A2C);
  static const red = Color(0xFFB0402F);

  static const levelCourse = Color(0xFF136F4B);
  static const levelSubject = Color(0xFF2C6E8F);
  static const levelChapter = Color(0xFFA06A1F);
  static const levelLecture = Color(0xFF7C4A9E);
}

class AppTheme {
  static ThemeData light() => _apply(ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.paper,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.brand,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ));

  static ThemeData dark() => _apply(ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF10221A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.brand,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ));

  static ThemeData _apply(ThemeData base) {
    final isDark = base.brightness == Brightness.dark;
    final display = GoogleFonts.frauncesTextTheme(base.textTheme);
    final body = GoogleFonts.interTextTheme(base.textTheme);
    return base.copyWith(
      textTheme: body.copyWith(
        headlineLarge: display.headlineLarge?.copyWith(fontWeight: FontWeight.w600),
        headlineMedium: display.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
        headlineSmall: display.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
        titleLarge: display.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        titleMedium: display.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: base.scaffoldBackgroundColor,
        foregroundColor: isDark ? Colors.white : AppColors.ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: display.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: isDark ? Colors.white : AppColors.ink,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? const Color(0xFF15281F) : Colors.white,
        indicatorColor: AppColors.brand.withOpacity(0.15),
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? const Color(0xFF17281F) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: isDark ? Colors.white10 : AppColors.line),
        ),
      ),
    );
  }
}

/// Shared row style for Subjects/Chapters/Lectures — a colored left tab
/// that echoes the admin dashboard's binder-tab navigation, tying the
/// two surfaces (app + admin) into one visual identity.
class LevelCard extends StatelessWidget {
  final Color accent;
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const LevelCard({
    super.key,
    required this.accent,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white10
              : AppColors.line,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 5, color: accent),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, color: accent, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600)),
                            if (subtitle != null) ...[
                              const SizedBox(height: 2),
                              Text(subtitle!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: Colors.grey)),
                            ],
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
