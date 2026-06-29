import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MomService {
  final String baseUrl = 'http://localhost:5000/api';
  Timer? _timer;
  final StreamController<List<dynamic>> _controller =
      StreamController.broadcast();

  Stream<List<dynamic>> get stream => _controller.stream;

  void startPolling() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 8), (_) => _fetch());
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/incidents'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _controller.add(data['data'] as List);
      }
    } catch (_) {}
  }

  void stop() {
    _timer?.cancel();
    _controller.close();
  }
}