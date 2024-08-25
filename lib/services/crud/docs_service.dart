import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

import 'package:vecinapp/services/crud/crud_exceptions.dart';

class DocsService {
  Database? _db;

  List<DatabaseDoc> _docs = [];

  static final DocsService _shared = DocsService._sharedInstance();
  DocsService._sharedInstance();
  factory DocsService() => _shared;

  final _docsStreamController = StreamController<List<DatabaseDoc>>.broadcast();

  Stream<List<DatabaseDoc>> get allDocs => _docsStreamController.stream;

  Future<DatabaseUser> getOrCreateUser({
    required String email,
  }) async {
    try {
      final user = await getUser(email: email);
      return user;
    } on CouldNotFindUser {
      final createdUser = await createUser(email: email);
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _cacheDocs() async {
    final allDocs = await getAllDocs();
    _docs = allDocs.toList();
    _docsStreamController.add(_docs);
  }

  Future<DatabaseDoc> updateDoc({
    required DatabaseDoc doc,
    required String text,
  }) async {
    await ensureDatatabaseIsOpen();
    final db = _getDatabaseOrThrow();

    // make sure owner exists in the database with the correct id
    await getDoc(id: doc.id);

    // update the doc in the database
    final updatesCount = await db.update(docTable, {
      textColumn: text,
      isSyncedWithCloudColumn: 0,
    });

    if (updatesCount == 0) {
      throw CouldNotUpdateDoc();
    } else {
      final updatedDoc = await getDoc(id: doc.id);
      _docs.removeWhere((doc) => doc.id == updatedDoc.id);
      _docs.add(updatedDoc);
      _docsStreamController.add(_docs);
      return updatedDoc;
    }
  }

  Future<Iterable<DatabaseDoc>> getAllDocs() async {
    await ensureDatatabaseIsOpen();
    final db = _getDatabaseOrThrow();
    final docs = await db.query(docTable);
    return docs.map((docRow) => DatabaseDoc.fromRow(docRow));
  }

  Future<DatabaseDoc> getDoc({required int id}) async {
    await ensureDatatabaseIsOpen();
    final db = _getDatabaseOrThrow();
    final docs = await db.query(
      docTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (docs.isEmpty) {
      throw CouldNotFindDoc();
    } else {
      final doc = DatabaseDoc.fromRow(docs.first);
      _docs.removeWhere((doc) => doc.id == id);
      _docs.add(doc);
      _docsStreamController.add(_docs);
      return doc;
    }
  }

  Future<int> deleteAllDocs() async {
    await ensureDatatabaseIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(docTable);
    _docs = [];
    _docsStreamController.add(_docs);
    return deletedCount;
  }

  Future<void> deleteDoc({required int id}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      docTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deletedCount == 0) {
      throw CouldNotDeleteDoc();
    } else {
      _docs.removeWhere((doc) => doc.id == id);
      _docsStreamController.add(_docs);
    }
  }

  Future<DatabaseDoc> createDoc({required DatabaseUser owner}) async {
    await ensureDatatabaseIsOpen();
    final db = _getDatabaseOrThrow();

    // make sure owner exists in the database with the correct id
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }

    const text = '';

    // create the document
    final docId = await db.insert(docTable, {
      userIdColumn: owner.id,
      textColumn: text,
      isSyncedWithCloudColumn: 1,
    });

    final doc = DatabaseDoc(
      id: docId,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: true,
    );

    _docs.add(doc);
    _docsStreamController.add(_docs);

    return doc;
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await ensureDatatabaseIsOpen();
    final db = _getDatabaseOrThrow();
    final result = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (result.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(result.first);
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await ensureDatatabaseIsOpen();
    final db = _getDatabaseOrThrow();
    final result = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (result.isNotEmpty) {
      throw UserAlreadyExists();
    }

    final userId = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });
    return DatabaseUser(
      id: userId,
      email: email,
    );
  }

  Future<void> deleteUser({required String email}) async {
    await ensureDatatabaseIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> close() async {
    if (_db == null) {
      throw DatabaseIsNotOpen();
    }
    await _db!.close();
    _db = null;
  }

  Future<void> ensureDatatabaseIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      // empty
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final docsDbPath = join(docsPath.path, dbName);
      final db = await openDatabase(docsDbPath);
      _db = db;
      // create the user table
      await db.execute(createUserTable);
      // create the doc table
      await db.execute(createDocTable);
      await _cacheDocs();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;
  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID = $id, email = $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseDoc {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  DatabaseDoc({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });

  DatabaseDoc.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud =
            (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      'Doc, ID = $id, userId = $userId, isSyncedWithCloud = $isSyncedWithCloud, text = $text';
  @override
  bool operator ==(covariant DatabaseDoc other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'docs.db';
const docTable = 'docs';
const userTable = 'users';

const idColumn = 'id';
const emailColumn = 'email';

const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';

const createUserTable = '''
CREATE TABLE IF NOT EXISTS "user" (
  "id"	INTEGER NOT NULL UNIQUE,
  "email"	TEXT NOT NULL UNIQUE,
  PRIMARY KEY("id" AUTOINCREMENT)
);''';
const createDocTable = '''
CREATE TABLE IF NOT EXISTS "doc" (
  "id"	INTEGER NOT NULL UNIQUE,
  "user_id"	INTEGER NOT NULL,
  "text"	TEXT,
  "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY("id" AUTOINCREMENT),
  FOREIGN KEY("user_id") REFERENCES "user"("id")
);''';
