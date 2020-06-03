import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:morgan_ppre/debounce.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DiaryEntry {
  final String day;
  int numGlassesOfWater;

  Meal breakfast;
  Meal lunch;
  Meal afternoonSnack;
  Meal dinner;
  Meal eveningSnack;

  List<Exercise> exercises;

  DiaryEntry({this.day, this.numGlassesOfWater})
  : breakfast = Meal('breakfast')
  , lunch = Meal('lunch')
  , afternoonSnack = Meal('afternoon_snack')
  , dinner = Meal('dinner')
  , eveningSnack = Meal('evening_snack')
  , exercises = [];

  DiaryEntry.fromJson(Map<String, dynamic> json)
    : day = json['day']
    , numGlassesOfWater = json['num_glasses_of_water']
    , breakfast = Meal.fromJson(jsonDecode(json['breakfast']))
    , lunch = Meal.fromJson(jsonDecode(json['lunch']))
    , afternoonSnack = Meal.fromJson(jsonDecode(json['afternoon_snack']))
    , dinner = Meal.fromJson(jsonDecode(json['dinner']))
    , eveningSnack = Meal.fromJson(jsonDecode(json['evening_snack']))
    , exercises = []
  {
    Iterable lst = jsonDecode(json['exercises']);
    List<Exercise> exers = lst.map<Exercise>((e) => Exercise.fromJson(e)).toList();
    exercises = exers;
  }

  Map<String, dynamic> toMap() {
    log('inside DiaryEntry.toMap()');
    log('numGlassesOfWater is ' + numGlassesOfWater.toString());
    log('jsonEncode(exercises) is ' + jsonEncode(exercises.map((e) => e.toMap()).toList()));
    return {
      'day': day,
      'num_glasses_of_water': numGlassesOfWater,
      'breakfast': jsonEncode(breakfast.toMap()),
      'lunch': jsonEncode(lunch.toMap()),
      'afternoon_snack': jsonEncode(afternoonSnack.toMap()),
      'dinner': jsonEncode(dinner.toMap()),
      'evening_snack': jsonEncode(eveningSnack.toMap()),
      'exercises':  jsonEncode(exercises.map((e) => e.toMap()).toList())
    };
  }

  Meal operator[](String key) {
    return (
      key == 'Breakfast' ? this.breakfast :
      key == 'Lunch' ? this.lunch :
      key == 'Afternoon Snack' ? this.afternoonSnack :
      key == 'Dinner' ? this.dinner :
      key == 'Evening Snack' ? this.eveningSnack :
      null
    );
  }
}

class Meal {
  String name;
  int protein;
  int grains;
  int produce;
  int fats;

  String notes;

  Meal(this.name)
  : protein = 0
  , grains = 0
  , produce = 0
  , fats = 0
  , notes = "";

  Meal.fromJson(Map<String, dynamic> json)
    : name = json['name']
    , protein = json['protein']
    , grains = json['grains']
    , produce = json['produce']
    , fats = json['fats']
    , notes = json['notes'];

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'protein': protein,
      'grains': grains,
      'produce': produce,
      'fats': fats,
      'notes': notes,
    };
  }

  void update({ int protein, int grains, int produce, int fats, String notes }) {
    if (protein != null) this.protein = protein;
    if (grains != null) this.grains = grains;
    if (produce != null) this.produce = produce;
    if (fats != null) this.fats = fats;
    if (notes != null) this.notes = notes;
  }
}

class Exercise {
  final String activity;
  final String reps;
  final String time;

  Exercise({this.activity, this.reps, this.time});

  Exercise.fromJson(Map<String, dynamic> json)
    : activity = json['activity']
    , reps = json['reps']
    , time = json['time'];

  Map<String, dynamic> toMap() {
    return {
      'activity': activity,
      'reps': reps,
      'time': time,
    };
  }
}

Future<Database> getDb() async {
  var dbPath = join(await getDatabasesPath(), 'food_diary.db');
  return openDatabase(
    dbPath,
    onCreate: (db, version) {
      return db.execute('''
        CREATE TABLE diary_entries(
          day TEXT PRIMARY KEY,
          num_glasses_of_water INTEGER NOT NULL DEFAULT (0),

          breakfast TEXT NOT NULL,
          lunch TEXT NOT NULL,
          afternoon_snack TEXT NOT NULL,
          dinner TEXT NOT NULL,
          evening_snack TEXT NOT NULL,

          exercises TEXT NOT NULL
        );
      ''');
    },
    version: 1
  );
}

Future<void> upsertEntry(Database db, DiaryEntry diary) async {
  await db.insert('diary_entries', diary.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
}

Future<DiaryEntry> getTodaysEntry(Database db) async {
  log('db is ' + db.toString());
  return db.rawQuery('''
    SELECT * from diary_entries
    WHERE day = DATE('now')
  ''')
  .then((ds) {
    if (ds.length == 0) {
      var now = DateTime.now();
      var formatter = new DateFormat('yyyy-MM-dd');
      return DiaryEntry(day: formatter.format(now), numGlassesOfWater: 0);
    }
    return DiaryEntry.fromJson(ds.first);
  });
}

Future<List<DiaryEntry>> lastSevenDays(Database db) async {
  return db.rawQuery('''
    SELECT * FROM diary_entries
    WHERE day > DATE('now', '-7 day')
      AND day < DATE('now')
  ''').then((ds) => ds.map((d) => DiaryEntry.fromJson(d)).toList());
}


class MealModel extends ChangeNotifier {
  Database _db;
  MealModel() {
    getDb()
    .then((db) {
      _db = db;
      return getTodaysEntry(db);
    })
    .then((ntry) {
      entry = ntry;
      notifyListeners(skipSave: true);
    });
  }
  DiaryEntry entry;

  void notifyListeners({ bool skipSave = false }) {
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

  void update(String mealName, { int protein, int grains, int produce, int fats, String notes }) {
    log('mealName ' + mealName);
    log('entry ' + entry[mealName].toString());
    entry[mealName].update(protein: protein, grains: grains, produce: produce, fats: fats, notes: notes);
    notifyListeners();
  }
}
