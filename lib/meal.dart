import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:morgan_ppre/db.dart';
import 'package:morgan_ppre/ppre_icons_icons.dart';
import 'package:provider/provider.dart';

class NutritionalRqmt {
  final int needed;
  final int optional;
  NutritionalRqmt({@required this.needed, @required this.optional});
}

class MealPlan {
  final NutritionalRqmt protein;
  final NutritionalRqmt grains;
  final NutritionalRqmt produce;
  final NutritionalRqmt fats;

  MealPlan({
    @required this.protein,
    @required this.grains,
    @required this.produce,
    @required this.fats,
  });

  NutritionalRqmt operator[](String key) {
    return (
      key == 'protein' ? protein :
      key == 'grains' ? grains :
      key == 'produce' ? produce :
      key == 'fats' ? fats :
      null
    );
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
        protein: NutritionalRqmt(needed: 2, optional: 1),
        produce: NutritionalRqmt(needed: 1, optional: 0),
        grains: NutritionalRqmt(needed: 2, optional: 0),
        fats: NutritionalRqmt(needed: 2, optional: 0),
      )),
  MealSpec(
      name: "Morning Snack",
      color: Colors.orange,
      plan: MealPlan(
        protein: NutritionalRqmt(needed: 1, optional: 0),
        fats: NutritionalRqmt(needed: 1, optional: 0),
        produce: NutritionalRqmt(needed: 1, optional: 0),
        grains: NutritionalRqmt(needed: 0, optional: 0),
      )
  ),
  MealSpec(
      name: "Lunch",
      color: Colors.red,
      plan: MealPlan(
        protein: NutritionalRqmt(needed: 3, optional: 1),
        produce: NutritionalRqmt(needed: 1, optional: 1),
        grains: NutritionalRqmt(needed: 2, optional: 0),
        fats: NutritionalRqmt(needed: 2, optional: 1),
      )),
  MealSpec(
      name: "Afternoon Snack",
      color: Colors.purple,
      plan: MealPlan(
        protein: NutritionalRqmt(needed: 1, optional: 0),
        produce: NutritionalRqmt(needed: 1, optional: 1),
        grains: NutritionalRqmt(needed: 0, optional: 1),
        fats: NutritionalRqmt(needed: 0, optional: 1),
      )),
  MealSpec(
      name: "Dinner",
      color: Colors.green,
      plan: MealPlan(
        protein: NutritionalRqmt(needed: 3, optional: 1),
        produce: NutritionalRqmt(needed: 2, optional: 0),
        grains: NutritionalRqmt(needed: 2, optional: 0),
        fats: NutritionalRqmt(needed: 2, optional: 1),
      )),
  MealSpec(
      name: "Evening Snack",
      color: Colors.blue,
      plan: MealPlan(
        protein: NutritionalRqmt(needed: 0, optional: 1),
        produce: NutritionalRqmt(needed: 0, optional: 1),
        grains: NutritionalRqmt(needed: 0, optional: 1),
        fats: NutritionalRqmt(needed: 0, optional: 1),
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
                        children: <Widget>[
                          ServingCheckboxRow(
                              title: "Protein",
                              counts: this.mealSpec.plan.protein,
                              onChange: (int newCount) {
                                meal.update(this.mealSpec.name,
                                    protein: newCount);
                              },
                              color: this.mealSpec.color,
                              value: meal.entry[this.mealSpec.name].protein),
                          ServingCheckboxRow(
                              title: "Grains",
                              counts: this.mealSpec.plan.grains,
                              onChange: (newCount) {
                                meal.update(this.mealSpec.name,
                                    grains: newCount);
                              },
                              color: this.mealSpec.color,
                              value: meal.entry[this.mealSpec.name].grains),
                          ServingCheckboxRow(
                              title: "Produce",
                              counts: this.mealSpec.plan.produce,
                              onChange: (newCount) {
                                meal.update(this.mealSpec.name,
                                    produce: newCount);
                              },
                              color: this.mealSpec.color,
                              value: meal.entry[this.mealSpec.name].produce),
                          ServingCheckboxRow(
                              title: "Fats",
                              counts: this.mealSpec.plan.fats,
                              onChange: (newCount) {
                                meal.update(this.mealSpec.name, fats: newCount);
                              },
                              color: this.mealSpec.color,
                              value: meal.entry[this.mealSpec.name].fats),
                          Container(
                            padding: EdgeInsets.all(10),
                            child: TextFormField(
                              initialValue: meal.entry[this.mealSpec.name].notes,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: "Notes",
                                  labelStyle: TextStyle(),
                                ),
                                minLines: 2,
                                maxLines: 5,
                                onChanged: (String note) {
                                  meal.update(this.mealSpec.name, notes: note);
                                }),
                          ),
                        ],
                      ))),
            )));
  }
}

typedef void CheckboxRowChanged(int i);

class ServingCheckboxRow extends StatelessWidget {
  final String title;
  final NutritionalRqmt counts;
  final int value;
  final Color color;
  final CheckboxRowChanged onChange;
  ServingCheckboxRow(
      {@required this.title,
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
          child: Text(this.title, style: TextStyle(fontSize: 20))),
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
