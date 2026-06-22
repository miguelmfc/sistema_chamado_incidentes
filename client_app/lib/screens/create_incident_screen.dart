import 'package:flutter/material.dart';
import '../services/incident_service.dart';

class CreateIncidentScreen extends StatefulWidget {
  const CreateIncidentScreen({super.key});

  @override
  State<CreateIncidentScreen> createState() => _CreateIncidentScreenState();
}

class _CreateIncidentScreenState extends State<CreateIncidentScreen> {
  final IncidentService _service = IncidentService();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _nameController = TextEditingController();
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
        _descController.text.trim().isEmpty ||
        _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await _service.createIncident(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        severity: _severity,
        reporterName: _nameController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Incidente reportado com sucesso!'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao criar incidente. Verifique a conexão.'),
          backgroundColor: Color(0xFFC62828),
        ),
      );
    }
  }

  Widget _field(String label, TextEditingController ctrl,
      {int maxLines = 1, String hint = ''}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF424242))),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF212121)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Reportar incidente',
          style: TextStyle(
            color: Color(0xFF212121),
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _field('Título', _titleController,
                hint: 'Ex: Acesso suspeito detectado'),
            _field('Descrição', _descController,
                maxLines: 4, hint: 'Descreva o que aconteceu...'),
            _field('Seu nome', _nameController, hint: 'Ex: João Silva'),
            const Text('Severidade',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF424242))),
            const SizedBox(height: 8),
            Row(
              children: _severities.map((s) {
                final selected = _severity == s['value'];
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _severity = s['value']!),
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF1565C0)
                            : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        s['label']!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: selected
                              ? Colors.white
                              : const Color(0xFF757575),
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
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Enviar incidente',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
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