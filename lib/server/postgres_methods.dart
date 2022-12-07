import 'package:dima_app/widgets/show_snack_bar.dart';
import 'package:postgres/postgres.dart';
import 'package:flutter/material.dart';

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
}
