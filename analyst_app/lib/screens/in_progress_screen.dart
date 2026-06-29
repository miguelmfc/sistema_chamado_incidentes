import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/incident.dart';
import '../models/user.dart';
import '../services/incident_service.dart';
import '../services/mom_service.dart';
import '../utils/app_theme.dart';

class InProgressScreen extends StatefulWidget {
  final User user;
  const InProgressScreen({super.key, required this.user});

  @override
  State<InProgressScreen> createState() => _InProgressScreenState();
}

class _InProgressScreenState extends State<InProgressScreen> {
  final MomService _mom = MomService();
  final IncidentService _service = IncidentService();
  List<Incident> _inProgress = [];
  bool _loading = true;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _mom.startPolling();
    _sub = _mom.stream.listen((list) {
      setState(() {
        _inProgress = list
            .map((j) => Incident.fromJson(j))
            .where((i) =>
                i.status == 'in_progress' &&
                i.analystName == widget.user.name)
            .toList();
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

  Future<void> _resolve(int id) async {
    try {
      await _service.updateStatus(id, 'resolved', widget.user.name);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Incidente resolvido!',
              style: GoogleFonts.spaceGrotesk()),
          backgroundColor: AppTheme.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao resolver.',
              style: GoogleFonts.spaceGrotesk()),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
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
        title: Text('Em andamento',
            style: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16)),
      ),
      body: _loading
          ? const Center(
              child:
                  CircularProgressIndicator(color: AppTheme.accent))
          : _inProgress.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined,
                          color: Colors.white24, size: 48),
                      const SizedBox(height: 12),
                      Text('Nenhum incidente em andamento',
                          style: GoogleFonts.spaceGrotesk(
                              color: Colors.white38)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _inProgress.length,
                  itemBuilder: (_, i) {
                    final inc = _inProgress[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppTheme.warning.withOpacity(0.2),
                            width: 0.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(inc.title,
                                    style: GoogleFonts.spaceGrotesk(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.warning.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text('Em andamento',
                                    style: GoogleFonts.spaceGrotesk(
                                        fontSize: 11,
                                        color: AppTheme.warning,
                                        fontWeight: FontWeight.w500)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Reportado por: ${inc.reporterName}',
                              style: GoogleFonts.spaceGrotesk(
                                  fontSize: 12, color: Colors.white38)),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 40,
                            child: ElevatedButton.icon(
                              onPressed: () => _resolve(inc.id),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    AppTheme.success.withOpacity(0.15),
                                foregroundColor: AppTheme.success,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(8)),
                                side: BorderSide(
                                    color:
                                        AppTheme.success.withOpacity(0.3),
                                    width: 0.5),
                              ),
                              icon: const Icon(Icons.check, size: 16),
                              label: Text('Marcar como resolvido',
                                  style: GoogleFonts.spaceGrotesk(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500)),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}