import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MaterialApp(home: MineDroidHome()));

class MineDroidHome extends StatefulWidget {
  const MineDroidHome({super.key});

  @override
  State<MineDroidHome> createState() => _MineDroidHomeState();
}

class _MineDroidHomeState extends State<MineDroidHome> {
  String _status = "Kliknij, aby sprawdzić agenta";

  Future<void> fetchStatus() async {
    try {
      // Jeśli odpalasz na Macu i Agent jest na Macu, użyj localhost
      final response = await http.get(Uri.parse('http://localhost:3000/status'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() => _status = "Serwer: ${data['serverName']}\nStatus: ${data['status']}");
      }
    } catch (e) {
      setState(() => _status = "Błąd połączenia: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MineDroid Controller')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_status, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: fetchStatus, child: const Text('Sprawdź Agenta')),
          ],
        ),
      ),
    );
  }
}