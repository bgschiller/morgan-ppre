import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:morgan_ppre/db.dart';
import 'package:morgan_ppre/meal.dart';
import 'package:morgan_ppre/ppre_icons_icons.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => MealModel(),
    child: MyApp()
  ));
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
              margin: EdgeInsets.all(20),
              child: Text(
              'Planned. Purposeful. Portioned. Permission.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            )),
            Expanded(child:Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(20),
                  alignment: Alignment.centerLeft,
                  child: ButtonTheme(
                    minWidth: 250,
                    height: 70,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: mealSpecs.map((m) => Container(
                        margin: EdgeInsets.only(top: 10),
                        child: MealButton(mealSpec: m))).toList()
                      )
                )),
                Consumer<MealModel>(
                  builder: (context, meal, child) => Column(children: List.generate(8, (ix) {
                    var dropColor = ix < (meal.entry?.numGlassesOfWater ?? 0) ? Colors.blue : Colors.grey;
                    var onPress = () {
                      if (ix < meal.entry.numGlassesOfWater) {
                        meal.updateNumGlassesOfWater(meal.entry.numGlassesOfWater - 1);
                      } else {
                        meal.updateNumGlassesOfWater(meal.entry.numGlassesOfWater + 1);
                      }
                    };
                    return Container(
                      alignment: AlignmentDirectional.topEnd,
                      margin: EdgeInsets.only(top: 10, left: 12),
                      child: IconButton(
                        icon: Icon(PpreIcons.water_drop, color: dropColor, size: 40),
                        onPressed: onPress,
                        padding: EdgeInsets.only(left: 4, top: 4),
                        alignment: Alignment.topLeft,
                      ));
                  })
                )),
              ],
            ))
          ],
        ),
      ),
    );
  }
}
