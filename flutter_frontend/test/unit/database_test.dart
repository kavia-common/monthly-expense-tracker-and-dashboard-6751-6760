import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';

import 'package:flutter_frontend/data/db/app_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppDatabase - initialization and schema', () {
    setUp(() async {
      // Ensure database is initialized using the singleton as the app does.
      await AppDatabase.instance.init();
    });

    tearDown(() async {
      // Close after each group/test to release handles for analyzer.
      await AppDatabase.instance.close();
    });

    test('opens database and contains expected tables', () async {
      final Database db = AppDatabase.instance.db;

      // Query sqlite master to list tables
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;",
      );
      final tableNames = tables.map((row) => (row['name'] ?? '').toString()).toList();

      // Expected tables based on models/repositories in the app
      final expected = <String>{
        'categories',
        'budgets',
        'transactions',
      };

      for (final t in expected) {
        expect(tableNames, contains(t), reason: 'Missing table: $t');
      }
    });
  });
}
