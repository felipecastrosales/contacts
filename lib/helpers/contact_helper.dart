import 'dart:async';

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
    // final path = join(databasesPath, 'contactsnew.db');
    final path = '$databasesPath/contactsnew.db';
    return await openDatabase(path, version: 1,
        onCreate: (db, newerVersion) async {
      await db.execute('CREATE TABLE $contactTable('
          '$idColumn INTEGER PRIMARY KEY,'
          '$nameColumn TEXT,'
          '$emailColumn TEXT,'
          '$phoneColumn TEXT,'
          '$imgColumn TEXT)');
    });
  }

  Future<Contact> saveContact(Contact contact) async {
    var dbContact = await db;
    contact.id = await dbContact.insert(contactTable, contact.toMap());
    return contact;
  }

  Future<Contact?> getContact(int id) async {
    var dbContact = await db;
    List<Map> maps = await dbContact.query(contactTable,
        columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],
        where: '$idColumn = ?',
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Contact.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> deleteContact(int id) async {
    var dbContact = await db;
    return await dbContact
        .delete(contactTable, where: '$idColumn = ?', whereArgs: [id]);
  }

  Future<int> updateContact(Contact contact) async {
    var dbContact = await db;
    return await dbContact.update(contactTable, contact.toMap(),
        where: '$idColumn = ?', whereArgs: [contact.id]);
  }

  Future<List> getAllContacts() async {
    var dbContact = await db;
    List listMap = await dbContact.rawQuery('SELECT * FROM $contactTable');
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

  int id;
  String name;
  String email;
  String phone;
  String img;

  factory Contact.fromMap(Map map) {
    return Contact(
      id: map[idColumn],
      name: map[nameColumn],
      email: map[emailColumn],
      phone: map[phoneColumn],
      img: map[imgColumn],
    );
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img
    };
    map[idColumn] = id;
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
}
