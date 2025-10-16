import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_frontend/data/db/app_database.dart';
import 'package:flutter_frontend/data/models/category_model.dart';
import 'package:flutter_frontend/data/models/budget_model.dart';
import 'package:flutter_frontend/data/models/transaction_model.dart';
import 'package:flutter_frontend/data/repositories/category_repository.dart';
import 'package:flutter_frontend/data/repositories/budget_repository.dart';
import 'package:flutter_frontend/data/repositories/transaction_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Repository CRUD smoke tests', () {
    setUp(() async {
      await AppDatabase.instance.init();
      // Clean slate between tests (best-effort; categories may have FKs)
      await TransactionRepository.instance.deleteAll();
      await BudgetRepository.instance.deleteAll();
      // no deleteAll on categories to preserve seed; tests handle by lookup
    });

    tearDown(() async {
      await AppDatabase.instance.close();
    });

    test('CategoryRepository create and list', () async {
      final created = await CategoryRepository.instance.create(
        const CategoryModel(name: 'Groceries', color: 0xFF2563EB),
      );
      expect(created.id, isNotNull);

      final categories = await CategoryRepository.instance.list();
      expect(categories.any((c) => c.name == 'Groceries'), isTrue);
    });

    test('BudgetRepository create and fetch', () async {
      // Ensure a category exists for the budget
      final category = await CategoryRepository.instance.create(
        const CategoryModel(name: 'Transport', color: 0xFFF59E0B),
      );

      final monthStart = DateTime(DateTime.now().year, DateTime.now().month, 1);
      final monthEnd = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);

      final budget = BudgetModel.monthly(
        categoryId: category.id!,
        amount: 200.0,
        monthStart: monthStart,
        monthEnd: monthEnd,
      );
      final created = await BudgetRepository.instance.create(budget);
      expect(created.id, isNotNull);

      final budgets = await BudgetRepository.instance.list(categoryId: category.id);
      expect(budgets.where((b) => b.amount == 200.0).isNotEmpty, isTrue);
    });

    test('TransactionRepository create, list, and delete', () async {
      final category = await CategoryRepository.instance.create(
        const CategoryModel(name: 'Utilities', color: 0xFF111827),
      );

      final txn = TransactionModel.onDate(
        categoryId: category.id!,
        amount: 45.50,
        note: 'Electricity bill',
        date: DateTime.now(),
      );

      final created = await TransactionRepository.instance.create(txn);
      expect(created.id, isNotNull);

      final all = await TransactionRepository.instance.list();
      expect(all.any((t) => (t.note ?? '').contains('Electricity')), isTrue);

      // Delete and assert removed
      final deleted = await TransactionRepository.instance.delete(created.id!);
      expect(deleted, isTrue);

      final afterDelete = await TransactionRepository.instance.list();
      expect(afterDelete.any((t) => t.id == created.id), isFalse);
    });
  });
}
