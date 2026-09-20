import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pesca_app/core/database/database_helper.dart';
import 'package:pesca_app/features/equipment/models/equipment_model.dart';
import 'package:uuid/uuid.dart';

class EquipmentNotifier extends Notifier<List<Equipment>> {
  @override
  List<Equipment> build() {
    loadEquipments();
    return [];
  }

  Future<void> loadEquipments() async {
    final list = await DatabaseHelper.instance.getEquipments();
    state = list;
  }

  Future<void> addEquipment({
    required EquipmentType type,
    required String name,
    String? brand,
    String? specs,
    String? photoPath,
  }) async {
    final eq = Equipment(
      id: const Uuid().v4(),
      type: type,
      name: name,
      brand: brand,
      specs: specs,
      photoPath: photoPath,
    );

    await DatabaseHelper.instance.insertEquipment(eq);
    await loadEquipments();
  }

  Future<void> deleteEquipment(String id) async {
    await DatabaseHelper.instance.deleteEquipment(id);
    await loadEquipments();
  }
}

final equipmentProvider = NotifierProvider<EquipmentNotifier, List<Equipment>>(EquipmentNotifier.new);
