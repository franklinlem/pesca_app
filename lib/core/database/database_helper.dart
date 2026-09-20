import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:pesca_app/features/sessions/models/fishing_session.dart';
import 'package:pesca_app/features/catches/models/catch_model.dart';
import 'package:pesca_app/features/equipment/models/equipment_model.dart';
import 'package:pesca_app/features/weather/models/weather_condition.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('diario_pesca.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Tabela Pescarias
    await db.execute('''
      CREATE TABLE pescarias (
        id TEXT PRIMARY KEY,
        start_time TEXT NOT NULL,
        end_time TEXT,
        location_name TEXT,
        latitude REAL,
        longitude REAL,
        notes TEXT,
        is_active INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Tabela Capturas
    await db.execute('''
      CREATE TABLE capturas (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        species TEXT NOT NULL,
        length_cm REAL NOT NULL,
        weight_kg REAL,
        timestamp TEXT NOT NULL,
        bait_used TEXT,
        technique TEXT,
        is_released INTEGER NOT NULL DEFAULT 1,
        photo_path TEXT,
        latitude REAL,
        longitude REAL,
        notes TEXT,
        equipment_id TEXT,
        FOREIGN KEY (session_id) REFERENCES pescarias (id) ON DELETE CASCADE
      )
    ''');

    // Tabela Equipamentos
    await db.execute('''
      CREATE TABLE equipamentos (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        name TEXT NOT NULL,
        brand TEXT,
        specs TEXT,
        photo_path TEXT,
        is_favorite INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Tabela Condicoes Ambientais
    await db.execute('''
      CREATE TABLE condicoes_ambientais (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        weather TEXT NOT NULL,
        wind TEXT NOT NULL,
        water_condition TEXT NOT NULL,
        temperature_c REAL,
        moon_phase TEXT,
        pressure_hpa REAL,
        notes TEXT,
        FOREIGN KEY (session_id) REFERENCES pescarias (id) ON DELETE CASCADE
      )
    ''');
  }

  // --- PESCARIAS (SESSIONS) ---
  Future<void> insertSession(FishingSession session) async {
    final db = await instance.database;
    await db.insert('pescarias', session.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateSession(FishingSession session) async {
    final db = await instance.database;
    await db.update(
      'pescarias',
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  Future<List<FishingSession>> getSessions() async {
    final db = await instance.database;
    final result = await db.query('pescarias', orderBy: 'start_time DESC');

    List<FishingSession> sessions = [];
    for (var map in result) {
      final id = map['id'] as String;
      final catches = await getCatchesBySession(id);
      final weather = await getWeatherBySession(id);
      sessions.add(FishingSession.fromMap(map, catches: catches, weather: weather));
    }
    return sessions;
  }

  Future<FishingSession?> getActiveSession() async {
    final db = await instance.database;
    final result = await db.query(
      'pescarias',
      where: 'is_active = 1',
      limit: 1,
    );
    if (result.isEmpty) return null;
    final id = result.first['id'] as String;
    final catches = await getCatchesBySession(id);
    final weather = await getWeatherBySession(id);
    return FishingSession.fromMap(result.first, catches: catches, weather: weather);
  }

  Future<void> deleteSession(String id) async {
    final db = await instance.database;
    await db.delete('pescarias', where: 'id = ?', whereArgs: [id]);
    await db.delete('capturas', where: 'session_id = ?', whereArgs: [id]);
    await db.delete('condicoes_ambientais', where: 'session_id = ?', whereArgs: [id]);
  }

  // --- CAPTURAS (CATCHES) ---
  Future<void> insertCatch(CatchModel catchModel) async {
    final db = await instance.database;
    await db.insert('capturas', catchModel.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<CatchModel>> getCatchesBySession(String sessionId) async {
    final db = await instance.database;
    final result = await db.query(
      'capturas',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'timestamp DESC',
    );
    return result.map((json) => CatchModel.fromMap(json)).toList();
  }

  Future<List<CatchModel>> getAllCatches() async {
    final db = await instance.database;
    final result = await db.query('capturas', orderBy: 'timestamp DESC');
    return result.map((json) => CatchModel.fromMap(json)).toList();
  }

  Future<void> deleteCatch(String id) async {
    final db = await instance.database;
    await db.delete('capturas', where: 'id = ?', whereArgs: [id]);
  }

  // --- EQUIPAMENTOS ---
  Future<void> insertEquipment(Equipment eq) async {
    final db = await instance.database;
    await db.insert('equipamentos', eq.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Equipment>> getEquipments() async {
    final db = await instance.database;
    final result = await db.query('equipamentos', orderBy: 'name ASC');
    return result.map((json) => Equipment.fromMap(json)).toList();
  }

  Future<void> deleteEquipment(String id) async {
    final db = await instance.database;
    await db.delete('equipamentos', where: 'id = ?', whereArgs: [id]);
  }

  // --- CONDICOES CLIMATICAS ---
  Future<void> saveWeather(WeatherCondition weather) async {
    final db = await instance.database;
    await db.insert('condicoes_ambientais', weather.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<WeatherCondition?> getWeatherBySession(String sessionId) async {
    final db = await instance.database;
    final result = await db.query(
      'condicoes_ambientais',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return WeatherCondition.fromMap(result.first);
  }

  Future<void> closeDB() async {
    final db = await instance.database;
    await db.close();
  }
}
