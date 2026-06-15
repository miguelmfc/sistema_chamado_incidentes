import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/incident.dart';

class IncidentService {
  final String baseUrl = 'http://10.0.2.2:5000/api';

  Future<List<Incident>> getIncidents() async {
    final response = await http.get(Uri.parse('$baseUrl/incidents'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['data'];
      return list.map((json) => Incident.fromJson(json)).toList();
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

  Future<Incident> createIncident({
    required String title,
    required String description,
    required String severity,
    required String reporterName,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/incidents'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'description': description,
        'severity': severity,
        'reporter_name': reporterName,
      }),
    );
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Incident.fromJson(data['data']);
    }
    throw Exception('Erro ao criar incidente');
  }
}