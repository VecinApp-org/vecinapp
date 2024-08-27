import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

import 'package:vecinapp/services/crud/docs_exceptions.dart';
import 'dart:developer' as devtools show log;

class DocsService {
  Database? _db;

  List<DatabaseDoc> _docs = [];

  static final DocsService _shared = DocsService._sharedInstance();

  DocsService._sharedInstance() {
    _docsStreamController = StreamController<List<DatabaseDoc>>.broadcast(
      onListen: () {
        _docsStreamController.sink.add(_docs);
      },
    );
  }

  factory DocsService() {
    return _shared;
  }

  late final StreamController<List<DatabaseDoc>> _docsStreamController;

  Stream<List<DatabaseDoc>> get allDocs {
    return _docsStreamController.stream;
  }

  Future<DatabaseUser> getOrCreateUser({
    required String authId,
  }) async {
    try {
      final user = await getUser(authId: authId);
      return user;
    } on CouldNotFindUser {
      final createdUser = await createUser(authId: authId);
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
    required String title,
  }) async {
    if (title.isEmpty) {
      throw EmptyTitle();
    }

    if (text.isEmpty) {
      throw EmptyText();
    }

    await ensureDatabaseIsOpen();
    final db = _getDatabaseOrThrow();

    // make sure doc exists in the database with the correct id
    final dbDoc = await getDoc(id: doc.id);
    if (dbDoc.userId != doc.userId) {
      throw CouldNotFindDoc();
    }

    // make sure user is the owner

    // update the doc in the database
    final updatesCount = await db.update(
      docTable,
      {
        docsTitleColumn: title,
        docsTextColumn: text,
        docsIsSyncedWithCloudColumn: 0,
      },
      where: '$docsIdColumn = ?',
      whereArgs: [doc.id],
    );

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
    await ensureDatabaseIsOpen();
    final db = _getDatabaseOrThrow();
    final docs = await db.query(docTable);
    return docs.map((docRow) => DatabaseDoc.fromRow(docRow));
  }

  Future<DatabaseDoc> getDoc({required int id}) async {
    await ensureDatabaseIsOpen();
    final db = _getDatabaseOrThrow();
    final docs = await db.query(
      docTable,
      limit: 1,
      where: '$docsIdColumn = ?',
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
    await ensureDatabaseIsOpen();
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
      where: '$docsIdColumn = ?',
      whereArgs: [id],
    );
    if (deletedCount == 0) {
      throw CouldNotDeleteDoc();
    } else {
      _docs.removeWhere((doc) => doc.id == id);
      _docsStreamController.add(_docs);
    }
  }

  Future<DatabaseDoc> createDoc({
    required DatabaseUser owner,
    required String title,
    required String text,
  }) async {
    if (title.isEmpty) {
      throw EmptyTitle();
    }

    if (text.isEmpty) {
      throw EmptyText();
    }

    await ensureDatabaseIsOpen();
    final db = _getDatabaseOrThrow();

    // make sure owner exists in the database with the correct id
    final dbUser = await getUser(authId: owner.authId);

    if (dbUser != owner) {
      throw CouldNotFindUser();
    }

    // create the document
    final docId = await db.insert(docTable, {
      docsUserIdSyncedColumn: owner.id,
      docsTextColumn: text,
      docsTitleColumn: title,
      docsIsSyncedWithCloudColumn: 1,
    });

    final doc = DatabaseDoc(
      id: docId,
      userId: owner.id,
      text: text,
      title: title,
      isSyncedWithCloud: true,
    );

    _docs.add(doc);
    _docsStreamController.add(_docs);

    return doc;
  }

  Future<DatabaseDoc> createEmptyDoc({required DatabaseUser owner}) async {
    await ensureDatabaseIsOpen();
    final db = _getDatabaseOrThrow();

    // make sure owner exists in the database with the correct id
    final dbUser = await getUser(authId: owner.authId);

    if (dbUser != owner) {
      throw CouldNotFindUser();
    }

    const text = '';
    const title = '';

    // create the document
    final docId = await db.insert(docTable, {
      docsUserIdSyncedColumn: owner.id,
      docsTextColumn: text,
      docsTitleColumn: title,
      docsIsSyncedWithCloudColumn: 1,
    });

    final doc = DatabaseDoc(
      id: docId,
      userId: owner.id,
      text: text,
      title: title,
      isSyncedWithCloud: true,
    );

    _docs.add(doc);
    _docsStreamController.add(_docs);

    return doc;
  }

