import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MomService {
  final String baseUrl = 'http://localhost:5000/api';
  Timer? _pollingTimer;
  final StreamController<Map<String, dynamic>> _eventController =
      StreamController.broadcast();

  Stream<Map<String, dynamic>> get events => _eventController.stream;

  void startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 8),
      (_) => _fetchLatestEvent(),
    );
  }

  Future<void> _fetchLatestEvent() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/incidents'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _eventController.add({
          'type': 'incidents_updated',
          'data': data['data'],
        });
      }
    } catch (_) {}
  }

  void stop() {
    _pollingTimer?.cancel();
    _eventController.close();
  }
}