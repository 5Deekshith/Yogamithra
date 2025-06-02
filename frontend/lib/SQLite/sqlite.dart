import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:yoga_mithra/JsonModels/note_model.dart';
import 'package:yoga_mithra/JsonModels/users.dart';

class DatabaseHelper {
  final databaseName = "yoga_mithra.db";
  //Now we must create our user table into our sqlite db

  String users =
      "create table users (usrId INTEGER PRIMARY KEY AUTOINCREMENT, usrName TEXT UNIQUE, email TEXT UNIQUE, mobileNumber INTEGER UNIQUE, usrPassword TEXT)";

  //We are done in this section

  Future<Database> initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);

    return openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(users);
    });
  }

  //Now we create login and sign up method
  //as we create sqlite other functionality in our previous video

  //IF you didn't watch my previous videos, check part 1 and part 2

  //Login Method

  Future<Users?> login(Users user) async {
    final Database db = await initDB();

    var result = await db.rawQuery(
        "select * from users where usrName = '${user.usrName}' OR email = '${user.email}' OR mobileNumber = '${user.mobileNumber}' AND usrPassword = '${user.usrPassword}'");
    if (result.isNotEmpty) {
      Users userLoggedIn = Users.fromMap(result.first);
      return userLoggedIn;
    } else {
      return null;
    }
  }

  //Sign up
  Future<int> signup(Users user) async {
    final Database db = await initDB();

    return db.insert('users', user.toMap());
  }

  //Search Method
  Future<List<NoteModel>> searchNotes(String keyword) async {
    final Database db = await initDB();
    List<Map<String, Object?>> searchResult = await db.rawQuery(
        "select * from yoga_mithra where noteTitle LIKE ?", ["%$keyword%"]);
    return searchResult.map((e) => NoteModel.fromMap(e)).toList();
  }

  //CRUD Methods

  //Create Note
  Future<int> createNote(NoteModel note) async {
    final Database db = await initDB();
    return db.insert('yoga_mithra', note.toMap());
  }

  //Get yoga_mithra
  Future<List<NoteModel>> getNotes() async {
    final Database db = await initDB();
    List<Map<String, Object?>> result = await db.query('yoga_mithra');
    return result.map((e) => NoteModel.fromMap(e)).toList();
  }

  //Delete yoga_mithra
  Future<int> deleteNote(int id) async {
    final Database db = await initDB();
    return db.delete('yoga_mithra', where: 'noteId = ?', whereArgs: [id]);
  }

  //Update yoga_mithra
  Future<int> updateNote(title, content, noteId) async {
    final Database db = await initDB();
    return db.rawUpdate(
        'update yoga_mithra set noteTitle = ?, noteContent = ? where noteId = ?',
        [title, content, noteId]);
  }
}