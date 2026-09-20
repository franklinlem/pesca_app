import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:pesca_app/core/database/database_helper.dart';
import 'package:pesca_app/features/sessions/models/fishing_session.dart';
import 'package:pesca_app/features/catches/models/catch_model.dart';
import 'package:pesca_app/features/equipment/models/equipment_model.dart';

class BackupService {
  /// Gera chave de 32 bytes (AES-256) a partir da senha do usuário
  static enc.Key _deriveKey(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return enc.Key(Uint8List.fromList(digest.bytes));
  }

  /// Exporta o banco de dados SQLite local em um arquivo criptografado (.pescabackup)
  static Future<File> exportEncryptedBackup(String password) async {
    final db = DatabaseHelper.instance;
    final sessions = await db.getSessions();
    final catches = await db.getAllCatches();
    final equipments = await db.getEquipments();

    final dataMap = {
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'sessions': sessions.map((s) => s.toMap()).toList(),
      'catches': catches.map((c) => c.toMap()).toList(),
      'equipments': equipments.map((e) => e.toMap()).toList(),
    };

    final jsonString = jsonEncode(dataMap);

    final key = _deriveKey(password);
    final iv = enc.IV.fromLength(16);
    final encrypter = enc.Encrypter(enc.AES(key));

    final encrypted = encrypter.encrypt(jsonString, iv: iv);

    final payload = {
      'iv': iv.base64,
      'data': encrypted.base64,
    };

    final docDir = await getApplicationDocumentsDirectory();
    final fileName = 'backup_pesca_${DateTime.now().millisecondsSinceEpoch}.pescabackup';
    final backupFile = File(p.join(docDir.path, fileName));

    await backupFile.writeAsString(jsonEncode(payload));
    return backupFile;
  }

  /// Restaura o arquivo criptografado (.pescabackup) no banco local
  static Future<bool> restoreEncryptedBackup(File backupFile, String password) async {
    try {
      final content = await backupFile.readAsString();
      final map = jsonDecode(content) as Map<String, dynamic>;

      final ivBase64 = map['iv'] as String;
      final dataBase64 = map['data'] as String;

      final key = _deriveKey(password);
      final iv = enc.IV.fromBase64(ivBase64);
      final encrypter = enc.Encrypter(enc.AES(key));

      final decrypted = encrypter.decrypt64(dataBase64, iv: iv);
      final dataMap = jsonDecode(decrypted) as Map<String, dynamic>;

      final db = DatabaseHelper.instance;

      if (dataMap.containsKey('sessions')) {
        for (var s in dataMap['sessions']) {
          final session = FishingSession.fromMap(Map<String, dynamic>.from(s));
          await db.insertSession(session);
        }
      }

      if (dataMap.containsKey('equipments')) {
        for (var e in dataMap['equipments']) {
          final equipment = Equipment.fromMap(Map<String, dynamic>.from(e));
          await db.insertEquipment(equipment);
        }
      }

      if (dataMap.containsKey('catches')) {
        for (var c in dataMap['catches']) {
          final catchModel = CatchModel.fromMap(Map<String, dynamic>.from(c));
          await db.insertCatch(catchModel);
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}
