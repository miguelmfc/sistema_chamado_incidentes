import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/incident.dart';
import '../models/user.dart';
import '../services/incident_service.dart';
import '../utils/app_theme.dart';

class IncidentDetailScreen extends StatefulWidget {
  final Incident incident;
  final User user;
  const IncidentDetailScreen(
      {super.key, required this.incident, required this.user});

  @override
  State<IncidentDetailScreen> createState() =>
      _IncidentDetailScreenState();
}

class _IncidentDetailScreenState extends State<IncidentDetailScreen> {
  final IncidentService _service = IncidentService();
  bool _loading = false;

  Future<void> _updateStatus(String status) async {
    setState(() => _loading = true);
    try {
      await _service.updateStatus(
          widget.incident.id, status, widget.user.name);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == 'in_progress'
                  ? 'Incidente aceito!'
                  : 'Incidente recusado.',
              style: GoogleFonts.spaceGrotesk(),
            ),
            backgroundColor: status == 'in_progress'
                ? AppTheme.success
                : AppTheme.danger,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar.',
              style: GoogleFonts.spaceGrotesk()),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }

  Widget _infoBlock(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  color: Colors.white38,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(value,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  color: valueColor ?? Colors.white70)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inc = widget.incident;
    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Detalhes do incidente',
            style: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(inc.title,
                            style: GoogleFonts.spaceGrotesk(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.severityColor(inc.severity)
                              .withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppTheme.severityColor(inc.severity)
                                  .withOpacity(0.3),
                              width: 0.5),
                        ),
                        child: Text(
                            AppTheme.severityLabel(inc.severity),
                            style: GoogleFonts.spaceGrotesk(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.severityColor(
                                    inc.severity))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 16),
                  _infoBlock('Descrição', inc.description),
                  _infoBlock('Reportado por', inc.reporterName),
                  _infoBlock('Aberto em', inc.createdAt),
                  _infoBlock(
                    'Severidade',
                    AppTheme.severityLabel(inc.severity),
                    valueColor:
                        AppTheme.severityColor(inc.severity),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Ação',
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    color: Colors.white38,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _loading
                          ? null
                          : () => _updateStatus('in_progress'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.check_circle_outline,
                          size: 18),
                      label: Text('Aceitar',
                          style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _loading
                          ? null
                          : () => _updateStatus('closed'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.danger,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: Text('Recusar',
                          style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ],
            ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Center(
                    child: CircularProgressIndicator(
                        color: AppTheme.accent)),
              ),
          ],
        ),
      ),
    );
  }
}