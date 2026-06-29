import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/incident.dart';
import '../services/mom_service.dart';
import '../utils/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final MomService _mom = MomService();
  List<Incident> _resolved = [];
  bool _loading = true;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _mom.startPolling();
    _sub = _mom.stream.listen((list) {
      setState(() {
        _resolved = list
            .map((j) => Incident.fromJson(j))
            .where((i) => i.status == 'resolved' || i.status == 'closed')
            .toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
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
        title: Text('Histórico',
            style: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppTheme.success.withOpacity(0.3), width: 0.5),
                ),
                child: Text('${_resolved.length} resolvidos',
                    style: GoogleFonts.spaceGrotesk(
                        color: AppTheme.success,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.accent))
          : _resolved.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history,
                          color: Colors.white24, size: 48),
                      const SizedBox(height: 12),
                      Text('Nenhum incidente resolvido ainda',
                          style: GoogleFonts.spaceGrotesk(
                              color: Colors.white38)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _resolved.length,
                  itemBuilder: (_, i) {
                    final inc = _resolved[i];
                    final isClosed = inc.status == 'closed';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isClosed
                              ? AppTheme.danger.withOpacity(0.2)
                              : AppTheme.success.withOpacity(0.2),
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Expanded(
                              child: Text(inc.title,
                                  style: GoogleFonts.spaceGrotesk(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: (isClosed
                                        ? AppTheme.danger
                                        : AppTheme.success)
                                    .withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                  isClosed ? 'Recusado' : 'Resolvido',
                                  style: GoogleFonts.spaceGrotesk(
                                      fontSize: 11,
                                      color: isClosed
                                          ? AppTheme.danger
                                          : AppTheme.success,
                                      fontWeight: FontWeight.w500)),
                            ),
                          ]),
                          const SizedBox(height: 6),
                          Text('Reportado por: ${inc.reporterName}',
                              style: GoogleFonts.spaceGrotesk(
                                  fontSize: 12, color: Colors.white38)),
                          if (inc.analystName != null) ...[
                            const SizedBox(height: 2),
                            Text('Analista: ${inc.analystName}',
                                style: GoogleFonts.spaceGrotesk(
                                    fontSize: 12, color: Colors.white38)),
                          ],
                          if (inc.notes != null && inc.notes!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.accent.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: AppTheme.accent.withOpacity(0.15),
                                    width: 0.5),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.comment_outlined,
                                      size: 12,
                                      color: AppTheme.accent.withOpacity(0.6)),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(inc.notes!,
                                        style: GoogleFonts.spaceGrotesk(
                                            fontSize: 12,
                                            color: Colors.white54)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 6),
                          Text('Encerrado em: ${inc.updatedAt}',
                              style: GoogleFonts.spaceGrotesk(
                                  fontSize: 11, color: Colors.white24)),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}