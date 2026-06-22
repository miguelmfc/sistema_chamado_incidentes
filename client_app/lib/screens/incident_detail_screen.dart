import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/incident.dart';
import '../services/incident_service.dart';
import '../utils/app_theme.dart';

class IncidentDetailScreen extends StatefulWidget {
  final int incidentId;

  const IncidentDetailScreen({super.key, required this.incidentId});

  @override
  State<IncidentDetailScreen> createState() => _IncidentDetailScreenState();
}

class _IncidentDetailScreenState extends State<IncidentDetailScreen> {
  final IncidentService _service = IncidentService();
  Incident? _incident;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final incident =
          await _service.getIncidentById(widget.incidentId);
      setState(() {
        _incident = incident;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Widget _infoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              color: Colors.white38,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inc = _incident;

    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detalhes do incidente',
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.accent),
            )
          : inc == null
              ? Center(
                  child: Text(
                    'Incidente não encontrado',
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.white38,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white10,
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TITLE + STATUS
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                inc.title,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.statusColor(inc.status)
                                    .withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppTheme.statusColor(inc.status)
                                      .withOpacity(0.3),
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                AppTheme.statusLabel(inc.status),
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      AppTheme.statusColor(inc.status),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        Divider(color: Colors.white12),

                        const SizedBox(height: 14),

                        _infoItem('Descrição', inc.description),
                        _infoItem(
                          'Severidade',
                          inc.severity.toUpperCase(),
                        ),
                        _infoItem(
                          'Reportado por',
                          inc.reporterName,
                        ),
                        _infoItem(
                          'Analista responsável',
                          inc.analystName ?? 'Aguardando atribuição',
                        ),
                        _infoItem('Criado em', inc.createdAt),
                        _infoItem('Atualizado em', inc.updatedAt),
                      ],
                    ),
                  ),
                ),
    );
  }
}