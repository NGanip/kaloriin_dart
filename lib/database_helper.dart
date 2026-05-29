import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'food_data.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;
  static Database? _db;

  Future<Database> get db async {
    _db ??= await initDb();
    return _db!;
  }

  DatabaseHelper.internal();

  initDb() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "food_database.db");
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  void _onCreate(Database db, int newVersion) async {
    await db.execute(
      'CREATE TABLE food_data(id INTEGER PRIMARY KEY, name TEXT, weight REAL, calories REAL)',
    );
  }

  Future<int> saveFoodData(FoodData foodData) async {
    var dbClient = await db;
    int res = await dbClient.insert("food_data", foodData.toMap());
    return res;
  }

  Future<List<Map>> getFoodMapList() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM food_data');
    return list;
  }

  Future<List<FoodData>> getFoodDataList() async {
    var dbClient = await db;
    List<Map<String, dynamic>> list = await dbClient.rawQuery('SELECT * FROM food_data');
    List<FoodData> foodDataList =
        list.map((foodData) => FoodData.fromMap(foodData)).toList();
    return foodDataList;
  }

  Future<int> deleteFoodData(int id) async {
    var dbClient = await db;
    int res = await dbClient.delete("food_data", where: "id = ?", whereArgs: [id]);
    return res;
  }

  Future<int> updateFoodData(FoodData foodData) async {
    var dbClient = await db;
    int res = await dbClient.update("food_data", foodData.toMap(),
        where: "id = ?", whereArgs: [foodData.id]);
    return res;
  }

  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }
}
