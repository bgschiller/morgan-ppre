import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:morgan_ppre/debounce.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class PastEntry {
  final String day;
  DiaryEntry entry;
  PastEntry({ @required this.day, this.entry });

  PastEntry.fromJson(Map<String, dynamic> json)
    : day = json['past_day']
  {
    if (json['num_glasses_of_water']) {
      entry = DiaryEntry.fromJson(json);
    } else {
      entry = null;
    }
  }
}

class DiaryEntry {
  final String day;
  int numGlassesOfWater;

  Meal breakfast;
  Meal lunch;
  Meal afternoonSnack;
  Meal dinner;
  Meal eveningSnack;

  String exercises;

  DiaryEntry({this.day, this.numGlassesOfWater})
  : breakfast = Meal('breakfast')
  , lunch = Meal('lunch')
  , afternoonSnack = Meal('afternoon_snack')
  , dinner = Meal('dinner')
  , eveningSnack = Meal('evening_snack')
  , exercises = '';

  DiaryEntry.fromJson(Map<String, dynamic> json)
    : day = json['day']
    , numGlassesOfWater = json['num_glasses_of_water']
    , breakfast = Meal.fromJson(jsonDecode(json['breakfast']))
    , lunch = Meal.fromJson(jsonDecode(json['lunch']))
    , afternoonSnack = Meal.fromJson(jsonDecode(json['afternoon_snack']))
    , dinner = Meal.fromJson(jsonDecode(json['dinner']))
    , eveningSnack = Meal.fromJson(jsonDecode(json['evening_snack']))
    , exercises = json['exercises'];

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'num_glasses_of_water': numGlassesOfWater,
      'breakfast': jsonEncode(breakfast.toMap()),
      'lunch': jsonEncode(lunch.toMap()),
      'afternoon_snack': jsonEncode(afternoonSnack.toMap()),
      'dinner': jsonEncode(dinner.toMap()),
      'evening_snack': jsonEncode(eveningSnack.toMap()),
      'exercises':  exercises,
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

  int operator[](String key) {
    return (
      key == 'protein' ? protein :
      key == 'grains' ? grains :
      key == 'produce' ? produce :
      key == 'fats' ? fats :
      null
    );
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
  return db.rawQuery('''
    SELECT * from diary_entries
    WHERE day = DATE('now', 'localtime')
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

Future<List<PastEntry>> getLastSevenDays(Database db) async {
  return db.rawQuery('''
  WITH RECURSIVE last_seven(ix, past_day) AS (
    SELECT -1, DATE('now', 'localtime', '-1 day')
   UNION ALL
    SELECT ix - 1, DATE('now', 'localtime', (ix - 1) || ' day')
    WHERE ix - 1 > -8
  )
  SELECT past_day, de.*
  FROM last_seven ls
  LEFT JOIN diary_entry de
  ON (ls.past_day = de.day)
  ''').then((ds) => ds.map((d) => PastEntry.fromJson(d)).toList());
}


class MealModel extends ChangeNotifier {
  Database _db;
  MealModel() {
    var dbp = getDb();
    dbp
      .then((db) {
        _db = db;
      });
    dbp
      .then(getTodaysEntry)
      .then((ntry) {
        entry = ntry;
        notifyListeners(skipSave: true);
      });
    dbp
      .then(getLastSevenDays)
      .then((days) {
        lastSevenDays = days;
      });
  }
  DiaryEntry entry;
  List<PastEntry> lastSevenDays = [
    PastEntry(day: '2020-06-09', entry: DiaryEntry.fromJson({
      'day': '2020-06-09',
      'num_glasses_of_water': 8,
      'breakfast': '''{
        "name": "breakfast",
        "protein": 3,
        "grains": 2,
        "produce": 1,
        "fats": 1,
        "notes": ""
      }''',
      "lunch": '''{
        "name": "lunch",
        "protein": 2,
        "grains": 4,
        "produce": 2,
        "fats": 2,
        "notes": ""
      }''',
      "afternoon_snack": '''{
        "name": "afternoon_snack",
        "protein": 1,
        "grains": 2,
        "produce": 1,
        "fats": 0,
        "notes": ""
      }''',
      "dinner": '''{
        "name": "dinner",
        "protein": 3,
        "grains": 2,
        "produce": 2,
        "fats": 1,
        "notes": ""
      }''',
      "evening_snack": '''{
        "name": "evening_snack",
        "protein": 3,
        "grains": 2,
        "produce": 1,
        "fats": 1,
        "notes": ""
      }''',
      'exercises': 'nope',
    })
    ),
    PastEntry(day: '2020-06-08', entry: DiaryEntry.fromJson({
      'day': '2020-06-08',
      'num_glasses_of_water': 8,
      'breakfast': '''{
        "name": "breakfast",
        "protein": 2,
        "grains": 2,
        "produce": 2,
        "fats": 0,
        "notes": ""
      }''',
      "lunch": '''{
        "name": "lunch",
        "protein": 1,
        "grains": 0,
        "produce": 2,
        "fats": 1,
        "notes": ""
      }''',
      "afternoon_snack": '''{
        "name": "afternoon_snack",
        "protein": 0,
        "grains": 0,
        "produce": 0,
        "fats": 1,
        "notes": ""
      }''',
      "dinner": '''{
        "name": "dinner",
        "protein": 2,
        "grains": 1,
        "produce": 0,
        "fats": 1,
        "notes": ""
      }''',
      "evening_snack": '''{
        "name": "evening_snack",
        "protein": 3,
        "grains": 2,
        "produce": 1,
        "fats": 1,
        "notes": ""
      }''',
      'exercises': '',
    })
    ),
    PastEntry(day: '2020-06-07', entry: null),
    PastEntry(day: '2020-06-06', entry: DiaryEntry.fromJson({
      'day': '2020-06-06',
      'num_glasses_of_water': 5,
      'breakfast': '''{
        "name": "breakfast",
        "protein": 1,
        "grains": 2,
        "produce": 2,
        "fats": 1,
        "notes": ""
      }''',
      "lunch": '''{
        "name": "lunch",
        "protein": 1,
        "grains": 0,
        "produce": 1,
        "fats": 1,
        "notes": ""
      }''',
      "afternoon_snack": '''{
        "name": "afternoon_snack",
        "protein": 0,
        "grains": 2,
        "produce": 0,
        "fats": 1,
        "notes": ""
      }''',
      "dinner": '''{
        "name": "dinner",
        "protein": 2,
        "grains": 1,
        "produce": 0,
        "fats": 1,
        "notes": ""
      }''',
      "evening_snack": '''{
        "name": "evening_snack",
        "protein": 3,
        "grains": 2,
        "produce": 1,
        "fats": 1,
        "notes": ""
      }''',
      'exercises': 'yep',
    })
    )
  ];

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
    entry[mealName].update(protein: protein, grains: grains, produce: produce, fats: fats, notes: notes);
    notifyListeners();
  }

  void setExercise(String exercise) {
    entry.exercises = exercise;
    notifyListeners();
  }
}
