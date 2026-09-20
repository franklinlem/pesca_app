import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pesca_app/core/services/pdf_report_service.dart';
import 'package:pesca_app/core/theme/app_theme.dart';
import 'package:pesca_app/core/widgets/catch_and_release_badge.dart';
import 'package:pesca_app/features/catches/models/catch_model.dart';
import 'package:pesca_app/features/catches/presentation/quick_catch_screen.dart';
import 'package:pesca_app/features/catches/providers/catch_provider.dart';
import 'package:pesca_app/features/sessions/models/fishing_session.dart';
import 'package:pesca_app/features/sessions/providers/session_provider.dart';
import 'package:pesca_app/features/weather/presentation/weather_modal.dart';

class SessionDetailScreen extends ConsumerWidget {
  final FishingSession session;

  const SessionDetailScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(sessionProvider);
    final currentSession = sessionState.allSessions.firstWhere(
      (s) => s.id == session.id,
      orElse: () => session,
    );

    final dateFormat = DateFormat('dd/MM/yyyy - HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text(currentSession.locationName ?? 'Detalhes da Pescaria'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded, color: AppTheme.warningOrange),
            tooltip: 'Exportar Relatório PDF',
            onPressed: () {
              PdfReportService.generateAndShowPdf(currentSession);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: currentSession.isActive ? AppTheme.cardBg : AppTheme.surfaceHeader,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: currentSession.isActive ? AppTheme.primaryGreen : Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          currentSession.isActive ? '⚡ EM ANDAMENTO' : 'CONCLUÍDA',
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      Text(
                        dateFormat.format(currentSession.startTime),
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currentSession.locationName ?? 'Local Não Especificado',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  if (currentSession.notes != null) ...[
                    const SizedBox(height: 6),
                    Text(currentSession.notes!, style: const TextStyle(color: AppTheme.textSecondary)),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatMiniCard(
                        title: 'Capturas',
                        value: '${currentSession.totalCatches}',
                        color: AppTheme.accentCyan,
                        icon: Icons.phishing_rounded,
                      ),
                      _StatMiniCard(
                        title: 'Soltos 🌿',
                        value: '${currentSession.totalReleased}',
                        color: AppTheme.primaryGreen,
                        icon: Icons.eco_rounded,
                      ),
                      _StatMiniCard(
                        title: 'Maior (cm)',
                        value: '${currentSession.maxLen.toInt()} cm',
                        color: AppTheme.warningOrange,
                        icon: Icons.emoji_events_rounded,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          Card(
            color: AppTheme.cardBg,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('🌤️ Condições Registradas',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      if (currentSession.isActive)
                        TextButton.icon(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (_) => WeatherModal(existing: currentSession.weather),
                            );
                          },
                          icon: const Icon(Icons.edit, size: 18),
                          label: Text(currentSession.weather == null ? 'Adicionar' : 'Editar'),
                        ),
                    ],
                  ),
                  if (currentSession.weather == null)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('Nenhuma condição registrada ainda.', style: TextStyle(color: AppTheme.textSecondary)),
                    )
                  else ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        _WeatherChip(icon: Icons.wb_sunny_rounded, label: 'Clima: ${currentSession.weather!.weather}'),
                        _WeatherChip(icon: Icons.air_rounded, label: 'Vento: ${currentSession.weather!.wind}'),
                        _WeatherChip(icon: Icons.water_drop_rounded, label: 'Água: ${currentSession.weather!.waterCondition}'),
                        if (currentSession.weather!.temperatureC != null)
                          _WeatherChip(icon: Icons.thermostat_rounded, label: '${currentSession.weather!.temperatureC}°C'),
                        if (currentSession.weather!.moonPhase != null)
                          _WeatherChip(icon: Icons.brightness_3_rounded, label: 'Lua ${currentSession.weather!.moonPhase}'),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          if (currentSession.isActive) ...[
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => QuickCatchScreen(sessionId: currentSession.id)),
                );
              },
              icon: const Icon(Icons.add_circle_outline_rounded, size: 28),
              label: const Text('REGISTRAR NOVA CAPTURA'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent)),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Finalizar Pescaria?'),
                    content: const Text('Deseja encerrar o registro desta sessão de pesca?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Continuar')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                        onPressed: () {
                          Navigator.pop(ctx);
                          ref.read(sessionProvider.notifier).endActiveSession();
                        },
                        child: const Text('ENCERRAR'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.stop_circle_outlined, color: Colors.redAccent),
              label: const Text('Encerrar Pescaria', style: TextStyle(color: Colors.redAccent)),
            ),
            const SizedBox(height: 24),
          ],

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Peixes Fisgados (${currentSession.totalCatches})',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (currentSession.catches.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: const Column(
                children: [
                  Icon(Icons.phishing_rounded, size: 48, color: AppTheme.textSecondary),
                  SizedBox(height: 8),
                  Text('Nenhum peixe registrado nesta sessão.', style: TextStyle(color: AppTheme.textSecondary)),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: currentSession.catches.length,
              itemBuilder: (context, index) {
                final item = currentSession.catches[index];
                return _CatchCard(catchModel: item);
              },
            ),
        ],
      ),
    );
  }
}

class _StatMiniCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatMiniCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(title, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
      ],
    );
  }
}

class _WeatherChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _WeatherChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16, color: AppTheme.accentCyan),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: AppTheme.surfaceHeader,
    );
  }
}

class _CatchCard extends ConsumerWidget {
  final CatchModel catchModel;

  const _CatchCard({required this.catchModel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: catchModel.photoPath != null && File(catchModel.photoPath!).existsSync()
                  ? Image.file(File(catchModel.photoPath!), width: 70, height: 70, fit: BoxFit.cover)
                  : Container(
                      width: 70,
                      height: 70,
                      color: AppTheme.surfaceHeader,
                      child: const Icon(Icons.phishing, color: AppTheme.primaryGreen, size: 36),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(catchModel.species, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      CatchAndReleaseBadge(isReleased: catchModel.isReleased),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${catchModel.lengthCm} cm ${catchModel.weightKg != null ? "• ${catchModel.weightKg} kg" : ""}',
                    style: const TextStyle(color: AppTheme.warningOrange, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  if (catchModel.baitUsed != null) ...[
                    const SizedBox(height: 2),
                    Text('Isca: ${catchModel.baitUsed}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                  Text(
                    DateFormat('HH:mm').format(catchModel.timestamp),
                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
              onPressed: () {
                ref.read(catchProvider.notifier).deleteCatch(catchModel.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
