import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'vehicle_entry.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) {
        return db.execute(
          '''
          CREATE TABLE entries(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            vehicleNumber TEXT,
            driverName TEXT,
            date TEXT,
            time TEXT,
            timeout TEXT,
            location TEXT,
            latitude REAL,
            longitude REAL 
          )
          ''',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion < 2) {
          db.execute('ALTER TABLE entries ADD COLUMN timeout TEXT');
        }
      },
    );
  }

  Future<void> insertEntry(Map<String, dynamic> entry) async {
    final db = await database;
    await db.insert(
      'entries',
      entry,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> fetchEntries() async {
    final db = await database;
    return await db.query('entries');
  }

  Future<void> deleteAllEntries() async {
    final db = await database;
    await db.delete('entries');
  }

Future<void> updateEntry(Map<String, dynamic> entry) async {
  final db = await database;

  await db.update(
    'entries',
    {
      'driverName': entry['driverName'], 
      'date': entry['date'],
      'time': entry['time'],
      'timeout': entry['timeout'], 
    },
    where: 'vehicleNumber = ?',
    whereArgs: [entry['vehicleNumber']], 
  );
}

}
