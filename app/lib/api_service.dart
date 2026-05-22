import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static String get _ip => dotenv.env['AGENT_IP'] ?? '';
  static String get _apiKey => dotenv.env['AGENT_API_KEY'] ?? '';

  static String get _baseUrl => 'http://$_ip:3000';

  static Future<Map<String, dynamic>?> fetchStatus() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/status?key=$_apiKey'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Błąd API: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Błąd połączenia: $e');
      return null;
    }
  }

  static Future<bool> sendCommand(String action, {String target = "", String value = ""}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/command?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': action,
          'target': target,
          'value': value,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Błąd wysyłania komendy: $e');
      return false;
    }
  }
}