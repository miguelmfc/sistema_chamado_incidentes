import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/incident.dart';
import '../models/user.dart';
import '../services/incident_service.dart';
import '../services/mom_service.dart';
import '../utils/app_theme.dart';
import 'incident_detail_screen.dart';
import 'create_incident_screen.dart';
import 'login_screen.dart';

class IncidentListScreen extends StatefulWidget {
  final User user;
  const IncidentListScreen({super.key, required this.user});

  @override
  State<IncidentListScreen> createState() => _IncidentListScreenState();
}

class _IncidentListScreenState extends State<IncidentListScreen> {
  final IncidentService _service = IncidentService();
  final MomService _mom = MomService();
  List<Incident> _incidents = [];
  List<Incident> _filtered = [];
  String _selectedTab = 'Todos';
  bool _loading = true;
  StreamSubscription? _sub;

  final List<String> _tabs = ['Todos', 'Abertos', 'Em andamento', 'Resolvidos'];

  @override
  void initState() {
    super.initState();
    _loadIncidents();
    _mom.startPolling();
    _sub = _mom.events.listen((event) {
      if (event['type'] == 'incidents_updated') {
        final list = event['data'] as List;
        setState(() {
          _incidents = list.map((j) => Incident.fromJson(j)).toList();
          _applyFilter();
        });
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _mom.stop();
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
        _filtered =
            _incidents.where((i) => i.status == 'in_progress').toList();
      } else {
        _filtered = _incidents
            .where((i) => i.status == 'resolved' || i.status == 'closed')
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.shield_outlined,
                color: AppTheme.accent, size: 20),
            const SizedBox(width: 8),
            Text(
              'SecCall',
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              children: [
                Text(
                  widget.user.name.split(' ').first,
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LoginScreen()),
                  ),
                  child: const Icon(Icons.logout,
                      color: Colors.white38, size: 20),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppTheme.surface,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _tabs.map((tab) {
                  final sel = _selectedTab == tab;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedTab = tab);
                      _applyFilter();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(
                        color: sel
                            ? AppTheme.accent.withOpacity(0.15)
                            : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              sel ? AppTheme.accent : Colors.white12,
                          width: sel ? 1.5 : 0.5,
                        ),
                      ),
                      child: Text(
                        tab,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: sel
                              ? AppTheme.accent
                              : Colors.white38,
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
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppTheme.accent))
                : _filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox_outlined,
                                color: Colors.white24, size: 48),
                            const SizedBox(height: 12),
                            Text(
                              'Nenhum incidente',
                              style: GoogleFonts.spaceGrotesk(
                                  color: Colors.white38),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: AppTheme.accent,
                        backgroundColor: AppTheme.card,
                        onRefresh: _loadIncidents,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filtered.length,
                          itemBuilder: (context, index) {
                            final inc = _filtered[index];
                            return GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        IncidentDetailScreen(
                                            incidentId: inc.id),
                                  ),
                                );
                                _loadIncidents();
                              },
                              child: Container(
                                margin:
                                    const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppTheme.card,
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.white10,
                                      width: 0.5),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: AppTheme.severityColor(
                                                inc.severity)
                                            .withOpacity(0.12),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        border: Border.all(
                                          color:
                                              AppTheme.severityColor(
                                                      inc.severity)
                                                  .withOpacity(0.3),
                                          width: 0.5,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.warning_amber_rounded,
                                        color: AppTheme.severityColor(
                                            inc.severity),
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
                                            inc.title,
                                            style:
                                                GoogleFonts.spaceGrotesk(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                            maxLines: 1,
                                            overflow:
                                                TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            inc.createdAt,
                                            style:
                                                GoogleFonts.spaceGrotesk(
                                              fontSize: 11,
                                              color: Colors.white38,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.statusColor(
                                                inc.status)
                                            .withOpacity(0.12),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                        border: Border.all(
                                          color: AppTheme.statusColor(
                                                  inc.status)
                                              .withOpacity(0.3),
                                          width: 0.5,
                                        ),
                                      ),
                                      child: Text(
                                        AppTheme.statusLabel(inc.status),
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: AppTheme.statusColor(
                                              inc.status),
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
            MaterialPageRoute(
              builder: (_) =>
                  CreateIncidentScreen(user: widget.user),
            ),
          );
          _loadIncidents();
        },
        backgroundColor: AppTheme.accent,
        foregroundColor: AppTheme.primary,
        icon: const Icon(Icons.add),
        label: Text(
          'Novo chamado',
          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}