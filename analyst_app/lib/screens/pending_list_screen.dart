import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/incident.dart';
import '../models/user.dart';
import '../services/mom_service.dart';
import '../utils/app_theme.dart';
import 'incident_detail_screen.dart';
import 'in_progress_screen.dart';
import 'history_screen.dart';
import 'login_screen.dart';

class PendingListScreen extends StatefulWidget {
  final User user;
  const PendingListScreen({super.key, required this.user});

  @override
  State<PendingListScreen> createState() => _PendingListScreenState();
}

class _PendingListScreenState extends State<PendingListScreen> {
  final MomService _mom = MomService();
  List<Incident> _pending = [];
  bool _loading = true;
  StreamSubscription? _sub;
  int _prevCount = 0;
  String? _severityFilter; // null = todos

  static const _severities = ['critical', 'high', 'medium', 'low'];

  List<Incident> get _filtered => _severityFilter == null
      ? _pending
      : _pending.where((i) => i.severity == _severityFilter).toList();

  @override
  void initState() {
    super.initState();
    _mom.startPolling();
    _sub = _mom.stream.listen((list) {
      final pending = list
          .map((j) => Incident.fromJson(j))
          .where((i) => i.status == 'open')
          .toList();

      if (pending.length > _prevCount && _prevCount > 0) {
        _showNewIncidentBanner();
      }

      setState(() {
        _pending = pending;
        _prevCount = pending.length;
        _loading = false;
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _mom.stop();
    super.dispose();
  }

  void _showNewIncidentBanner() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.notification_important,
              color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text('Novo incidente recebido!',
              style: GoogleFonts.spaceGrotesk(
                  color: Colors.white, fontWeight: FontWeight.w500)),
        ]),
        backgroundColor: AppTheme.warning,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Widget _chip(String label, String? value, {Color? color}) {
    final selected = _severityFilter == value;
    final chipColor = color ?? AppTheme.accent;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _severityFilter = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: selected
                ? chipColor.withOpacity(0.2)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? chipColor.withOpacity(0.6)
                  : Colors.white12,
              width: selected ? 1 : 0.5,
            ),
          ),
          child: Text(label,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? chipColor : Colors.white38)),
        ),
      ),
    );
  }

  Widget _timeAgo(String createdAt) {
    final created = DateTime.tryParse(createdAt) ?? DateTime.now();
    final diff = DateTime.now().difference(created);
    String label;
    bool isOld = false;

    if (diff.inMinutes < 60) {
      label = 'Há ${diff.inMinutes}min';
    } else if (diff.inHours < 24) {
      label = 'Há ${diff.inHours}h';
      isOld = diff.inHours >= 4;
    } else {
      label = 'Há ${diff.inDays} dia${diff.inDays > 1 ? 's' : ''}';
      isOld = true;
    }

    return Row(children: [
      Icon(Icons.schedule,
          size: 11,
          color: isOld ? AppTheme.danger : Colors.white24),
      const SizedBox(width: 3),
      Text(label,
          style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              color: isOld ? AppTheme.danger : Colors.white38,
              fontWeight:
                  isOld ? FontWeight.w600 : FontWeight.w400)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: Row(children: [
          const Icon(Icons.security, color: AppTheme.accent, size: 20),
          const SizedBox(width: 8),
          Text('SecCall',
              style: GoogleFonts.spaceGrotesk(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  letterSpacing: 1)),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: AppTheme.accent.withOpacity(0.3), width: 0.5),
            ),
            child: Text('Analista',
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    color: AppTheme.accent,
                    fontWeight: FontWeight.w500)),
          ),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt, color: Colors.white70),
            tooltip: 'Em andamento',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => InProgressScreen(user: widget.user)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white70),
            tooltip: 'Histórico',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white38),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Contador
          Container(
            width: double.infinity,
            color: AppTheme.surface,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(children: [
              const Icon(Icons.inbox_outlined,
                  color: AppTheme.accent, size: 16),
              const SizedBox(width: 8),
              Text('Incidentes pendentes',
                  style: GoogleFonts.spaceGrotesk(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.danger.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppTheme.danger.withOpacity(0.3),
                      width: 0.5),
                ),
                child: Text('${_filtered.length} abertos',
                    style: GoogleFonts.spaceGrotesk(
                        color: AppTheme.danger,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
              ),
            ]),
          ),

          // Chips de filtro
          Container(
            color: AppTheme.surface,
            padding:
                const EdgeInsets.only(left: 12, right: 12, bottom: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                _chip('Todos', null),
                ..._severities.map((s) => _chip(
                      AppTheme.severityLabel(s),
                      s,
                      color: AppTheme.severityColor(s),
                    )),
              ]),
            ),
          ),

          // Lista
          Expanded(
            child: _loading
                ? const Center(
                    child:
                        CircularProgressIndicator(color: AppTheme.accent))
                : _filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline,
                                color: AppTheme.success, size: 48),
                            const SizedBox(height: 12),
                            Text('Nenhum incidente pendente',
                                style: GoogleFonts.spaceGrotesk(
                                    color: Colors.white54)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: AppTheme.accent,
                        backgroundColor: AppTheme.card,
                        onRefresh: () async => _mom.startPolling(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) {
                            final inc = _filtered[i];
                            return GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => IncidentDetailScreen(
                                      incident: inc,
                                      user: widget.user,
                                    ),
                                  ),
                                );
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
                                child: Row(children: [
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
                                        color: AppTheme.severityColor(
                                                inc.severity)
                                            .withOpacity(0.3),
                                        width: 0.5,
                                      ),
                                    ),
                                    child: Icon(
                                        Icons.warning_amber_rounded,
                                        color: AppTheme.severityColor(
                                            inc.severity),
                                        size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(inc.title,
                                            style:
                                                GoogleFonts.spaceGrotesk(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                            maxLines: 1,
                                            overflow:
                                                TextOverflow.ellipsis),
                                        const SizedBox(height: 3),
                                        Text(
                                          'Reportado por: ${inc.reporterName}',
                                          style: GoogleFonts.spaceGrotesk(
                                              fontSize: 11,
                                              color: Colors.white38),
                                        ),
                                        const SizedBox(height: 3),
                                        _timeAgo(inc.createdAt), // ← tempo
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppTheme.severityColor(
                                              inc.severity)
                                          .withOpacity(0.12),
                                      borderRadius:
                                          BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppTheme.severityColor(
                                                inc.severity)
                                            .withOpacity(0.3),
                                        width: 0.5,
                                      ),
                                    ),
                                    child: Text(
                                      AppTheme.severityLabel(
                                          inc.severity),
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.severityColor(
                                            inc.severity),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.chevron_right,
                                      color: Colors.white24, size: 18),
                                ]),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}