  Future<DatabaseUser> getUser({required String authId}) async {
    await ensureDatabaseIsOpen();
    final db = _getDatabaseOrThrow();
    final result = await db.query(
      userTable,
      limit: 1,
      where: '$usersAuthIdColumn = ?',
      whereArgs: [authId],
    );

    if (result.isEmpty) {
      throw CouldNotFindUser();
    } else {
      final user = DatabaseUser.fromRow(result.first);
      return user;
    }
  }

  Future<DatabaseUser> createUser({required String authId}) async {
    await ensureDatabaseIsOpen();
    final db = _getDatabaseOrThrow();
    // make sure authId is unique in the database
    final result = await db.query(
      userTable,
      limit: 1,
      where: "$usersAuthIdColumn = ?",
      whereArgs: [authId],
    );
    if (result.isNotEmpty) {
      throw UserAlreadyExists();
    }
    // create the user
    final userId = await db.insert(userTable, {
      usersAuthIdColumn: authId,
    });
    return DatabaseUser(
      id: userId,
      authId: authId,
    );
  }

  Future<void> deleteUser({required String authId}) async {
    await ensureDatabaseIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: '$usersAuthIdColumn = ?',
      whereArgs: [authId],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    } else {}
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
    final db = _db;
    if (db == null) {
      devtools.log('(close) Database is not open');
      throw DatabaseIsNotOpen();
    }

    await db.close();
    _db = null;
  }

  Future<void> ensureDatabaseIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpen {
      // empty
    }
  }

  Future<void> open() async {
    if (_db != null) {
      devtools.log('(open) Database already open');
      throw DatabaseAlreadyOpen();
    }
    try {
      devtools.log('(open) Opening database');
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
    } catch (e) {
      throw CouldNotOpenDatabase();
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String authId;
  const DatabaseUser({
    required this.id,
    required this.authId,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[usersIdColumn] as int,
        authId = map[usersAuthIdColumn] as String;

  @override
  String toString() => 'Person, ID = $id, AuthId = $authId';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseDoc {
  final int id;
  final int userId;
  final String text;
  final String title;
  final bool isSyncedWithCloud;

  DatabaseDoc({
    required this.id,
    required this.userId,
    required this.text,
    required this.title,
    required this.isSyncedWithCloud,
  });

  DatabaseDoc.fromRow(Map<String, Object?> map)
      : id = map[usersIdColumn] as int,
        userId = map[docsUserIdSyncedColumn] as int,
        text = map[docsTextColumn] as String,
        title = map[docsTitleColumn] as String,
        isSyncedWithCloud =
            (map[docsIsSyncedWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      'Doc, ID = $id, userId = $userId, isSyncedWithCloud = $isSyncedWithCloud, text = $text, title = $title';
  @override
  bool operator ==(covariant DatabaseDoc other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'docs.db';
const docTable = 'docs';
const userTable = 'users';

const usersIdColumn = 'id';
const usersAuthIdColumn = 'auth_id';

const docsIdColumn = 'id';
const docsUserIdSyncedColumn = 'user_id';
const docsTextColumn = 'text';
const docsIsSyncedWithCloudColumn = 'is_synced_with_cloud';
const docsTitleColumn = 'title';

const createUserTable = '''CREATE TABLE IF NOT EXISTS "users" (
	"id"	INTEGER NOT NULL,
  "auth_id"	TEXT NOT NULL UNIQUE,
	PRIMARY KEY("id" AUTOINCREMENT)
);''';
const createDocTable = '''CREATE TABLE IF NOT EXISTS "docs" (
	"id"	INTEGER NOT NULL,
	"user_id"	INTEGER NOT NULL,
	"text"	TEXT,
	"is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
	"title"	TEXT,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("user_id") REFERENCES "users"("id")
);''';
