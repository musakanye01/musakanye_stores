import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';

import 'package:pos_tablet/data/local/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('Inspect local SQLite tables, columns and foreign keys', () async {
    final tables = await db.customSelect('''
      SELECT name
      FROM sqlite_master
      WHERE type = 'table'
        AND name NOT LIKE 'sqlite_%'
      ORDER BY name
    ''').get();

    final schema = <Map<String, dynamic>>[];

    for (final table in tables) {
      final tableName = table.read<String>('name');

      // SQLite table names come from sqlite_master.
      final columns = await db
          .customSelect('PRAGMA table_info("$tableName")')
          .get();

      final foreignKeys = await db
          .customSelect('PRAGMA foreign_key_list("$tableName")')
          .get();

      schema.add({
        'table': tableName,
        'columns': columns
            .map(
              (column) => {
                'name': column.read<String>('name'),
                'type': column.read<String>('type'),
                'notNull': column.read<int>('notnull') == 1,
                'default': column.readNullable<String>('dflt_value'),
                'primaryKeyPosition': column.read<int>('pk'),
              },
            )
            .toList(),

        'foreignKeys': foreignKeys
            .map(
              (fk) => {
                'referencedTable': fk.read<String>('table'),
                'fromColumn': fk.read<String>('from'),
                'toColumn': fk.read<String>('to'),
                'onUpdate': fk.read<String>('on_update'),
                'onDelete': fk.read<String>('on_delete'),
              },
            )
            .toList(),
      });
    }

    // Print machine-readable output.
    // Run with --reporter expanded to see it.
    print('\n===== LOCAL DRIFT DATABASE SCHEMA =====');
    print(const JsonEncoder.withIndent('  ').convert(schema));
    print('===== END SCHEMA =====\n');

    expect(tables, isNotEmpty);
  });
}
