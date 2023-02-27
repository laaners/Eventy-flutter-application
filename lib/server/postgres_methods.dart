import 'package:dima_app/widgets/show_snack_bar.dart';
import 'package:postgres/postgres.dart';
import 'package:flutter/material.dart';
import 'package:crypt/crypt.dart';

class PostgresMethods {
  final PostgreSQLConnection _db;
  PostgresMethods(this._db);

  // Test
  Future test(BuildContext context) async {
    try {
      await _db.query(
        "insert into Users values(@aValue,@aValue,@aValue)",
        substitutionValues: {"aValue": 'a'},
      );
    } on PostgreSQLException catch (e) {
      debugPrint(e.message);
      showSnackBar(context, e.message!);
    }

    // Testing Injection resistance
    var results = await _db.mappedResultsQuery(
      "SELECT * FROM Users WHERE UserName != @aValue",
      substitutionValues: {
        "aValue":
            "a' UNION SELECT 'INJECTION', 'INJECTION', 'INJECTION', null; --"
      },
    );

    return results;
  }

  Future<List> users() async {
    var results = await _db.mappedResultsQuery(
      "SELECT * FROM Users",
    );
    return results;
  }

  // Add new user to the database in SignUpScreen
  Future insertUser(BuildContext context, String username, String name,
      String surname, String password) async {
    try {
      // todo: check if the username already exists, if is there already one in the db raise an error
      await _db.query(
        "insert into Users values(@usernameValue,@nameValue,@passwordValue)",
        substitutionValues: {
          "usernameValue": username,
          "nameValue": '$name $surname',
          // It hashes and adds a salt to the password to store in the db
          "passwordValue": Crypt.sha256(password, salt: username).toString(),
        },
      );
    } on PostgreSQLException catch (e) {
      debugPrint(e.message);
      showSnackBar(context, e.message!);
    }
  }

  // todo: add authentication logic
  Future authenticateUser(
      BuildContext context, String username, String password) async {
    try {
      // todo: check if the username already exists, if is there already one in the db raise an error
      await _db.query(
        "SELECT @usernameValue FROM Users WHERE Password = @passwordValue",
        substitutionValues: {
          "usernameValue": username,
          // It hashes and adds a salt to the password to store in the db
          "passwordValue": Crypt.sha256(password, salt: username).toString(),
        },
      );
    } on PostgreSQLException catch (e) {
      debugPrint(e.message);
      showSnackBar(context, e.message!);
    }
  }
}
