import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pesca_app/core/theme/app_theme.dart';
import 'package:pesca_app/features/sessions/providers/session_provider.dart';
import 'package:pesca_app/features/weather/models/weather_condition.dart';

class WeatherModal extends ConsumerStatefulWidget {
  final WeatherCondition? existing;

  const WeatherModal({super.key, this.existing});

  @override
  ConsumerState<WeatherModal> createState() => _WeatherModalState();
}

class _WeatherModalState extends ConsumerState<WeatherModal> {
  String _weather = 'Ensolarado';
  String _wind = 'Fraco';
  String _water = 'Limpa';
  String _moon = 'Crescente';
  final _tempController = TextEditingController(text: '28');

  final List<String> _weathers = ['Ensolarado', 'Nublado', 'Chuvoso', 'Tempestade', 'Com Neblina'];
  final List<String> _winds = ['Sem Vento', 'Fraco', 'Moderado', 'Forte', 'Vendaval'];
  final List<String> _waters = ['Limpa', 'Turva', 'Barrenta', 'Salobra', 'Agitada', 'Espelhada'];
  final List<String> _moons = ['Nova', 'Crescente', 'Cheia', 'Minguante'];

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _weather = widget.existing!.weather;
      _wind = widget.existing!.wind;
      _water = widget.existing!.waterCondition;
      if (widget.existing!.moonPhase != null) _moon = widget.existing!.moonPhase!;
      if (widget.existing!.temperatureC != null) {
        _tempController.text = widget.existing!.temperatureC.toString();
      }
    }
  }

  void _save() async {
    final temp = double.tryParse(_tempController.text.replaceAll(',', '.'));
    final condition = WeatherCondition(
      weather: _weather,
      wind: _wind,
      waterCondition: _water,
      temperatureC: temp,
      moonPhase: _moon,
    );

    await ref.read(sessionProvider.notifier).saveWeatherForActiveSession(condition);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🌤️ Condições climáticas registradas!'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('🌤️ Condições Ambientais',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),

            const Text('Clima / Tempo:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: _weathers.map((w) {
                final isSelected = _weather == w;
                return ChoiceChip(
                  label: Text(w),
                  selected: isSelected,
                  selectedColor: AppTheme.accentCyan,
                  onSelected: (val) {
                    if (val) setState(() => _weather = w);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            const Text('Vento:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: _winds.map((w) {
                final isSelected = _wind == w;
                return ChoiceChip(
                  label: Text(w),
                  selected: isSelected,
                  selectedColor: AppTheme.primaryGreen,
                  onSelected: (val) {
                    if (val) setState(() => _wind = w);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            const Text('Condição da Água:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: _waters.map((w) {
                final isSelected = _water == w;
                return ChoiceChip(
                  label: Text(w),
                  selected: isSelected,
                  selectedColor: AppTheme.warningOrange,
                  onSelected: (val) {
                    if (val) setState(() => _water = w);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Fase da Lua:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        initialValue: _moon,
                        items: _moons.map((m) => DropdownMenuItem(value: m, child: Text('🌙 Lua $m'))).toList(),
                        onChanged: (val) => setState(() => _moon = val!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Temperatura (°C):', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _tempController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(suffixText: '°C'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_rounded),
              label: const Text('SALVAR CONDIÇÕES'),
            ),
          ],
        ),
      ),
    );
  }
}
