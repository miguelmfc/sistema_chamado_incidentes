import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/incident_service.dart';
import '../models/user.dart';
import '../utils/app_theme.dart';

class CreateIncidentScreen extends StatefulWidget {
  final User user;
  const CreateIncidentScreen({super.key, required this.user});

  @override
  State<CreateIncidentScreen> createState() => _CreateIncidentScreenState();
}

class _CreateIncidentScreenState extends State<CreateIncidentScreen> {
  final IncidentService _service = IncidentService();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _severity = 'medium';
  bool _loading = false;

  final List<Map<String, String>> _severities = [
    {'value': 'low', 'label': 'Baixo'},
    {'value': 'medium', 'label': 'Médio'},
    {'value': 'high', 'label': 'Alto'},
    {'value': 'critical', 'label': 'Crítico'},
  ];

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty ||
        _descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Preencha todos os campos',
              style: GoogleFonts.spaceGrotesk()),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await _service.createIncident(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        severity: _severity,
        reporterName: widget.user.name,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Incidente reportado com sucesso!',
                style: GoogleFonts.spaceGrotesk()),
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao criar incidente. Verifique a conexão.',
              style: GoogleFonts.spaceGrotesk()),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }

  Widget _field(String label, TextEditingController ctrl,
      {int maxLines = 1, String hint = ''}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white54,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.white12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.white12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppTheme.accent, width: 1),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Icon(Icons.shield_outlined,
                color: AppTheme.accent, size: 18),
            const SizedBox(width: 8),
            Text(
              'Reportar incidente',
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info do reportante
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppTheme.accent.withOpacity(0.2), width: 0.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_outline,
                      color: AppTheme.accent, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Reportando como: ',
                    style: GoogleFonts.spaceGrotesk(
                        color: Colors.white38, fontSize: 13),
                  ),
                  Text(
                    widget.user.name,
                    style: GoogleFonts.spaceGrotesk(
                      color: AppTheme.accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            _field('Título', _titleController,
                hint: 'Ex: Acesso suspeito detectado'),
            _field('Descrição', _descController,
                maxLines: 5, hint: 'Descreva detalhadamente o que aconteceu...'),

            // Severidade
            Text(
              'Severidade',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: _severities.map((s) {
                final selected = _severity == s['value'];
                final color = AppTheme.severityColor(s['value']!);
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _severity = s['value']!),
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? color.withOpacity(0.15)
                            : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selected ? color : Colors.white12,
                          width: selected ? 1.5 : 0.5,
                        ),
                      ),
                      child: Text(
                        s['label']!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: selected ? color : Colors.white38,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.primary,
                        ),
                      )
                    : Text(
                        'Enviar incidente',
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}