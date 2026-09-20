import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pesca_app/core/theme/app_theme.dart';
import 'package:pesca_app/core/widgets/catch_and_release_badge.dart';
import 'package:pesca_app/features/catches/providers/catch_provider.dart';
import 'package:pesca_app/features/equipment/providers/equipment_provider.dart';
import 'package:pesca_app/features/sessions/providers/session_provider.dart';

class QuickCatchScreen extends ConsumerStatefulWidget {
  final String? sessionId;

  const QuickCatchScreen({super.key, this.sessionId});

  @override
  ConsumerState<QuickCatchScreen> createState() => _QuickCatchScreenState();
}

class _QuickCatchScreenState extends ConsumerState<QuickCatchScreen> {
  final _formKey = GlobalKey<FormState>();

  String _selectedSpecies = 'Tucunaré';
  final _customSpeciesController = TextEditingController();
  final _lengthController = TextEditingController(text: '35');
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();
  final _baitController = TextEditingController();
  final _techniqueController = TextEditingController(text: 'Isca Artificial / Pincho');

  bool _isReleased = true;
  File? _imageFile;
  double? _latitude;
  double? _longitude;
  bool _fetchingLocation = false;
  String? _selectedEquipmentId;

  final List<String> _popularSpecies = [
    'Tucunaré',
    'Robalo',
    'Dourado',
    'Traíra',
    'Tambaqui',
    'Pintado',
    'Tucunaré-Açú',
    'Bicuda',
    'Black Bass',
    'Outro',
  ];

  final ImagePicker _picker = ImagePicker();

