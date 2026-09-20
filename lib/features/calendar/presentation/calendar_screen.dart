import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:pesca_app/core/theme/app_theme.dart';
import 'package:pesca_app/features/sessions/models/fishing_session.dart';
import 'package:pesca_app/features/sessions/presentation/session_detail_screen.dart';
import 'package:pesca_app/features/sessions/providers/session_provider.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionProvider);
    final sessions = sessionState.allSessions;

    List<FishingSession> getEventsForDay(DateTime day) {
      return sessions.where((s) {
        return isSameDay(s.startTime, day);
      }).toList();
    }

    final selectedDayEvents = _selectedDay != null ? getEventsForDay(_selectedDay!) : [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('📅 Calendário de Pescarias'),
      ),
      body: Column(
        children: [
          TableCalendar<FishingSession>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: getEventsForDay,
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: AppTheme.accentCyan.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: AppTheme.primaryGreen,
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: AppTheme.warningOrange,
                shape: BoxShape.circle,
              ),
            ),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
          ),
          const Divider(),

          Expanded(
            child: selectedDayEvents.isEmpty
                ? const Center(
                    child: Text('Nenhuma pescaria realizada nesta data.',
                        style: TextStyle(color: AppTheme.textSecondary)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: selectedDayEvents.length,
                    itemBuilder: (context, index) {
                      final item = selectedDayEvents[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: item.isActive ? AppTheme.primaryGreen : AppTheme.surfaceHeader,
                            child: Icon(
                              Icons.phishing,
                              color: item.isActive ? Colors.black : Colors.white,
                            ),
                          ),
                          title: Text(item.locationName ?? 'Local Não Especificado',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            '${item.totalCatches} peixe(s) fisgado(s) • ${item.totalReleased} solto(s)',
                            style: const TextStyle(color: AppTheme.textSecondary),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => SessionDetailScreen(session: item)),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
