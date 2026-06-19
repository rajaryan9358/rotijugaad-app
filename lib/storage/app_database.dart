import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static const String _dbName = 'rotijugaad.db';
  static const int _dbVersion = 5;

  static Database? _db;

  static Future<Database> instance() async {
    final existing = _db;
    if (existing != null) return existing;

    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);

    final db = await openDatabase(
      path,
      version: _dbVersion,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'CREATE TABLE IF NOT EXISTS masters_salary_ranges (id INTEGER PRIMARY KEY, sequence INTEGER, json TEXT NOT NULL)',
          );
        }
        if (oldVersion < 3) {
          await db.execute(
            'CREATE TABLE IF NOT EXISTS masters_business_categories (id INTEGER PRIMARY KEY, sequence INTEGER, json TEXT NOT NULL)',
          );
        }
        if (oldVersion < 4) {
          await db.execute(
            'CREATE TABLE IF NOT EXISTS masters_vacancy_numbers (id INTEGER PRIMARY KEY, sequence INTEGER, json TEXT NOT NULL)',
          );
          await db.execute(
            'CREATE TABLE IF NOT EXISTS masters_job_benefits (id INTEGER PRIMARY KEY, sequence INTEGER, json TEXT NOT NULL)',
          );
        }
        if (oldVersion < 5) {
          await db.execute(
            'CREATE TABLE IF NOT EXISTS masters_additional_document_types (id INTEGER PRIMARY KEY, sequence INTEGER, json TEXT NOT NULL)',
          );
        }
      },
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE masters_states (id INTEGER PRIMARY KEY, sequence INTEGER, json TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE masters_cities (id INTEGER PRIMARY KEY, state_id INTEGER, sequence INTEGER, json TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE masters_skills (id INTEGER PRIMARY KEY, sequence INTEGER, json TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE masters_qualifications (id INTEGER PRIMARY KEY, sequence INTEGER, json TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE masters_shifts (id INTEGER PRIMARY KEY, sequence INTEGER, json TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE masters_job_profiles (id INTEGER PRIMARY KEY, sequence INTEGER, json TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE masters_document_types (id INTEGER PRIMARY KEY, sequence INTEGER, json TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE masters_additional_document_types (id INTEGER PRIMARY KEY, sequence INTEGER, json TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE masters_work_natures (id INTEGER PRIMARY KEY, sequence INTEGER, json TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE masters_business_categories (id INTEGER PRIMARY KEY, sequence INTEGER, json TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE masters_experiences (id INTEGER PRIMARY KEY, sequence INTEGER, json TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE masters_salary_types (id INTEGER PRIMARY KEY, sequence INTEGER, json TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE masters_salary_ranges (id INTEGER PRIMARY KEY, sequence INTEGER, json TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE masters_distances (id INTEGER PRIMARY KEY, sequence INTEGER, json TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE masters_employee_call_experiences (id INTEGER PRIMARY KEY, sequence INTEGER, json TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE masters_employee_report_reasons (id INTEGER PRIMARY KEY, sequence INTEGER, json TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE masters_employer_call_experiences (id INTEGER PRIMARY KEY, sequence INTEGER, json TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE masters_employer_report_reasons (id INTEGER PRIMARY KEY, sequence INTEGER, json TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE masters_vacancy_numbers (id INTEGER PRIMARY KEY, sequence INTEGER, json TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE masters_job_benefits (id INTEGER PRIMARY KEY, sequence INTEGER, json TEXT NOT NULL)',
        );
      },
    );

    _db = db;
    return db;
  }

  static Future<void> close() async {
    final db = _db;
    _db = null;
    await db?.close();
  }

  static Future<void> delete() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);
    await close();
    await deleteDatabase(path);
  }
}
