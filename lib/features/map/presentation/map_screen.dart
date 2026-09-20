import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:pesca_app/core/theme/app_theme.dart';
import 'package:pesca_app/core/widgets/pro_badge.dart';
import 'package:pesca_app/features/catches/providers/catch_provider.dart';
import 'package:pesca_app/features/sessions/providers/session_provider.dart';
import 'package:pesca_app/features/settings/providers/user_pro_provider.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catches = ref.watch(catchProvider);
    final sessions = ref.watch(sessionProvider).allSessions;
    final isPro = ref.watch(userProProvider);

    final List<Marker> markers = [];
    LatLng initialCenter = const LatLng(-13.0, -50.0);

    for (var s in sessions) {
      if (s.latitude != null && s.longitude != null) {
        initialCenter = LatLng(s.latitude!, s.longitude!);
        markers.add(
          Marker(
            point: LatLng(s.latitude!, s.longitude!),
            width: 44,
            height: 44,
            child: GestureDetector(
              onTap: () {
                _showSpotDetails(context, s.locationName ?? 'Pescaria', 'Ponto de Partida', s.totalCatches);
              },
              child: const Icon(Icons.location_on, color: AppTheme.primaryGreen, size: 40),
            ),
          ),
        );
      }
    }

    for (var c in catches) {
      if (c.latitude != null && c.longitude != null) {
        initialCenter = LatLng(c.latitude!, c.longitude!);
        markers.add(
          Marker(
            point: LatLng(c.latitude!, c.longitude!),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () {
                _showSpotDetails(context, c.species, '${c.lengthCm} cm (${c.baitUsed ?? "Isca N/I"})', 1);
              },
              child: const Icon(Icons.phishing, color: AppTheme.warningOrange, size: 32),
            ),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('🗺️ Mapa de Pontos de Pesca'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryGreen),
            ),
            child: Row(
              children: const [
                Icon(Icons.lock, size: 14, color: AppTheme.primaryGreen),
                SizedBox(width: 4),
                Text('PRIVADO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: 6.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.diariodepesca.pesca_app',
              ),
              MarkerLayer(markers: markers),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Card(
              color: AppTheme.darkBg.withValues(alpha: 0.9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.shield_outlined, color: AppTheme.primaryGreen, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Coordenadas 100% Salvas no Aparelho',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Seus pontos de pesca nunca são enviados para servidores nem compartilhados publicamente.',
                      style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                    ),
                    if (!isPro) ...[
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              ProBadge(isCompact: true),
                              SizedBox(width: 6),
                              Text('Mapas Offline com Cache', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              ref.read(userProProvider.notifier).setProStatus(true);
                            },
                            child: const Text('Ativar PRO'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSpotDetails(BuildContext context, String title, String subtitle, int catchesCount) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.place, color: AppTheme.primaryGreen, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(10)),
              child: const Row(
                children: [
                  Icon(Icons.lock_clock, color: AppTheme.accentCyan, size: 18),
                  SizedBox(width: 8),
                  Text('Ponto privado mantido em armazenamento SQLite local.', style: TextStyle(fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
