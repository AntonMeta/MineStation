import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'theme/app_theme.dart';
import 'api_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MineStationApp());
}

class MineStationApp extends StatelessWidget {
  const MineStationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MineStation',
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
  bool _isLoading = true;
  String _serverName = "Ładowanie...";
  String _status = "Brak danych";
  String _ramUsage = "0 MB";
  List<String> _players = [];

  @override
  void initState() {
    super.initState();
    _loadServerData();
  }

  Future<void> _loadServerData() async {
    setState(() => _isLoading = true);

    final data = await ApiService.fetchStatus();

    if (data != null) {
      setState(() {
        _serverName = data['serverName'] ?? "Nieznany";
        _status = data['status'] ?? "OFFLINE";
        _ramUsage = data['ramUsage'] ?? "0 MB";

        if (data['status'] == 'ONLINE' && data['details'] != null) {
          String details = data['details'];
          if (details.contains("online:")) {
            String playersStr = details.split("online:")[1].trim();
            if (playersStr.isNotEmpty) {
              _players = playersStr.split(",").map((e) => e.trim()).toList();
            } else {
              _players = [];
            }
          }
        }
      });
    } else {
      setState(() {
        _status = "BŁĄD POŁĄCZENIA";
        _players = [];
      });
    }

    setState(() => _isLoading = false);
  }

  Future<void> _executeCommand(String commandLabel, String action, {String target = ""}) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Wysyłanie: $commandLabel...'), duration: const Duration(seconds: 1)),
    );

    bool success = await ApiService.sendCommand(action, target: target);

    // ignore: use_build_context_synchronously
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Wykonano: $commandLabel!' : 'Błąd: $commandLabel!'),
        backgroundColor: success ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MINESTATION',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.primary),
            onPressed: _isLoading ? null : _loadServerData,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          _buildStatusCard(),
          const SizedBox(height: 16),
          _buildQuickActions(),
          const SizedBox(height: 16),
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
            Text("SYSTEM STATUS", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text("HOST: $_serverName", style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 4),
            Text(
              "STATUS: $_status",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: _status == 'ONLINE' ? Colors.greenAccent : Colors.redAccent,
              ),
            ),
            const SizedBox(height: 4),
            Text("RAM AGENTA: $_ramUsage", style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("SZYBKIE AKCJE", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildActionBtn("Dzień", Icons.wb_sunny, "day"),
                _buildActionBtn("Noc", Icons.nights_stay, "raw", target: "time set night"),
                _buildActionBtn("Czyste Niebo", Icons.cloud_off, "raw", target: "weather clear"),
                _buildActionBtn("Deszcz", Icons.water_drop, "raw", target: "weather rain"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBtn(String label, IconData icon, String action, {String target = ""}) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.accent.withValues(alpha: 0.1),
        foregroundColor: AppTheme.accent,
        side: const BorderSide(color: AppTheme.accent),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () => _executeCommand(label, action, target: target),
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildPlayerList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                "AKTYWNI GRACZE (${_players.length}/20)",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
              ),
            ),
            const Divider(color: AppTheme.textMuted),
            if (_players.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Brak graczy na serwerze.", style: TextStyle(color: AppTheme.textMuted)),
              ),
            ..._players.map((playerName) => ListTile(
              leading: const Icon(Icons.person, color: AppTheme.primary),
              title: Row(
            children: [
            Expanded(
            child: Text(
              playerName,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textMain),
              overflow: TextOverflow.ellipsis,
            ),
            ),
            const SizedBox(width: 8),
            _buildGamemodeBar(playerName),
          ],
        ),

          trailing: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: AppTheme.textMuted),
                color: AppTheme.background,
                onSelected: (String action) {
                  if (action == 'op') {
                    _executeCommand("OP ($playerName)", "op", target: playerName);
                  } else if (action == 'kick') {
                    _executeCommand("Kick ($playerName)", "raw", target: "kick $playerName");
                  } else if (action == 'ban') {
                    _executeCommand("Ban ($playerName)", "raw", target: "ban $playerName");
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(value: 'op', child: Text('✨ Nadaj status OP', style: TextStyle(color: Colors.white))),
                  const PopupMenuItem<String>(value: 'deop', child: Text('❌ Odbierz status OP', style: TextStyle(color: Colors.white))),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(value: 'kick', child: Text('👞 Kick', style: TextStyle(color: Colors.orange))),
                  const PopupMenuItem<String>(value: 'ban', child: Text('🔨 Ban', style: TextStyle(color: Colors.red))),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
  Widget _buildGamemodeBar(String playerName) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildGamemodeTab(playerName, "SURV", "survival"),
          Container(width: 1, height: 16, color: AppTheme.accent.withValues(alpha: 0.3)), // Pionowa kreska dzieląca
          _buildGamemodeTab(playerName, "CREA", "creative"),
          Container(width: 1, height: 16, color: AppTheme.accent.withValues(alpha: 0.3)), // Pionowa kreska dzieląca
          _buildGamemodeTab(playerName, "SPEC", "spectator"),
        ],
      ),
    );
  }

  // Pomocnicza zakładka (kafelek) wewnątrz paska trybów gry
  Widget _buildGamemodeTab(String playerName, String label, String gamemode) {
    return InkWell(
      onTap: () => _executeCommand(
          "Zmień tryb na $gamemode dla $playerName",
          "raw",
          target: "gamemode $gamemode $playerName"
      ),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppTheme.textMain,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}