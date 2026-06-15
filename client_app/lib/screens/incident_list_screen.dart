import 'dart:async';
import 'package:flutter/material.dart';
import '../models/incident.dart';
import '../services/incident_service.dart';
import 'incident_detail_screen.dart';
import 'create_incident_screen.dart';

class IncidentListScreen extends StatefulWidget {
  const IncidentListScreen({super.key});

  @override
  State<IncidentListScreen> createState() => _IncidentListScreenState();
}

class _IncidentListScreenState extends State<IncidentListScreen> {
  final IncidentService _service = IncidentService();
  List<Incident> _incidents = [];
  List<Incident> _filtered = [];
  String _selectedTab = 'Todos';
  bool _loading = true;
  Timer? _pollingTimer;

  final List<String> _tabs = ['Todos', 'Abertos', 'Em andamento', 'Resolvidos'];

  @override
  void initState() {
    super.initState();
    _loadIncidents();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _loadIncidents(),
    );
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadIncidents() async {
    try {
      final incidents = await _service.getIncidents();
      setState(() {
        _incidents = incidents;
        _applyFilter();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _applyFilter() {
    setState(() {
      if (_selectedTab == 'Todos') {
        _filtered = _incidents;
      } else if (_selectedTab == 'Abertos') {
        _filtered = _incidents.where((i) => i.status == 'open').toList();
      } else if (_selectedTab == 'Em andamento') {
        _filtered = _incidents.where((i) => i.status == 'in_progress').toList();
      } else {
        _filtered = _incidents
            .where((i) => i.status == 'resolved' || i.status == 'closed')
            .toList();
      }
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'open': return const Color(0xFF1565C0);
      case 'in_progress': return const Color(0xFFF57F17);
      case 'resolved': return const Color(0xFF2E7D32);
      case 'closed': return Colors.grey;
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

  Color _severityColor(String severity) {
    switch (severity) {
      case 'critical': return const Color(0xFFC62828);
      case 'high': return const Color(0xFFE65100);
      case 'medium': return const Color(0xFFF57F17);
      case 'low': return const Color(0xFF2E7D32);
      default: return Colors.grey;
    }
  }

  IconData _severityIcon(String severity) {
    switch (severity) {
      case 'critical':
      case 'high': return Icons.warning_amber_rounded;
      case 'medium': return Icons.info_outline_rounded;
      case 'low': return Icons.check_circle_outline_rounded;
      default: return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Incidentes',
          style: TextStyle(
            color: Color(0xFF212121),
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF757575)),
            onPressed: _loadIncidents,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _tabs.map((tab) {
                  final selected = _selectedTab == tab;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedTab = tab);
                      _applyFilter();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF1565C0)
                            : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tab,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: selected ? Colors.white : const Color(0xFF757575),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhum incidente encontrado.',
                          style: TextStyle(color: Color(0xFF9E9E9E)),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadIncidents,
                        child: ListView.builder(
                          itemCount: _filtered.length,
                          itemBuilder: (context, index) {
                            final incident = _filtered[index];
                            return GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => IncidentDetailScreen(
                                      incidentId: incident.id,
                                    ),
                                  ),
                                );
                                _loadIncidents();
                              },
                              child: Container(
                                color: Colors.white,
                                margin: const EdgeInsets.only(bottom: 1),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE3F2FD),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        _severityIcon(incident.severity),
                                        color: _severityColor(incident.severity),
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            incident.title,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF212121),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            incident.createdAt,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF9E9E9E),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: _statusColor(incident.status)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _statusLabel(incident.status),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: _statusColor(incident.status),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateIncidentScreen()),
          );
          _loadIncidents();
        },
        backgroundColor: const Color(0xFF1565C0),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Novo chamado',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}