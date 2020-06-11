import 'package:flutter/material.dart';
import 'package:morgan_ppre/db.dart';
import 'package:provider/provider.dart';

class ExercisePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Good for you, Exercising!"),
          backgroundColor: Colors.deepPurple
        ),
        body: SingleChildScrollView(child: Consumer<MealModel>(
          builder: (context, meal, child) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.only(top: 20),
              child: TextFormField(
                initialValue: meal.entry.exercises,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelStyle: TextStyle(),
                    labelText: "What did you do today?"
                  ),
                  minLines: 4,
                  maxLines: 10,
                  onChanged: (String exercises) {
                    meal.setExercise(exercises);
                  }),
            )
            ]),
        )
    )));
  }
}