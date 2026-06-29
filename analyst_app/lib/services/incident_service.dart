import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/incident.dart';

class IncidentService {
  final String baseUrl = 'http://localhost:5000/api';

  Future<List<Incident>> getIncidents() async {
    final response = await http.get(Uri.parse('$baseUrl/incidents'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['data'];
      return list.map((j) => Incident.fromJson(j)).toList();
    }
    throw Exception('Erro ao buscar incidentes');
  }

  Future<Incident> getIncidentById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/incidents/$id'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Incident.fromJson(data['data']);
    }
    throw Exception('Incidente não encontrado');
  }

  Future<Incident> updateStatus(
      int id, String status, String analystName, {String notes = ''}) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/incidents/$id/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'status': status,
        'analyst_name': analystName,
        'notes': notes,       // ← novo
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Incident.fromJson(data['data']);
    }
    throw Exception('Erro ao atualizar status');
  }
}