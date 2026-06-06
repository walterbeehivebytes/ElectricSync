import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Colour tokens ────────────────────────────────────────────────────────────

class AppColors {
  AppColors._();

  // Backgrounds
  static const background  = Color(0xFF0F1117);
  static const surface     = Color(0xFF1C1F26);
  static const surfaceHigh = Color(0xFF252932);
  static const border      = Color(0xFF2E3340);

  // Role accents
  static const pm = Color(0xFFFFAB00); // Project Manager – amber
  static const sm = Color(0xFF4A9FFF); // Site Manager    – blue
  static const tl = Color(0xFF34D058); // Team Lead       – green
  static const tm = Color(0xFF00C8E8); // Team Member     – cyan

  // Priority / severity
  static const urgent = Color(0xFFFF4444);
  static const high   = Color(0xFFFF8C00);
  static const medium = Color(0xFF4A9FFF);
  static const low    = Color(0xFF6B7280);

  // Text
  static const textPrimary   = Color(0xFFF0F2F5);
  static const textSecondary = Color(0xFF8B90A0);
  static const textMuted     = Color(0xFF4B5063);
}

// ─── Typography helpers ───────────────────────────────────────────────────────

class AppText {
  AppText._();

  // Barlow Condensed – headings, numbers, role labels
  static TextStyle display(double size, {
    FontWeight weight = FontWeight.w700,
    Color color = AppColors.textPrimary,
    double letterSpacing = 0.3,
  }) =>
      GoogleFonts.barlowCondensed(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
      );

  // DM Sans – body, labels, descriptions
  static TextStyle body(double size, {
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.textPrimary,
    double letterSpacing = 0.0,
  }) =>
      GoogleFonts.dmSans(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
      );
}

// ─── Role helpers ─────────────────────────────────────────────────────────────

extension RoleTheme on UserRoleTheme {
  static Color colorFor(String roleKey) {
    switch (roleKey) {
      case 'pm': return AppColors.pm;
      case 'sm': return AppColors.sm;
      case 'tl': return AppColors.tl;
      case 'tm': return AppColors.tm;
      default:   return AppColors.pm;
    }
  }
}

class UserRoleTheme {}

// ─── Priority colour helper ───────────────────────────────────────────────────

Color priorityColor(String priority) {
  switch (priority.toLowerCase()) {
    case 'urgent': return AppColors.urgent;
    case 'high':   return AppColors.high;
    case 'low':    return AppColors.low;
    default:       return AppColors.medium;
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

/// Thin left-border task/project card used across all dashboards.
class AppCard extends StatelessWidget {
  final Color accentColor;
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.accentColor,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border(
            left: BorderSide(color: accentColor, width: 3),
          ),
        ),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Small uppercase status chip.
class StatusChip extends StatelessWidget {
  final String label;
  final Color? color;

  const StatusChip(this.label, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppText.display(9, color: c, letterSpacing: 1.2),
      ),
    );
  }
}

/// Bold stat card with left accent border.
class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const StatCard({super.key, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: AppText.display(34, color: color)),
          const SizedBox(height: 4),
          Text(label, style: AppText.body(11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

/// Section header: uppercase label + optional count badge.
class SectionHeader extends StatelessWidget {
  final String title;
  final int? count;
  final Color? countColor;

  const SectionHeader(this.title, {super.key, this.count, this.countColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(title, style: AppText.display(13, color: AppColors.textSecondary, letterSpacing: 2, weight: FontWeight.w700)),
          if (count != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: (countColor ?? AppColors.pm).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: AppText.display(11, color: countColor ?? AppColors.pm, weight: FontWeight.w700),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Role badge pill shown in app bars.
class RoleBadge extends StatelessWidget {
  final String label;
  final Color color;

  const RoleBadge(this.label, {super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(label, style: AppText.display(11, color: color, weight: FontWeight.w700, letterSpacing: 1.5)),
    );
  }
}

/// Standard icon button for app bars.
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const AppIconButton(this.icon, {super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 18, color: AppColors.textSecondary),
      ),
    );
  }
}

/// Primary CTA button (solid accent colour).
class PrimaryButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool fullWidth;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.color,
    this.onPressed,
    this.icon,
    this.loading = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = color == AppColors.pm || color == AppColors.tl || color == AppColors.tm;
    final fgColor = isDark ? const Color(0xFF000000) : Colors.white;

    Widget content = loading
        ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: fgColor))
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 16, color: fgColor), const SizedBox(width: 6)],
              Text(label, style: AppText.body(14, weight: FontWeight.w600, color: fgColor)),
            ],
          );

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: GestureDetector(
        onTap: loading ? null : onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          decoration: BoxDecoration(
            color: loading ? color.withValues(alpha: 0.5) : color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(child: content),
        ),
      ),
    );
  }
}

/// Ghost / outlined button.
class GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final bool fullWidth;

  const GhostButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.color,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textSecondary;
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[Icon(icon, size: 16, color: c), const SizedBox(width: 6)],
              Text(label, style: AppText.body(14, weight: FontWeight.w600, color: c)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Empty state widget.
class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyState({super.key, required this.message, this.icon = Icons.check_circle_outline});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(icon, color: AppColors.textMuted, size: 24),
          ),
          const SizedBox(height: 12),
          Text(message, style: AppText.body(13, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// ─── ThemeData ────────────────────────────────────────────────────────────────

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.dark(
      primary: AppColors.pm,
      secondary: AppColors.sm,
      surface: AppColors.surface,
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onSurface: AppColors.textPrimary,
      outline: AppColors.border,
    ),
    textTheme: GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge:  GoogleFonts.barlowCondensed(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
      displayMedium: GoogleFonts.barlowCondensed(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
      displaySmall:  GoogleFonts.barlowCondensed(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
      headlineLarge: GoogleFonts.barlowCondensed(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
      titleTextStyle: GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      iconTheme: const IconThemeData(color: AppColors.textSecondary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      labelStyle: AppText.body(14, color: AppColors.textSecondary),
      hintStyle: AppText.body(14, color: AppColors.textMuted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.pm, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.pm,
        foregroundColor: Colors.black,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        side: const BorderSide(color: AppColors.border),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.pm,
        textStyle: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.border),
      ),
      margin: const EdgeInsets.only(bottom: 8),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1, space: 1),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surfaceHigh,
      contentTextStyle: AppText.body(14, color: AppColors.textPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      behavior: SnackBarBehavior.floating,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.surfaceHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surfaceHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.pm.withValues(alpha: 0.18),
      disabledColor: AppColors.surface,
      labelStyle: AppText.body(13, color: AppColors.textSecondary),
      side: const BorderSide(color: AppColors.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.pm),
    iconTheme: const IconThemeData(color: AppColors.textSecondary),
  );
}
