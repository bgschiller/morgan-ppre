import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:morgan_ppre/debounce.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DiaryEntry {
  final String day;
  int numGlassesOfWater;

  Meal breakfast;
  Meal morningSnack;
  Meal lunch;
  Meal afternoonSnack;
  Meal dinner;
  Meal eveningSnack;

  String exercises;

  DiaryEntry({this.day = '', this.numGlassesOfWater = 0})
      : breakfast = Meal('breakfast'),
        morningSnack = Meal('morning_snack'),
        lunch = Meal('lunch'),
        afternoonSnack = Meal('afternoon_snack'),
        dinner = Meal('dinner'),
        eveningSnack = Meal('evening_snack'),
        exercises = '';

  DiaryEntry.fromJson(Map<String, dynamic> json)
      : day = json['day'],
        numGlassesOfWater = json['num_glasses_of_water'],
        breakfast = Meal.fromJson(jsonDecode(json['breakfast'])),
        morningSnack = Meal.fromJson(jsonDecode(json['morning_snack'])),
        lunch = Meal.fromJson(jsonDecode(json['lunch'])),
        afternoonSnack = Meal.fromJson(jsonDecode(json['afternoon_snack'])),
        dinner = Meal.fromJson(jsonDecode(json['dinner'])),
        eveningSnack = Meal.fromJson(jsonDecode(json['evening_snack'])),
        exercises = json['exercises'];

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'num_glasses_of_water': numGlassesOfWater,
      'breakfast': jsonEncode(breakfast.toMap()),
      'morning_snack': jsonEncode(morningSnack.toMap()),
      'lunch': jsonEncode(lunch.toMap()),
      'afternoon_snack': jsonEncode(afternoonSnack.toMap()),
      'dinner': jsonEncode(dinner.toMap()),
      'evening_snack': jsonEncode(eveningSnack.toMap()),
      'exercises': exercises,
    };
  }

  Meal operator [](String key) {
    return (key == 'Breakfast'
        ? this.breakfast
        : key == 'Morning Snack'
            ? this.morningSnack
            : key == 'Lunch'
                ? this.lunch
                : key == 'Afternoon Snack'
                    ? this.afternoonSnack
                    : key == 'Dinner'
                        ? this.dinner
                        : key == 'Evening Snack'
                            ? this.eveningSnack
                            : null);
  }
}

class Meal {
  String name;
  int protein;
  int starch;
  int produce;
  int veg;
  int fruitOrVeg;
  int dairy;
  int fats;

  Meal(this.name)
      : protein = 0,
        starch = 0,
        produce = 0,
        fats = 0,
        veg = 0,
        fruitOrVeg = 0,
        dairy = 0;

  Meal.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        protein = json['protein'],
        starch = json['starch'],
        produce = json['produce'],
        fats = json['fats'],
        veg = json['veg'],
        fruitOrVeg = json['fruitOrVeg'],
        dairy = json['dairy'];

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'protein': protein,
      'starch': starch,
      'produce': produce,
      'fats': fats,
      'veg': veg,
      'fruitOrVeg': fruitOrVeg,
      'dairy': dairy,
    };
  }

  void update(
      {int protein,
      int starch,
      int produce,
      int fats,
      int veg,
      int fruitOrVeg,
      int dairy}) {
    if (protein != null) this.protein = protein;
    if (starch != null) this.starch = starch;
    if (produce != null) this.produce = produce;
    if (fats != null) this.fats = fats;
    if (veg != null) this.veg = veg;
    if (fruitOrVeg != null) this.fruitOrVeg = fruitOrVeg;
    if (dairy != null) this.dairy = dairy;
  }

  int operator [](String key) {
    return (key == 'protein'
        ? protein
        : key == 'starch'
            ? starch
            : key == 'produce'
                ? produce
                : key == 'fats'
                    ? fats
                    : key == 'veg'
                        ? veg
                        : key == 'fruitOrVeg'
                            ? fruitOrVeg
                            : key == 'dairy'
                                ? dairy
                                : 0);
  }
}

Future<Database> getDb() async {
  var dbPath = join(await getDatabasesPath(), 'food_diary.db');
  return openDatabase(dbPath, version: 1, onCreate: (db, version) {
    return db.execute('''
        CREATE TABLE diary_entries(
          day TEXT PRIMARY KEY,
          num_glasses_of_water INTEGER NOT NULL DEFAULT (0),

          breakfast TEXT NOT NULL,
          morning_snack TEXT NOT NULL,
          lunch TEXT NOT NULL,
          afternoon_snack TEXT NOT NULL,
          dinner TEXT NOT NULL,
          evening_snack TEXT NOT NULL,

          exercises TEXT NOT NULL
        );
      ''');
  }, onUpgrade: (db, version, otherVersionNotSureWhichIsNew) {
    return db.execute('''
      ALTER TABLE diary_entries ADD COLUMN morning_snack TEXT NOT NULL;
  ''');
  });
}

Future<void> upsertEntry(Database db, DiaryEntry diary) async {
  await db.insert('diary_entries', diary.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace);
}

Future<DiaryEntry> getTodaysEntry(Database db) async {
  return db.rawQuery('''
    SELECT * from diary_entries
    WHERE day = DATE('now', 'localtime')
  ''').then((ds) {
    if (ds.length == 0) {
      var now = DateTime.now();
      var formatter = new DateFormat('yyyy-MM-dd');
      return DiaryEntry(day: formatter.format(now), numGlassesOfWater: 0);
    }
    return DiaryEntry.fromJson(ds.first);
  });
}

class MealModel extends ChangeNotifier {
  Database _db;
  MealModel() {
    var dbp = getDb();
    dbp.then((db) {
      _db = db;
    });
    dbp.then(getTodaysEntry).then((ntry) {
      entry = ntry;
      notifyListeners(skipSave: true);
    });
  }
  DiaryEntry entry;

  void notifyListeners({bool skipSave = false}) {
    super.notifyListeners();
    if (!skipSave) debounce(300, _save, []);
  }

  void _save() {
    upsertEntry(_db, entry);
  }

  void updateNumGlassesOfWater(int glasses) {
    entry.numGlassesOfWater = glasses;
    notifyListeners();
  }

  void update(String mealName, Map<String, int> kwargs) {
    entry[mealName].update(
        protein: kwargs['protein'],
        starch: kwargs['starch'],
        produce: kwargs['produce'],
        fats: kwargs['fats'],
        veg: kwargs['veg'],
        fruitOrVeg: kwargs['fruitOrVeg'],
        dairy: kwargs['dairy']);
    notifyListeners();
  }

  void setExercise(String exercise) {
    entry.exercises = exercise;
    notifyListeners();
  }
}
