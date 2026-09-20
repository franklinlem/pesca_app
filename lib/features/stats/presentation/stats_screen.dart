import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pesca_app/core/theme/app_theme.dart';
import 'package:pesca_app/core/widgets/pro_badge.dart';
import 'package:pesca_app/features/catches/providers/catch_provider.dart';
import 'package:pesca_app/features/settings/providers/user_pro_provider.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catches = ref.watch(catchProvider);
    final isPro = ref.watch(userProProvider);

    final totalCatches = catches.length;
    final totalReleased = catches.where((c) => c.isReleased).length;
    final releasePercentage = totalCatches > 0 ? (totalReleased / totalCatches * 100).toStringAsFixed(1) : '0';

    final Map<String, int> speciesMap = {};
    for (var c in catches) {
      speciesMap[c.species] = (speciesMap[c.species] ?? 0) + 1;
    }

    final Map<String, int> baitMap = {};
    for (var c in catches) {
      if (c.baitUsed != null && c.baitUsed!.isNotEmpty) {
        baitMap[c.baitUsed!] = (baitMap[c.baitUsed!] ?? 0) + 1;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Estatísticas Pessoais'),
      ),
      body: catches.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart_rounded, size: 64, color: AppTheme.textSecondary),
                  SizedBox(height: 12),
                  Text('Nenhuma captura registrada para gerar estatísticas.',
                      style: TextStyle(color: AppTheme.textSecondary)),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        title: 'Total de Peixes',
                        value: '$totalCatches',
                        icon: Icons.phishing,
                        color: AppTheme.accentCyan,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Pesque & Solte',
                        value: '$releasePercentage%',
                        subtitle: '$totalReleased soltos com vida 🌿',
                        icon: Icons.eco_rounded,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🐟 Espécies Mais Fisgadas',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 180,
                          child: PieChart(
                            PieChartData(
                              sections: _generatePieSections(speciesMap),
                              sectionsSpace: 3,
                              centerSpaceRadius: 40,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 6,
                          children: speciesMap.entries.map((e) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: _getColorForIndex(speciesMap.keys.toList().indexOf(e.key)),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text('${e.key} (${e.value})', style: const TextStyle(fontSize: 12)),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Card(
                  color: isPro ? AppTheme.cardBg : AppTheme.surfaceHeader.withValues(alpha: 0.5),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('🎯 Iscas Mais Eficientes',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            if (!isPro) const ProBadge(isCompact: true),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (!isPro) ...[
                          const Text(
                            'Desbloqueie o Diário de Pesca PRO para ver análises avançadas de iscas mais produtivas, melhores horários de briga e ranking por período!',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              ref.read(userProProvider.notifier).setProStatus(true);
                            },
                            child: const Text('DESBLOQUEAR ESTATÍSTICAS PRO'),
                          ),
                        ] else ...[
                          if (baitMap.isEmpty)
                            const Text('Nenhuma isca registrada nas capturas.',
                                style: TextStyle(color: AppTheme.textSecondary))
                          else
                            ...baitMap.entries.map((e) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.accentCyan.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text('${e.value} peixe(s)',
                                          style: const TextStyle(
                                              color: AppTheme.accentCyan, fontWeight: FontWeight.bold, fontSize: 12)),
                                    ),
                                  ],
                                ),
                              );
                            }),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  List<PieChartSectionData> _generatePieSections(Map<String, int> data) {
    int total = data.values.fold(0, (a, b) => a + b);
    int index = 0;
    return data.entries.map((e) {
      final percentage = (e.value / total * 100);
      final color = _getColorForIndex(index++);
      return PieChartSectionData(
        color: color,
        value: e.value.toDouble(),
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 45,
        titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 12),
      );
    }).toList();
  }

  Color _getColorForIndex(int index) {
    final colors = [
      AppTheme.primaryGreen,
      AppTheme.accentCyan,
      AppTheme.warningOrange,
      AppTheme.highVisYellow,
      Colors.purpleAccent,
      Colors.pinkAccent,
    ];
    return colors[index % colors.length];
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                Icon(icon, color: color, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color)),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
            ],
          ],
        ),
      ),
    );
  }
}
