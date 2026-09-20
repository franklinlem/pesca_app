import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pesca_app/core/database/database_helper.dart';
import 'package:pesca_app/features/catches/models/catch_model.dart';
import 'package:pesca_app/features/sessions/providers/session_provider.dart';
import 'package:uuid/uuid.dart';

class CatchNotifier extends Notifier<List<CatchModel>> {
  @override
  List<CatchModel> build() {
    loadAllCatches();
    return [];
  }

  Future<void> loadAllCatches() async {
    final list = await DatabaseHelper.instance.getAllCatches();
    state = list;
  }

  Future<void> addCatch({
    required String sessionId,
    required String species,
    required double lengthCm,
    double? weightKg,
    String? baitUsed,
    String? technique,
    required bool isReleased,
    String? photoPath,
    double? latitude,
    double? longitude,
    String? notes,
    String? equipmentId,
  }) async {
    final catchModel = CatchModel(
      id: const Uuid().v4(),
      sessionId: sessionId,
      species: species,
      lengthCm: lengthCm,
      weightKg: weightKg,
      timestamp: DateTime.now(),
      baitUsed: baitUsed,
      technique: technique,
      isReleased: isReleased,
      photoPath: photoPath,
      latitude: latitude,
      longitude: longitude,
      notes: notes,
      equipmentId: equipmentId,
    );

    await DatabaseHelper.instance.insertCatch(catchModel);
    await loadAllCatches();
    await ref.read(sessionProvider.notifier).loadSessions();
  }

  Future<void> deleteCatch(String id) async {
    await DatabaseHelper.instance.deleteCatch(id);
    await loadAllCatches();
    await ref.read(sessionProvider.notifier).loadSessions();
  }
}

final catchProvider = NotifierProvider<CatchNotifier, List<CatchModel>>(CatchNotifier.new);
