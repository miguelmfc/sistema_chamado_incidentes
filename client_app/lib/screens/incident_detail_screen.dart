import 'package:flutter/material.dart';
import '../models/incident.dart';
import '../services/incident_service.dart';

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
      final incident = await _service.getIncidentById(widget.incidentId);
      setState(() {
        _incident = incident;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'open': return const Color(0xFF1565C0);
      case 'in_progress': return const Color(0xFFF57F17);
      case 'resolved': return const Color(0xFF2E7D32);
      default: return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'open': return 'Aberto';
      case 'in_progress': return 'Em andamento';
      case 'resolved': return 'Resolvido';
      case 'closed': return 'Fechado';
      default: return status;
    }
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF9E9E9E))),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 15, color: Color(0xFF212121))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF212121)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detalhes do incidente',
          style: TextStyle(
            color: Color(0xFF212121),
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _incident == null
              ? const Center(child: Text('Incidente não encontrado'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE0E0E0),
                            width: 0.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _incident!.title,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF212121),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _statusColor(_incident!.status)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _statusLabel(_incident!.status),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: _statusColor(_incident!.status),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Divider(height: 1, color: Color(0xFFF0F0F0)),
                            const SizedBox(height: 16),
                            _infoRow('Descrição', _incident!.description),
                            _infoRow('Severidade', _incident!.severity.toUpperCase()),
                            _infoRow('Reportado por', _incident!.reporterName),
                            _infoRow(
                              'Analista responsável',
                              _incident!.analystName ?? 'Aguardando atribuição',
                            ),
                            _infoRow('Aberto em', _incident!.createdAt),
                            _infoRow('Última atualização', _incident!.updatedAt),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}