import 'package:control_app/model/massageSetting.dart';
import 'package:control_app/model/user.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:synchronized/synchronized.dart';

class MassageDatabase {
  static final MassageDatabase instance = MassageDatabase._init();

  static Database? _database;

  MassageDatabase._init();

  static Lock _lock = Lock();

  //Get Database instance
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('massage.db');
    return _database!;
  }

  //Initialise database
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path,
        version: 1, onCreate: _createDB, onUpgrade: _createDBAgain);
  }

  //create databse schema
  Future _createDB(Database db, int version) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final textType = 'TEXT NOT NULL';
    final boolType = 'BOOLEAN NOT NULL';
    final integerType = 'INTEGER NOT NULL';
    final textNullType = 'TEXT NULL';
    final dateTimeType = 'DATETIME NULL';
    final blobNullType = 'BLOB NULL';

    await db.execute('''
    CREATE TABLE $userTable ( 
      ${UserFields.userId} $textNullType, 
      ${UserFields.firstName} $textNullType,
      ${UserFields.lastName} $textNullType,
      ${UserFields.userName} $textNullType,
      ${UserFields.email} $textNullType,
      ${UserFields.role} $textNullType,
      ${UserFields.registerType} $textNullType,
      ${UserFields.profileImagePath} $textNullType,
      ${UserFields.profileImageSource} $blobNullType,
      ${UserFields.modifiedAt} $textNullType,
      ${UserFields.token} $textNullType
      )
    ''');

    await db.execute('''
    CREATE TABLE $massageSettingTable ( 
      ${MassageSettingFields.massageSettingId} $textNullType, 
      ${MassageSettingFields.userId} $textNullType, 
      ${MassageSettingFields.massageConfiguration} $textNullType,
      ${MassageSettingFields.modifiedAt} $textNullType
      )
    ''');
  }

  //re-create databse schema when upgrade
  Future _createDBAgain(Database db, int version, int test) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final textType = 'TEXT NOT NULL';
    final boolType = 'BOOLEAN NOT NULL';
    final integerType = 'INTEGER NOT NULL';
    final textNullType = 'TEXT NULL';
    final dateTimeType = 'DATETIME NULL';
    final blobNullType = 'BLOB NULL';

    await db.execute('''
    ALTER TABLE $userTable ( 
      ${UserFields.userId} $textNullType, 
      ${UserFields.firstName} $textNullType,
      ${UserFields.lastName} $textNullType,
      ${UserFields.userName} $textNullType,
      ${UserFields.email} $textNullType,
      ${UserFields.role} $textNullType,
      ${UserFields.registerType} $textNullType,
      ${UserFields.profileImagePath} $textNullType,
      ${UserFields.profileImageSource} $blobNullType,
      ${UserFields.modifiedAt} $textNullType,
      ${UserFields.token} $textNullType
      )
    ''');

    await db.execute('''
    ALTER TABLE $massageSettingTable ( 
      ${MassageSettingFields.massageSettingId} $textNullType, 
      ${MassageSettingFields.userId} $textNullType, 
      ${MassageSettingFields.massageConfiguration} $textNullType,
      ${MassageSettingFields.modifiedAt} $textNullType
      )
    ''');
  }

  //add user record
  Future<User> addUser(User user) async {
    return _lock.synchronized(() async {
      final db = await instance.database;

      // final json = note.toJson();
      // final columns =
      //     '${NoteFields.title}, ${NoteFields.description}, ${NoteFields.time}';
      // final values =
      //     '${json[NoteFields.title]}, ${json[NoteFields.description]}, ${json[NoteFields.time]}';
      // final id = await db
      //     .rawInsert('INSERT INTO table_name ($columns) VALUES ($values)');

      final maps = await db.query(
        userTable,
        columns: UserFields.values,
        where: '${UserFields.userId} = ?',
        whereArgs: [user.userId],
      );

      if (maps.isNotEmpty) {
        return User.fromJson(maps.first, maps.first["token"].toString());
      } else {
        final id = await db.insert(userTable, user.toJson());
        return user.copy(userId: id.toString());
      }
    });
  }

  //add massage setting record
  Future<MassageSetting> addMassageSetting(
      MassageSetting massageSetting) async {
    return _lock.synchronized(() async {
      final db = await instance.database;

      final maps = await db.query(
        massageSettingTable,
        columns: MassageSettingFields.values,
        where: '${MassageSettingFields.userId} = ?',
        whereArgs: [massageSetting.userId],
      );

      if (maps.isNotEmpty) {
        //update Massage Setting if found
        await db.update(
          massageSettingTable,
          massageSetting.toJson(),
          where: '${MassageSettingFields.userId} = ?',
          whereArgs: [massageSetting.userId],
        );
        return massageSetting;
      } else {
        final id =
            await db.insert(massageSettingTable, massageSetting.toJson());
        return massageSetting.copy(massageSettingId: id.toString());
      }
    });
  }

  //Get user by id
  Future<User> getUser(String? id) async {
    final db = await instance.database;

    final maps = await db.query(
      userTable,
      columns: UserFields.values,
      where: '${UserFields.userId} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return User.fromJson(maps.first, maps.first["token"].toString());
    } else {
      throw Exception('ID $id not found');
    }
  }

  //Get last user
  Future<User> getUserWithoutId() async {
    final db = await instance.database;

    final maps =
        await db.query(userTable, columns: UserFields.values, limit: 1);

    if (maps.isNotEmpty) {
      return User.fromJson(maps.first, maps.first["token"].toString());
    } else {
      throw Exception('User not found');
    }
  }

  //Get massage setting by user Id
  Future<MassageSetting> getMassageSetting(String? id) async {
    final db = await instance.database;

    final maps = await db.query(
      massageSettingTable,
      columns: MassageSettingFields.values,
      where: '${MassageSettingFields.userId} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return MassageSetting.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  //Check whether user data exist
  Future<bool> checkIsLocalUserDataEmpty() async {
    final db = await instance.database;

    int? count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $userTable'));

    if (count! >= 1) {
      return true;
    } else {
      return false;
    }
  }

  Future<List<User>> readAllNotes() async {
    final db = await instance.database;

    final orderBy = '${UserFields.userId} ASC';
    // final result =
    //     await db.rawQuery('SELECT * FROM $tableNotes ORDER BY $orderBy');

    final result = await db.query(userTable, orderBy: orderBy);

    return result
        .map((json) => User.fromJson(json, json["token"].toString()))
        .toList();
  }

  //update user details
  Future<int> updateUser(User user) async {
    return _lock.synchronized(() async {
      final db = await instance.database;

      return await db.update(
        userTable,
        user.toJson(),
        where: '${UserFields.userId} = ?',
        whereArgs: [user.userId],
      );
    });
  }

  //update user modifyDate
  Future<int> updateUserModifyDate(User user) async {
    return _lock.synchronized(() async {
      final db = await instance.database;

      return await db.update(
        userTable,
        <String, dynamic>{
          'modifiedAt': user.modifiedAt,
        },
        where: '${UserFields.userId} = ?',
        whereArgs: [user.userId],
      );
    });
  }

  //update massage setting
  Future<int> updateMassageSetting(MassageSetting massageSetting) async {
    return _lock.synchronized(() async {
      final db = await instance.database;

      return await db.update(
        massageSettingTable,
        massageSetting.toJson(),
        where: '${UserFields.userId} = ?',
        whereArgs: [massageSetting.userId],
      );
    });
  }

  //delete user by id
  Future<int> delete(int id) async {
    return _lock.synchronized(() async {
      final db = await instance.database;

      return await db.delete(
        userTable,
        where: '${UserFields.userId} = ?',
        whereArgs: [id],
      );
    });
  }

  //Clear all data when user log out
  Future<int> deleteMassageTableAndUsetTableData() async {
    final db = await instance.database;
    await db.delete(
      massageSettingTable,
    );

    return await db.delete(
      userTable,
    );
  }

  //drop table
  Future dropTable() async {
    final db = await instance.database;

    await db.execute("DROP TABLE IF EXISTS $userTable");
    await db.execute("DROP TABLE IF EXISTS $massageSettingTable");
  }

  //Clear all data by run query
  Future deleteAllData() async {
    final db = await instance.database;

    await db.execute("DELETE FROM $userTable");
    await db.execute("DELETE FROM $massageSettingTable");
  }

  //close database in dispose
  // Future close() async {
  //   final db = await instance.database;
  //   _database = null;
  //   db.close();
  // }
}
