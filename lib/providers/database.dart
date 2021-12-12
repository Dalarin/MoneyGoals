import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:moneygoals/models/goals.dart';
import 'package:moneygoals/models/contributions.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();

  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('goals.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
        CREATE TABLE $goal_tablename (
          ${GoalsFields.id} $idType,
          ${GoalsFields.title} $textType,
          ${GoalsFields.amount} $textType,
          ${GoalsFields.date} $textType,
          ${GoalsFields.icon} $textType,
          ${GoalsFields.status} $integerType
        )
        ''');
    await db.execute('''
        CREATE TABLE $contributions_tablename (
          ${ContributionsFields.id} $idType,
          ${ContributionsFields.id_goal} $integerType,
          ${ContributionsFields.amount} $textType,
          ${ContributionsFields.date} $textType,
          ${ContributionsFields.comment} $textType,
          FOREIGN KEY(${ContributionsFields.id_goal}) REFERENCES $goal_tablename(${GoalsFields.id})
        )
    ''');
  }

  Future<Goals> createGoal(Goals goals) async {
    final db = await instance.database;
    final id = await db.insert(goal_tablename, goals.toJson());
    return goals.copy(id: id);
  }

  Future<Goals> readGoal(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      goal_tablename,
      columns: GoalsFields.values,
      where: '${GoalsFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Goals.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Goals>> readAllGoals() async {
    final db = await instance.database;
    final result = await db.query(goal_tablename);
    return result.map((json) => Goals.fromJson(json)).toList();
  }

  Future<int> updateGoal(int status, int idGoal) async {
    final db = await instance.database;

    return db.rawUpdate(
        'UPDATE ${goal_tablename} SET ${GoalsFields.status} = ? WHERE ${GoalsFields.id} = ?',
        [status, idGoal]);
  }

  Future<int> deleteGoal(int id) async {
    final db = await instance.database;
    deleteContributions(id);
    return await db.delete(
      goal_tablename,
      where: '${GoalsFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteContribution(int id) async {
    final db = await instance.database;
    return await db.delete(
      contributions_tablename,
      where: '${ContributionsFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteContributions(int idGoal) async {
    final db = await instance.database;
    return await db.delete(
      contributions_tablename,
      where: '${ContributionsFields.id_goal} = ?',
      whereArgs: [idGoal],
    );
  }

  Future<List<Contributions>> readAllContributions(int id_goal) async {
    final db = await instance.database;
    final result = await db.query(contributions_tablename,
        where: '${ContributionsFields.id_goal} = ?',
        whereArgs: [id_goal],
        orderBy: '${ContributionsFields.date} DESC');
    return result.map((json) => Contributions.fromJson(json)).toList();
  }

  Future<List<Contributions>> readAllAmountContributionsID() async {
    final db = await instance.database;
    final result = await db.query(contributions_tablename);
    return result.map((json) => Contributions.fromJson(json)).toList();
  }

  Future<Contributions> createContribution(Contributions contributions) async {
    final db = await instance.database;
    final id = await db.insert(contributions_tablename, contributions.toJson());
    return contributions.copy(id: id);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