  Future<void> _takePhoto(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<void> _captureLocation() async {
    setState(() => _fetchingLocation = true);
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('📍 Coordenada capturada e mantida estritamente PRIVADA localmente!'),
              backgroundColor: AppTheme.primaryGreen,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível obter a localização atual.')),
        );
      }
    } finally {
      if (mounted) setState(() => _fetchingLocation = false);
    }
  }

  void _submitCatch() async {
    if (!_formKey.currentState!.validate()) return;

    final sessionState = ref.read(sessionProvider);
    final targetSessionId = widget.sessionId ?? sessionState.activeSession?.id;

    if (targetSessionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhuma pescaria ativa! Inicie uma pescaria primeiro.')),
      );
      return;
    }

    final speciesName = _selectedSpecies == 'Outro'
        ? (_customSpeciesController.text.isEmpty ? 'Peixe N/Identificado' : _customSpeciesController.text)
        : _selectedSpecies;

    final length = double.tryParse(_lengthController.text.replaceAll(',', '.')) ?? 0.0;
    final weight = double.tryParse(_weightController.text.replaceAll(',', '.'));

    await ref.read(catchProvider.notifier).addCatch(
          sessionId: targetSessionId,
          species: speciesName,
          lengthCm: length,
          weightKg: weight,
          baitUsed: _baitController.text.isNotEmpty ? _baitController.text : null,
          technique: _techniqueController.text.isNotEmpty ? _techniqueController.text : null,
          isReleased: _isReleased,
          photoPath: _imageFile?.path,
          latitude: _latitude,
          longitude: _longitude,
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
          equipmentId: _selectedEquipmentId,
        );

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🏆 $speciesName registrado com sucesso!'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final equipments = ref.watch(equipmentProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('⚡ Cadastro Rápido de Captura'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.camera_alt, color: AppTheme.primaryGreen, size: 28),
                            title: const Text('Tirar Foto Agora', style: TextStyle(fontWeight: FontWeight.bold)),
                            onTap: () {
                              Navigator.pop(context);
                              _takePhoto(ImageSource.camera);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.photo_library, color: AppTheme.accentCyan, size: 28),
                            title: const Text('Escolher da Galeria', style: TextStyle(fontWeight: FontWeight.bold)),
                            onTap: () {
                              Navigator.pop(context);
                              _takePhoto(ImageSource.gallery);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primaryGreen, width: 2),
                    image: _imageFile != null
                        ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: _imageFile == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.add_a_photo_rounded, size: 48, color: AppTheme.primaryGreen),
                            SizedBox(height: 8),
                            Text('Toque para Adicionar Foto do Peixe',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        )
                      : Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.7), shape: BoxShape.circle),
                            child: const Icon(Icons.edit, color: Colors.white, size: 20),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              Card(
                color: _isReleased ? AppTheme.primaryGreen.withValues(alpha: 0.15) : Colors.redAccent.withValues(alpha: 0.15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: _isReleased ? AppTheme.primaryGreen : Colors.redAccent,
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: SwitchListTile(
                    activeThumbColor: AppTheme.primaryGreen,
                    title: Row(
                      children: [
                        CatchAndReleaseBadge(isReleased: _isReleased, isLarge: true),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _isReleased
                            ? 'Peixe devolvido com vida para a água! 🌿'
                            : 'Peixe retido.',
                        style: TextStyle(
                          color: _isReleased ? AppTheme.primaryGreen : Colors.redAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    value: _isReleased,
                    onChanged: (val) => setState(() => _isReleased = val),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text('Espécie Fisgada:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _popularSpecies.map((species) {
                  final isSelected = _selectedSpecies == species;
                  return ChoiceChip(
                    label: Text(species, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.black : Colors.white)),
                    selected: isSelected,
                    selectedColor: AppTheme.primaryGreen,
                    backgroundColor: AppTheme.cardBg,
                    onSelected: (val) {
                      if (val) setState(() => _selectedSpecies = species);
                    },
                  );
                }).toList(),
              ),
              if (_selectedSpecies == 'Outro') ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _customSpeciesController,
                  decoration: const InputDecoration(labelText: 'Nome da Espécie'),
                ),
              ],
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _lengthController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Comprimento (cm)*',
                        suffixText: 'cm',
                        prefixIcon: Icon(Icons.straighten, color: AppTheme.primaryGreen),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Informe a medida' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Peso (opcional)',
                        suffixText: 'kg',
                        prefixIcon: Icon(Icons.scale_rounded, color: AppTheme.accentCyan),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _baitController,
                      decoration: const InputDecoration(
                        labelText: 'Isca Utilizada',
                        hintText: 'Ex: Shiner 90, Jig 10g',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _techniqueController,
                      decoration: const InputDecoration(
                        labelText: 'Técnica',
                        hintText: 'Ex: Pincho, Troll',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (equipments.isNotEmpty) ...[
                DropdownButtonFormField<String>(
                  initialValue: _selectedEquipmentId,
                  decoration: const InputDecoration(
                    labelText: 'Equipamento / Conjunto Utilizado',
                    prefixIcon: Icon(Icons.build_rounded, color: AppTheme.warningOrange),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Nenhum selecionado')),
                    ...equipments.map((eq) => DropdownMenuItem(
                          value: eq.id,
                          child: Text('${eq.name} (${eq.typeLabel})'),
                        )),
                  ],
                  onChanged: (val) => setState(() => _selectedEquipmentId = val),
                ),
                const SizedBox(height: 16),
              ],

              Card(
                color: AppTheme.cardBg,
                child: ListTile(
                  leading: Icon(
                    _latitude != null ? Icons.location_on : Icons.add_location_alt_rounded,
                    color: _latitude != null ? AppTheme.primaryGreen : AppTheme.textSecondary,
                    size: 28,
                  ),
                  title: Text(
                    _latitude != null ? 'Ponto Salvo Localmente 🔒' : 'Registrar Ponto GPS Privado',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    _latitude != null
                        ? 'Lat: ${_latitude!.toStringAsFixed(4)}, Long: ${_longitude!.toStringAsFixed(4)} (Não compartilhado)'
                        : 'Toque para guardar coordenadas apenas no aparelho.',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: _fetchingLocation
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                      : IconButton(
                          icon: const Icon(Icons.gps_fixed, color: AppTheme.primaryGreen),
                          onPressed: _captureLocation,
                        ),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Observações / História da Briga',
                  hintText: 'Ex: Bateu na estrutura de pau seco ao meio dia...',
                ),
              ),
              const SizedBox(height: 28),

              ElevatedButton.icon(
                onPressed: _submitCatch,
                icon: const Icon(Icons.check_circle_rounded, size: 28),
                label: const Text('SALVAR CAPTURA'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
