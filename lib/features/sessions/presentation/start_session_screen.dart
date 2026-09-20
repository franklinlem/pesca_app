import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pesca_app/core/theme/app_theme.dart';
import 'package:pesca_app/features/sessions/providers/session_provider.dart';

class StartSessionScreen extends ConsumerStatefulWidget {
  const StartSessionScreen({super.key});

  @override
  ConsumerState<StartSessionScreen> createState() => _StartSessionScreenState();
}

class _StartSessionScreenState extends ConsumerState<StartSessionScreen> {
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  double? _latitude;
  double? _longitude;
  bool _gettingGps = false;

  Future<void> _fetchGps() async {
    setState(() => _gettingGps = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 8),
          ),
        );
        setState(() {
          _latitude = pos.latitude;
          _longitude = pos.longitude;
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _gettingGps = false);
    }
  }

  void _start() async {
    final locationName = _locationController.text.trim();
    await ref.read(sessionProvider.notifier).startSession(
          locationName: locationName.isNotEmpty ? locationName : 'Pescaria Sem Nome',
          latitude: _latitude,
          longitude: _longitude,
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎣 Pescaria Iniciada! Boa sorte no rio!'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🚀 Iniciar Nova Pescaria'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.phishing_rounded, size: 64, color: AppTheme.primaryGreen),
            const SizedBox(height: 12),
            const Text(
              'Pronto para molhar a linha?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'O aplicativo funcionará 100% offline. Você poderá registrar capturas, equipamentos e tempo a qualquer momento.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 28),

            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Nome do Local / Rio / Represa',
                hintText: 'Ex: Rio Araguaia, Represa de Furnas',
                prefixIcon: Icon(Icons.water_rounded, color: AppTheme.accentCyan),
              ),
            ),
            const SizedBox(height: 16),

            Card(
              color: AppTheme.cardBg,
              child: ListTile(
                leading: Icon(
                  _latitude != null ? Icons.my_location : Icons.location_on_outlined,
                  color: _latitude != null ? AppTheme.primaryGreen : AppTheme.textSecondary,
                ),
                title: Text(
                  _latitude != null ? 'Ponto de Partida Salvo 🔒' : 'Registrar Ponto GPS Inicial',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  _latitude != null
                      ? 'Lat: ${_latitude!.toStringAsFixed(4)}, Long: ${_longitude!.toStringAsFixed(4)}'
                      : 'Privado. Não será publicado.',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: _gettingGps
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : IconButton(
                        icon: const Icon(Icons.gps_fixed, color: AppTheme.primaryGreen),
                        onPressed: _fetchGps,
                      ),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Notas Iniciais / Objetivos',
                hintText: 'Ex: Pescaria de Tucunarés com isca de superfície...',
              ),
            ),
            const SizedBox(height: 32),

            ElevatedButton.icon(
              onPressed: _start,
              icon: const Icon(Icons.play_arrow_rounded, size: 28),
              label: const Text('INICIAR AGORA'),
            ),
          ],
        ),
      ),
    );
  }
}
