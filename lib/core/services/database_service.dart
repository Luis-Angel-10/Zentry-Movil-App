import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _open();
    return _database!;
  }

  Future<Database> _open() async {
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'zentry.db');

    return openDatabase(
      path,
      version: 4,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fullName TEXT NOT NULL,
            artistName TEXT,
            username TEXT NOT NULL UNIQUE COLLATE NOCASE,
            email TEXT NOT NULL UNIQUE COLLATE NOCASE,
            passwordHash TEXT NOT NULL,
            salt TEXT NOT NULL,
            discipline TEXT,
            bio TEXT,
            photoPath TEXT,
            coverPhotoPath TEXT,
            avatarFrameId TEXT,
            featuredBadgeIds TEXT,
            interests TEXT,
            createdAt TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE users ADD COLUMN photoPath TEXT');
          await db.execute('ALTER TABLE users ADD COLUMN coverPhotoPath TEXT');
        }
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE users ADD COLUMN avatarFrameId TEXT');
          await db.execute(
            'ALTER TABLE users ADD COLUMN featuredBadgeIds TEXT',
          );
        }
        if (oldVersion < 4) {
          await db.execute('ALTER TABLE users ADD COLUMN interests TEXT');
        }
      },
    );
  }
}
