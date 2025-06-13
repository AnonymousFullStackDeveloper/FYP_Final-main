import 'package:fyp_final/SharedData/UserDetails.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  static Future<Database> initDb() async {
    final path = join(await getDatabasesPath(), 'location_history.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE trip_log (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId INTEGER,
            startLat REAL,
            startLng REAL,
            startTimestamp TEXT,
            endLat REAL,
            endLng REAL,
            endTimestamp TEXT,
            isSynced INTEGER
          )
        ''');
      },
    );
  }

  // Insert a trip record (offline or fallback from failed sync)
  static Future<void> insertTrip(Map<String, dynamic> trip) async {
    final db = await database;
    await db.insert('trip_log', {
      'userId': UserData.UserId,
      'startLat': trip['startLat'],
      'startLng': trip['startLng'],
      'startTimestamp': trip['startTimestamp'],
      'endLat': trip['endLat'],
      'endLng': trip['endLng'],
      'endTimestamp': trip['endTimestamp'],
      'isSynced': trip['isSynced'] ? 1 : 0,
    });
  }

  // Retrieve all unsynced trip logs
  static Future<List<Map<String, dynamic>>> getUnsyncedTrips() async {
    final db = await database;
    return await db.query('trip_log', where: 'isSynced = ?', whereArgs: [0]);
  }

  // Mark a trip record as synced
  static Future<void> markTripAsSynced(int id) async {
    final db = await database;
    await db.update(
      'trip_log',
      {'isSynced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Optional: clear all trips (for testing)
  static Future<void> clearTrips() async {
    final db = await database;
    await db.delete('trip_log');
  }
}
