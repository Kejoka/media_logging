import 'dart:developer';

import 'package:media_logging/domain/repositories/database_repository.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

/// Repositroy that handles all database accesses that affect the entire databse

class DatabaseRepositoryImpl implements DatabaseRepository {
  Future<Database> initDB() async {
    String dbPath = await getDatabasesPath();
    return openDatabase(join(dbPath, "media_database.db"), version: 2,
        onCreate: (database, version) async {
      await database.execute(
          "CREATE TABLE games (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, addedIn NUMBER, image TEXT, release TEXT, genres TEXT, platforms TEXT, averageRating REAL, medal NUMBER, trophy NUMBER)");
      await database.execute(
          "CREATE TABLE movies (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, image TEXT, genres TEXT, addedIn NUMBER, release TEXT, medal NUMBER, averageRating REAL)");
      await database.execute(
          "CREATE TABLE shows (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, image TEXT, genres TEXT, addedIn NUMBER, release TEXT, medal NUMBER, seasons TEXT, averageRating REAL)");
      await database.execute(
          "CREATE TABLE books (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, subtitle TEXT, image TEXT, author TEXT, medal NUMBER, averageRating REAL, pageCount NUMBER, release TEXT, addedIn NUMBER)");
    },
    onUpgrade: (database, oldVersion, newVersion) async {
      if (newVersion == 2) {
        await database.execute("ALTER TABLE shows ADD COLUMN episode INT DEFAULT 0");
      }
    });
  }

  @override
  Future<List<Object?>> getYearList(int? mediaIndex) async {
    final Database db = await initDB();
    List<Map<String, Object?>> result;
    switch (mediaIndex) {
      case 0:
        result = await db.query("games",
            distinct: true, orderBy: "addedIn", columns: ["addedIn"]);
        break;
      case 1:
        result = await db.query("movies",
            distinct: true, orderBy: "addedIn", columns: ["addedIn"]);
        break;
      case 2:
        result = await db.query("shows",
            distinct: true, orderBy: "addedIn", columns: ["addedIn"]);
        break;
      case 3:
        result = await db.query("books",
            distinct: true, orderBy: "addedIn", columns: ["addedIn"]);
        break;
      default:
        result = [
          {"addedIn": 2022}
        ];
    }
    var yearList = result.map((e) => e["addedIn"]).toList();
    if (!yearList.contains(DateTime.now().year)) {
      yearList.add(DateTime.now().year);
    }
    return yearList;
  }

  @override
  Future<void> emptyDatabase() async {
    final db = await initDB();
    await db.delete('movies');
    await db.delete('games');
    await db.delete('shows');
    await db.delete('books');
  }

  @override
  Future<bool> exportDatabase() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    String dbPath = await getDatabasesPath();
    File dbFile = File(join(dbPath, "media_database.db"));
    if (selectedDirectory != null) {
      String backupFile = join(selectedDirectory, "media_database.db");
      dbFile.copy(backupFile);
      return true;
    } else {
      return false;
    }
  }

  @override
  Future<bool> importDatabase() async {
    FilePickerResult? chosenBackupFile = await FilePicker.platform.pickFiles();
    FilePickerResult chosenBackupFileNotNull;
    if (chosenBackupFile != null) {
      // Flutter did not accept chosenBackupFile.files.single.path despite being within
      // the null check for some reason.
      chosenBackupFileNotNull = chosenBackupFile;
      var importFile = File(chosenBackupFileNotNull.files.single.path ?? "");
      String dbPath = await getDatabasesPath();
      importFile.copy(join(dbPath, "media_database.db"));
      return true;
    } else {
      return false;
    }
  }

  @override
  Future<void> deleteDatabase() async {
    String dbPath = await getDatabasesPath();
    databaseFactory.deleteDatabase(join(dbPath, "media_database.db"));
  }
}
