import 'dart:io';
import 'package:rx_view/models/app_policy/app_policy_mod.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppPolicyDb{
  AppPolicyDb._private();
  static final AppPolicyDb instance = AppPolicyDb._private();

  Database? database;
  Future<Database> get getDatabase async => database ??= await initDatabase();

  Future<Database> initDatabase()async{
    Directory supportDirectory = await getApplicationSupportDirectory();
    String path = join(supportDirectory.path,'apppolicydb.db');

    return await openDatabase(path,version: 1,onCreate: onCreate,);
  }

  Future onCreate(Database db, int version)async{
    await db.execute("""
    CREATE TABLE apppolicydb(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    policyID TEXT,
    policyText TEXT,
    policyValue INTEGER,
    apValueFg INTEGER,
    policyVisibilityFg INTEGER,
    globalPermissionFg INTEGER
    )
    """);
  }

  Future<int> addData(AppPolicyModel appPolicyModel)async{
    Database db = await instance.getDatabase;
    return await db.insert('apppolicydb', appPolicyModel.toJson());
  }

  Future<List<AppPolicyModel>> getData()async{
    Database db = await instance.getDatabase;
    var policy = await db.query('apppolicydb',orderBy: 'id');

    List<AppPolicyModel> appPolicy = policy.isNotEmpty? policy.map((e) => AppPolicyModel.fromJson(e)).toList():[];
    return appPolicy;
  }

  Future deleteAll() async {
    Database db = await instance.getDatabase;
    print('object delete from apppolicydb');
    return await db.rawDelete("Delete from apppolicydb");
  }
}