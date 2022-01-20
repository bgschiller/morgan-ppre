import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:morgan_ppre/db.dart';
import 'package:morgan_ppre/ppre_icons_icons.dart';
import 'package:provider/provider.dart';

class NutritionalRqmt {
  final int needed;
  final int optional = 0;
  NutritionalRqmt({@required this.needed});
}

class MealPlan {
  final NutritionalRqmt protein;
  final NutritionalRqmt starch;
  final NutritionalRqmt veg;
  final NutritionalRqmt fruitOrVeg;
  final NutritionalRqmt fats;
  final NutritionalRqmt dairy;

  MealPlan(
      {this.protein,
      this.starch,
      this.veg,
      this.fruitOrVeg,
      this.fats,
      this.dairy});

  NutritionalRqmt operator [](String key) {
    return (key == 'protein'
        ? protein
        : key == 'starch'
            ? starch
            : key == 'veg'
                ? veg
                : key == 'fruitOrVeg'
                    ? fruitOrVeg
                    : key == 'fats'
                        ? fats
                        : key == 'dairy'
                            ? dairy
                            : null);
  }
}

class MealSpec {
  final String name;
  final Color color;
  final MealPlan plan;
  MealSpec({
    @required this.name,
    @required this.color,
    @required this.plan,
  });
}

var mealSpecs = [
  MealSpec(
      name: "Breakfast",
      color: Colors.pink,
      plan: MealPlan(
        starch: NutritionalRqmt(needed: 3),
        protein: NutritionalRqmt(needed: 3),
        fats: NutritionalRqmt(needed: 1),
        fruitOrVeg: NutritionalRqmt(needed: 1),
        dairy: NutritionalRqmt(needed: 1),
      )),
  MealSpec(
      name: "Morning Snack",
      color: Colors.orange,
      plan: MealPlan(
        protein: NutritionalRqmt(needed: 1),
        fats: NutritionalRqmt(needed: 1),
        fruitOrVeg: NutritionalRqmt(needed: 1),
      )),
  MealSpec(
      name: "Lunch",
      color: Colors.red,
      plan: MealPlan(
        protein: NutritionalRqmt(needed: 3),
        veg: NutritionalRqmt(needed: 2),
        starch: NutritionalRqmt(needed: 3),
        fats: NutritionalRqmt(needed: 2),
        dairy: NutritionalRqmt(needed: 1),
      )),
  MealSpec(
      name: "Afternoon Snack",
      color: Colors.purple,
      plan: MealPlan(
        protein: NutritionalRqmt(needed: 1),
        fruitOrVeg: NutritionalRqmt(needed: 1),
        dairy: NutritionalRqmt(needed: 1),
      )),
  MealSpec(
      name: "Dinner",
      color: Colors.green,
      plan: MealPlan(
        protein: NutritionalRqmt(needed: 3),
        veg: NutritionalRqmt(needed: 2),
        starch: NutritionalRqmt(needed: 3),
        fats: NutritionalRqmt(needed: 1),
        dairy: NutritionalRqmt(needed: 1),
      )),
];

class MealButton extends StatelessWidget {
  MealButton({@required this.mealSpec});
  final MealSpec mealSpec;

  @override
  build(BuildContext context) {
    return FlatButton(
      child: Text(this.mealSpec.name),
      color: this.mealSpec.color,
      textColor: Colors.white,
      onPressed: () {
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => MealPage(mealSpec: this.mealSpec)));
      },
    );
  }
}

class MealPage extends StatelessWidget {
  MealPage({@required this.mealSpec});
  final MealSpec mealSpec;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Scaffold(
            appBar: AppBar(
                title: Text(this.mealSpec.name),
                backgroundColor: this.mealSpec.color),
            body: SingleChildScrollView(
              child: Consumer<MealModel>(
                  builder: (context, meal, child) => Center(
                          child: Column(
                        children: [
                          {
                            'title': 'Protein',
                            'accessor': 'protein',
                            'recs': """
                  1oz poultry or beef
                  2oz fish
                  1oz most cheese
                  ¼ cup ricotta or cottage cheese
                  egg w/ yolk
                  1-2 tbsp Peanut butter
                  ½ cup tofu
                  ½ patty veggie burger
                            """
                          },
                          {'title': 'Starch', 'accessor': 'starch'},
                          {'title': 'Veg', 'accessor': 'veg'},
                          {'title': 'Fruit/Veg', 'accessor': 'fruitOrVeg'},
                          {'title': 'Fats', 'accessor': 'fats'},
                          {'title': 'Dairy', 'accessor': 'dairy'},
                        ]
                            .where((nutrient) =>
                                this.mealSpec.plan[nutrient['accessor']] !=
                                null)
                            .map((nutrient) => ServingCheckboxRow(
                                  recs: nutrient['recs'] ?? 'yolo',
                                  title: nutrient['title'],
                                  counts:
                                      this.mealSpec.plan[nutrient['accessor']],
                                  onChange: (int newCount) {
                                    meal.update(this.mealSpec.name,
                                        {nutrient['accessor']: newCount});
                                  },
                                  color: this.mealSpec.color,
                                  value: meal.entry[this.mealSpec.name] != null
                                      ? meal.entry[this.mealSpec.name]
                                          [nutrient['accessor']]
                                      : null,
                                ))
                            .toList(),
                      ))),
            )));
  }
}

typedef void CheckboxRowChanged(int i);

class ServingCheckboxRow extends StatelessWidget {
  final String title;
  final String recs;
  final NutritionalRqmt counts;
  final int value;
  final Color color;
  final CheckboxRowChanged onChange;
  ServingCheckboxRow(
      {@required this.title,
      @required this.recs,
      @required this.counts,
      @required this.value,
      @required this.color,
      @required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Row(children: <Widget>[
      Container(
          width: 100,
          height: 30,
          margin: EdgeInsets.all(20),
          alignment: Alignment.centerLeft,
          child: GestureDetector(
              child: Text(this.title, style: TextStyle(fontSize: 20)),
              onLongPress: () {
                showDialog(
                    context: context,
                    builder: (context) => Dialog(
                        child: Container(
                            padding: EdgeInsets.all(20),
                            child: Text(this.recs))));
              })),
      ...List.generate(this.counts.needed + this.counts.optional, (ix) {
        var optional = ix >= this.counts.needed;
        var colour = optional ? this.color.withAlpha(80) : this.color;
        var completed = ix < this.value;
        var icon =
            completed ? PpreIcons.check_box : PpreIcons.check_box_outline_blank;
        return Container(
            alignment: AlignmentDirectional.topEnd,
            margin: EdgeInsets.only(top: 10, left: 12),
            child: IconButton(
              icon: Icon(icon, color: colour, size: 40),
              onPressed: () {
                var delta = completed ? -1 : 1;
                this.onChange(this.value + delta);
              },
              padding: EdgeInsets.only(left: 4, top: 4),
              alignment: Alignment.topLeft,
            ));
      })
    ]));
  }
}
