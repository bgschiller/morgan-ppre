import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:morgan_ppre/meal.dart';
import 'package:morgan_ppre/ppre_icons_icons.dart';
import 'dart:math' as math;

import 'package:provider/provider.dart';

import 'db.dart';

String dayOfWeek(String date) {
  return DateFormat.E().format(DateTime.parse(date));
}

String dailySummary(String foodGroup, PastEntry pe) {
  if (pe.entry == null) return '—';
  int actual = 0;
  int expected = 0;
  for (var meal in mealSpecs) {
    actual += pe.entry[meal.name][foodGroup];
    expected += meal.plan[foodGroup].needed;
  }
  if (actual >= expected) return '💯';
  if (actual == 0) return '0';
  var pct = (actual.toDouble() * 100 / expected).round();
  return '$pct%';
}

// String avgSummary(String foodGroup, List<PastEntry> days) {
//   int actual = 0;
//   int expected = 0;
//   for (var meal in mealSpecs) {
//     for (var day in days) {
//       if (day.entry == null) continue;
//       actual += day.entry[meal.name][foodGroup];
//       expected += meal.plan[foodGroup].needed;
//     }
//   }
// }

class WeeklyLogPage extends StatelessWidget {
  final double textAngle = -math.pi * 2 / 5;

  TableRow averageRow(List<PastEntry> days) {
    return TableRow(children: [
      Spacer(), // day label
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Weekly Log"), backgroundColor: Colors.teal),
        body: Consumer<MealModel>(
            builder: (context, meal, child) => Container(
                padding: EdgeInsets.all(15),
                child: Table(
                    defaultVerticalAlignment: TableCellVerticalAlignment.top,
                    children: [
                      TableRow(children: [
                        SizedBox(height: 40),
                        SizedBox(height: 40),
                        SizedBox(height: 40),
                        SizedBox(height: 40),
                        SizedBox(height: 40),
                        SizedBox(height: 40),
                        SizedBox(height: 40),
                      ]),
                      TableRow(children: [
                        TableCell(child: SizedBox(height: 60)), // day label
                        Transform.rotate(
                            angle: textAngle,
                            child: Text(
                              "Protein",
                              overflow: TextOverflow.visible,
                              maxLines: 1,
                            )),
                        Transform.rotate(
                            angle: textAngle,
                            child: Text(
                              "Grains",
                              overflow: TextOverflow.visible,
                              maxLines: 1,
                            )),
                        Transform.rotate(
                            angle: textAngle,
                            child: Text(
                              "Produce",
                              overflow: TextOverflow.visible,
                              maxLines: 1,
                            )),
                        Transform.rotate(
                            angle: textAngle,
                            child: Text(
                              "Fats",
                              overflow: TextOverflow.visible,
                              maxLines: 1,
                            )),
                        Spacer(), // Exercise icon, or empty
                        Spacer(), // Water icon, or empty
                      ]),
                      ...meal.lastSevenDays.map((day) {
                        return TableRow(children: [
                          SizedBox(child: Text(dayOfWeek(day.day)), height: 50),
                          Text(dailySummary('protein', day)),
                          Text(dailySummary('grains', day)),
                          Text(dailySummary('produce', day)),
                          Text(dailySummary('fats', day)),
                          ((day?.entry?.exercises ?? '') != '')
                              ? Icon(Icons.star, color: Colors.deepPurple)
                              : Spacer(),
                          ((day?.entry?.numGlassesOfWater ?? 0) >= 8)
                              ? Icon(PpreIcons.water_drop, color: Colors.blue)
                              : Spacer(),
                        ]);
                      }),
                      // averageRow(meal.lastSevenDays),
                    ]))));
  }
}
