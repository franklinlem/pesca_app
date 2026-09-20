import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pesca_app/core/theme/app_theme.dart';
import 'package:pesca_app/core/widgets/pro_badge.dart';
import 'package:pesca_app/features/equipment/models/equipment_model.dart';
import 'package:pesca_app/features/equipment/providers/equipment_provider.dart';
import 'package:pesca_app/features/settings/providers/user_pro_provider.dart';

class EquipmentScreen extends ConsumerStatefulWidget {
  const EquipmentScreen({super.key});

  @override
  ConsumerState<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends ConsumerState<EquipmentScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  void _showAddDialog(BuildContext context, EquipmentType initialType) {
    final nameController = TextEditingController();
    final brandController = TextEditingController();
    final specsController = TextEditingController();
    EquipmentType selectedType = initialType;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('➕ Cadastrar Equipamento', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<EquipmentType>(
                initialValue: selectedType,
                decoration: const InputDecoration(labelText: 'Tipo de Equipamento'),
                items: const [
                  DropdownMenuItem(value: EquipmentType.rod, child: Text('Vara de Pesca')),
                  DropdownMenuItem(value: EquipmentType.reel, child: Text('Carretilha / Molinete')),
                  DropdownMenuItem(value: EquipmentType.line, child: Text('Linha')),
                  DropdownMenuItem(value: EquipmentType.bait, child: Text('Isca Artificial / Natural')),
                ],
                onChanged: (val) {
                  if (val != null) setModalState(() => selectedType = val);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Equipamento*',
                  hintText: 'Ex: Vara Venom, Carretilha Curado K, Isca Inna 70',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: brandController,
                decoration: const InputDecoration(
                  labelText: 'Marca (opcional)',
                  hintText: 'Ex: Shimano, Marine Sports, Daiwa, Deconto',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: specsController,
                decoration: const InputDecoration(
                  labelText: 'Especificações',
                  hintText: 'Ex: 17lbs 6\'0", 0.37mm Fluorocarbono, 9.5g Meia Água',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  if (nameController.text.trim().isEmpty) return;
                  ref.read(equipmentProvider.notifier).addEquipment(
                        type: selectedType,
                        name: nameController.text.trim(),
                        brand: brandController.text.isNotEmpty ? brandController.text.trim() : null,
                        specs: specsController.text.isNotEmpty ? specsController.text.trim() : null,
                      );
                  Navigator.pop(ctx);
                },
                icon: const Icon(Icons.check_rounded),
                label: const Text('SALVAR EQUIPAMENTO'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final equipments = ref.watch(equipmentProvider);
    final isPro = ref.watch(userProProvider);

    final rods = equipments.where((e) => e.type == EquipmentType.rod).toList();
    final reels = equipments.where((e) => e.type == EquipmentType.reel).toList();
    final lines = equipments.where((e) => e.type == EquipmentType.line).toList();
    final baits = equipments.where((e) => e.type == EquipmentType.bait).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎒 Meus Equipamentos'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryGreen,
          labelColor: AppTheme.primaryGreen,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(text: 'Varas'),
            Tab(text: 'Molinete/Carret.'),
            Tab(text: 'Linhas'),
            Tab(text: 'Iscas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _EquipmentList(list: rods, type: EquipmentType.rod, onAdd: () => _checkAndAdd(context, EquipmentType.rod, equipments.length, isPro)),
          _EquipmentList(list: reels, type: EquipmentType.reel, onAdd: () => _checkAndAdd(context, EquipmentType.reel, equipments.length, isPro)),
          _EquipmentList(list: lines, type: EquipmentType.line, onAdd: () => _checkAndAdd(context, EquipmentType.line, equipments.length, isPro)),
          _EquipmentList(list: baits, type: EquipmentType.bait, onAdd: () => _checkAndAdd(context, EquipmentType.bait, equipments.length, isPro)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded, size: 28),
        label: const Text('CADASTRAR', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () {
          final currentType = EquipmentType.values[_tabController.index];
          _checkAndAdd(context, currentType, equipments.length, isPro);
        },
      ),
    );
  }

  void _checkAndAdd(BuildContext context, EquipmentType type, int totalCount, bool isPro) {
    if (!isPro && totalCount >= 4) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Row(
            children: const [
              ProBadge(),
              SizedBox(width: 8),
              Text('Limite da Versão Grátis'),
            ],
          ),
          content: const Text(
            'A versão gratuita permite cadastrar até 4 equipamentos na sua caixa de tralha. Assine o Diário de Pesca PRO para ter cadastro ilimitado!',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Entendi')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ref.read(userProProvider.notifier).setProStatus(true);
              },
              child: const Text('ATIVAR PRO'),
            ),
          ],
        ),
      );
      return;
    }
    _showAddDialog(context, type);
  }
}

class _EquipmentList extends ConsumerWidget {
  final List<Equipment> list;
  final EquipmentType type;
  final VoidCallback onAdd;

  const _EquipmentList({required this.list, required this.type, required this.onAdd});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2_outlined, size: 56, color: AppTheme.textSecondary),
            const SizedBox(height: 12),
            const Text('Nenhum item cadastrado nesta categoria.', style: TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Cadastrar Primeiro Item'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.surfaceHeader,
              child: Icon(_getIconForType(item.type), color: AppTheme.primaryGreen),
            ),
            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Text(
              '${item.brand ?? "Sem Marca"} ${item.specs != null ? "• ${item.specs}" : ""}',
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.grey),
              onPressed: () {
                ref.read(equipmentProvider.notifier).deleteEquipment(item.id);
              },
            ),
          ),
        );
      },
    );
  }

  IconData _getIconForType(EquipmentType type) {
    switch (type) {
      case EquipmentType.rod:
        return Icons.straighten_rounded;
      case EquipmentType.reel:
        return Icons.rotate_right_rounded;
      case EquipmentType.line:
        return Icons.gesture_rounded;
      case EquipmentType.bait:
        return Icons.bug_report_rounded;
    }
  }
}
