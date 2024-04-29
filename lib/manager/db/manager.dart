// ignore_for_file: depend_on_referenced_packages, constant_identifier_names

import 'dart:io';

import 'package:sqflite/sqflite.dart';

import 'package:path/path.dart';

/// 数据库管理
class SqlManager {
  /// 版本号
  static const _VERSION = 1;

  /// 文件名
  static const NAME = "nian.db";

  /// 链接实例
  static Database? _database;

  ///初始化
  static init() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, NAME);

    await deleteDatabase(path);
    // var data = await rootBundle.load(join('assets', 'soulchat.db'));

    // List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    // // Write and flush the bytes written
    // await File(path).writeAsBytes(bytes, flush: true);
    _database = await openDatabase(
      path,
      version: _VERSION,
      onCreate: (Database db, int version) async {},
    );
  }

  /// 导出文件 [outPath] 导出文件路径
  static Future<void> export(String outPath) async {
    var databasesPath = await getDatabasesPath();
    var dbFileNames = [NAME, 'nian.db'];
    for (var name in dbFileNames) {
      String path = join(databasesPath, name);
      File file = File(path);
      if (file.existsSync()) {
        file.copy(outPath + name);
      }
    }
  }

  ///判断表是否存在
  static isTableExits(String tableName) async {
    await getCurrentDatabase();
    var res = await _database?.rawQuery("select * from Sqlite_master where type = 'table' and name = '$tableName'");
    return res != null && res.isNotEmpty;
  }

  /// 删除数据库
  static deleteSql({List? name}) async {
    var databasesPath = await getDatabasesPath();
    if (name != null) {
      name.add(NAME);
    } else {
      name = [NAME];
    }
    for (var i in name) {
      String path = join(databasesPath, i);
      await databaseExists(path).then((value) {
        if (value) {
          deleteDatabase(path);
        }
      });
    }
  }

  ///获取当前数据库对象
  static Future<Database> getCurrentDatabase() async {
    if (_database == null) {
      await init();
    }
    return _database!;
  }

  static getFilePath() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, "soulchat.db");
    return path;
  }

  ///关闭
  static close() {
    _database?.close();
    _database = null;
  }
}
