import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF0A1628);
  static const Color accent = Color(0xFF00D4FF);
  static const Color danger = Color(0xFFFF3B30);
  static const Color warning = Color(0xFFFF9500);
  static const Color success = Color(0xFF30D158);
  static const Color surface = Color(0xFF0D1F3C);
  static const Color card = Color(0xFF142240);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          primary: accent,
          surface: primary,
        ),
        scaffoldBackgroundColor: primary,
        textTheme: GoogleFonts.spaceGroteskTextTheme(
          ThemeData.dark().textTheme,
        ),
      );

  static Color severityColor(String s) {
    switch (s) {
      case 'critical': return danger;
      case 'high': return warning;
      case 'medium': return const Color(0xFFFFCC00);
      case 'low': return success;
      default: return Colors.grey;
    }
  }

  static Color statusColor(String s) {
    switch (s) {
      case 'open': return accent;
      case 'in_progress': return warning;
      case 'resolved': return success;
      case 'closed': return Colors.grey;
      default: return Colors.grey;
    }
  }

  static String statusLabel(String s) {
    switch (s) {
      case 'open': return 'Aberto';
      case 'in_progress': return 'Em andamento';
      case 'resolved': return 'Resolvido';
      case 'closed': return 'Fechado';
      default: return s;
    }
  }

  static String severityLabel(String s) {
    switch (s) {
      case 'critical': return 'Crítico';
      case 'high': return 'Alto';
      case 'medium': return 'Médio';
      case 'low': return 'Baixo';
      default: return s;
    }
  }
}