import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'theme/app_theme.dart';

void main() => runApp(const MineStationApp());

class MineStationApp extends StatelessWidget {
  const MineStationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MineStation',
      // TUTAJ PODPINASZ SWÓJ MOTYW:
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Mock data
  final String _serverName = "MACBOOK-AIR";
  final String _status = "Online";
  final List<String> _players = ["Steve", "Alex", "Ziemniak"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MINESTATION'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          _buildStatusCard(),
          _buildQuickActions(),
          _buildPlayerList(),
        ],
      ),
    );
  }


  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "SYSTEM STATUS",

              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              "HOST: $_serverName",

              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 4),
            Text(
              "STATUS: $_status",

              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent.withValues(alpha: 0.2),
                foregroundColor: AppTheme.accent,
                side: const BorderSide(color: AppTheme.accent),
              ),
              onPressed: () {},
              child: const Text("STOP SERVER"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerList() {
    return Card(
      child: Column(
        children: _players.map((p) => ListTile(
          leading: const Icon(Icons.person, color: AppTheme.primary),
          title: Text(p, style: const TextStyle(fontWeight: FontWeight.bold)),
          trailing: const Icon(Icons.more_vert, color: AppTheme.textMuted),
        )).toList(),
      ),
    );
  }
}