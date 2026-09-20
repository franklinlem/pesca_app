import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pesca_app/core/theme/app_theme.dart';
import 'package:pesca_app/features/calendar/presentation/calendar_screen.dart';
import 'package:pesca_app/features/catches/presentation/quick_catch_screen.dart';
import 'package:pesca_app/features/equipment/presentation/equipment_screen.dart';
import 'package:pesca_app/features/map/presentation/map_screen.dart';
import 'package:pesca_app/features/sessions/presentation/session_detail_screen.dart';
import 'package:pesca_app/features/sessions/presentation/start_session_screen.dart';
import 'package:pesca_app/features/sessions/providers/session_provider.dart';
import 'package:pesca_app/features/settings/presentation/settings_screen.dart';
import 'package:pesca_app/features/stats/presentation/stats_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _DashboardTab(),
    EquipmentScreen(),
    MapScreen(),
    CalendarScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.cardBg,
        selectedItemColor: AppTheme.primaryGreen,
        unselectedItemColor: AppTheme.textSecondary,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_rounded), label: 'Equipamentos'),
          BottomNavigationBarItem(icon: Icon(Icons.map_rounded), label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Calendário'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Ajustes'),
        ],
      ),
    );
  }
}

class _DashboardTab extends ConsumerWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(sessionProvider);
    final activeSession = sessionState.activeSession;
    final pastSessions = sessionState.allSessions.where((s) => !s.isActive).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎣 Diário de Pesca'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded, color: AppTheme.accentCyan),
            tooltip: 'Estatísticas',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const StatsScreen()));
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(sessionProvider.notifier).loadSessions();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (activeSession != null)
              Card(
                color: AppTheme.cardBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: const BorderSide(color: AppTheme.primaryGreen, width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.flash_on, size: 14, color: Colors.black),
                                SizedBox(width: 4),
                                Text('PESCARIA EM ANDAMENTO',
                                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                              ],
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => SessionDetailScreen(session: activeSession)),
                              );
                            },
                            icon: const Icon(Icons.open_in_new, size: 16, color: AppTheme.accentCyan),
                            label: const Text('Ver Detalhes', style: TextStyle(color: AppTheme.accentCyan)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        activeSession.locationName ?? 'Local Não Especificado',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.phishing_rounded, color: AppTheme.accentCyan, size: 18),
                          const SizedBox(width: 6),
                          Text('${activeSession.totalCatches} peixe(s) fisgado(s)',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(width: 16),
                          const Icon(Icons.eco_rounded, color: AppTheme.primaryGreen, size: 18),
                          const SizedBox(width: 6),
                          Text('${activeSession.totalReleased} solto(s)',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryGreen)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => QuickCatchScreen(sessionId: activeSession.id)),
                          );
                        },
                        icon: const Icon(Icons.add_circle_outline_rounded, size: 28),
                        label: const Text('REGISTRAR CAPTURA RÁPIDA'),
                      ),
                    ],
                  ),
                ),
              )
            else
              Card(
                color: AppTheme.surfaceHeader,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(Icons.phishing_rounded, size: 54, color: AppTheme.primaryGreen),
                      const SizedBox(height: 12),
                      const Text('Nenhuma pescaria em andamento.',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      const Text('Inicie um novo registro para guardar capturas e coordenadas offline.',
                          textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const StartSessionScreen()),
                          );
                        },
                        icon: const Icon(Icons.play_arrow_rounded, size: 28),
                        label: const Text('INICIAR PESCARIA'),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('📜 Histórico de Pescarias', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),

            if (pastSessions.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                child: const Column(
                  children: [
                    Icon(Icons.history_toggle_off_rounded, size: 44, color: AppTheme.textSecondary),
                    SizedBox(height: 8),
                    Text('Nenhuma pescaria concluída no histórico.', style: TextStyle(color: AppTheme.textSecondary)),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pastSessions.length,
                itemBuilder: (context, index) {
                  final session = pastSessions[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppTheme.cardBg,
                        child: Icon(Icons.check_circle_rounded, color: AppTheme.primaryGreen),
                      ),
                      title: Text(session.locationName ?? 'Local Não Especificado',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        '${session.totalCatches} peixe(s) • ${session.totalReleased} solto(s) 🌿',
                        style: const TextStyle(color: AppTheme.textSecondary),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SessionDetailScreen(session: session)),
                        );
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
