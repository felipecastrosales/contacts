import 'dart:async';

import 'package:contacts/ui/home_page.dart';
import 'package:sqflite/sqflite.dart';

const String contactTable = 'contactTable';
const String idColumn = 'idColumn';
const String nameColumn = 'nameColumn';
const String emailColumn = 'emailColumn';
const String phoneColumn = 'phoneColumn';
const String imgColumn = 'imgColumn';

class ContactHelper {
  static final _instance = ContactHelper._internal();
  factory ContactHelper() => _instance;

  ContactHelper._internal();
  Database? _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    } else {
      _db = await initDb();
      return _db!;
    }
  }

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = '$databasesPath/contactsnew.db';

    return await openDatabase(path, version: 1,
        onCreate: (db, newerVersion) async {
      await db.execute('CREATE TABLE $contactTable('
          '$idColumn INTEGER PRIMARY KEY AUTOINCREMENT,'
          '$nameColumn TEXT,'
          '$emailColumn TEXT,'
          '$phoneColumn TEXT,'
          '$imgColumn TEXT)');
    });
  }

  Future<int> deleteContact(int id) async {
    var dbContact = await db;
    final result = await dbContact
        .delete(contactTable, where: '$idColumn = ?', whereArgs: [id]);

    return result;
  }

  Future<int> updateOrCreateContact(Contact contact) async {
    var dbContact = await db;

    int result = 0;

    if (contact.id == 0) {
      result = await dbContact.insert(
        contactTable,
        contact.toMap(includeId: false),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      result = await dbContact.update(
        contactTable,
        contact.toMap(includeId: false),
        where: '$idColumn = ?',
        whereArgs: [contact.id],
      );
    }

    return result;
  }

  Future<List> getAllContacts(
    OrderOptions order,
  ) async {
    var dbContact = await db;
    final orderBy = order == OrderOptions.aToZ ? 'ASC' : 'DESC';

    List listMap = await dbContact.rawQuery(
      'SELECT * FROM $contactTable ORDER BY TRIM($nameColumn) $orderBy',
    );

    var listContact = <Contact>[];

    for (Map m in listMap) {
      listContact.add(Contact.fromMap(m));
    }

    return listContact;
  }

  Future<int?> getNumber() async {
    var dbContact = await db;
    return Sqflite.firstIntValue(
        await dbContact.rawQuery('SELECT COUNT(*) FROM $contactTable'));
  }

  Future close() async {
    var dbContact = await db;
    dbContact.close();
  }
}

class Contact {
  Contact({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.img,
  });

  final int id;
  final String name;
  final String email;
  final String phone;
  final String img;

  factory Contact.fromMap(Map map) {
    return Contact(
      id: map[idColumn],
      name: map[nameColumn],
      email: map[emailColumn],
      phone: map[phoneColumn],
      img: map[imgColumn],
    );
  }

  Map<String, dynamic> toMap({bool includeId = true}) {
    final map = <String, dynamic>{
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img,
    };

    if (includeId) {
      map[idColumn] = id;
    }

    return map;
  }

  @override
  String toString() {
    return 'Contact(id: $id,name: $name, email: $email, phone: $phone, img: $img)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Contact &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.phone == phone &&
        other.img == img;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        phone.hashCode ^
        img.hashCode;
  }

  Contact copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? img,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      img: img ?? this.img,
    );
  }
}
