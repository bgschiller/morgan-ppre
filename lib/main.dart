import 'package:morgan_ppre/exercise.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:morgan_ppre/db.dart';
import 'package:morgan_ppre/meal.dart';
import 'package:morgan_ppre/ppre_icons_icons.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(
      ChangeNotifierProvider(create: (context) => MealModel(), child: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Morgan's PPRE"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                margin: EdgeInsets.all(15),
                child: Text(
                  'Planned. Purposeful. Portioned. Permission.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                )),
            Expanded(
                child: Row(
              children: <Widget>[
                Container(
                    margin: EdgeInsets.all(20),
                    alignment: Alignment.centerLeft,
                    child: ButtonTheme(
                        minWidth: 250,
                        height: 70,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: mealSpecs
                                .map((m) => Container(
                                    margin: m.name == "Breakfast"
                                        ? EdgeInsets.only(top: 0)
                                        : EdgeInsets.only(top: 10),
                                    child: MealButton(mealSpec: m)))
                                .toList()))),
              ],
            )),
            Container(
                margin: EdgeInsets.all(20),
                child: Row(children: <Widget>[
                  Consumer<MealModel>(
                      builder: (context, meal, child) => Row(children: <Widget>[
                            Container(
                                padding: EdgeInsets.only(left: 7, top: 14),
                                alignment: Alignment.center,
                                child: Text(
                                  meal.entry != null
                                      ? meal.entry.numGlassesOfWater.toString()
                                      : '',
                                  style: TextStyle(
                                      color: Colors.blue, fontSize: 24),
                                  textAlign: TextAlign.center,
                                )),
                            IconButton(
                              icon: Icon(PpreIcons.water_drop,
                                  color: Colors.blue, size: 40),
                              onPressed: () {
                                meal.updateNumGlassesOfWater(
                                    (meal.entry.numGlassesOfWater + 1) % 13);
                              },
                              alignment: Alignment.topLeft,
                            ),
                          ])),
                  Spacer(),
                  FlatButton(
                    child: Row(children: [
                      Icon(Icons.star, color: Colors.white),
                      Container(
                          child: Text("Exercise"),
                          margin: EdgeInsets.only(left: 10)),
                    ]),
                    textColor: Colors.white,
                    color: Colors.deepPurple,
                    onPressed: () {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => ExercisePage()));
                    },
                  )
                ]))
          ],
        ),
      ),
    );
  }
}
