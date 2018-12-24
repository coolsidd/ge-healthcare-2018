import 'package:flutter/material.dart';
import 'games.dart' as Games;
import 'graphs.dart' as Graphs;
import 'sleep.dart' as Sleep;
import 'activities.dart' as Activities;
import 'emotion.dart' as Emotion;
import 'aboutUs.dart' as AboutUs;
import 'colors.dart';
import 'advice.dart' as Advice;
import 'emergencyCall.dart' as EmergencyCall;
import 'predictions.dart' as Predictions;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'scheduler.dart' as Schedular;

final ThemeData _kShrineTheme = _buildShrineTheme();

ThemeData _buildShrineTheme() {
  final ThemeData base = ThemeData.light();
  return base.copyWith(
    accentColor: secondaryMain,
    primaryColor: primaryMain,
    buttonColor: secondaryDark,
    textSelectionColor: Colors.lightBlue,
  );
}

void main() {
  runApp(MaterialApp(
    title: "Adorer",
    debugShowCheckedModeBanner: false,
    home: new MyHomePage(),
    theme: _kShrineTheme,
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyHomePage();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() {
    return new _MyHomePageState();
  }
}

enum Screens { home, games, sleep, medicine }
void noteTime(Screens screen) async {
  final directory = await getApplicationDocumentsDirectory();
  if (true) {
    final File file = File("${directory.path}/meta.csv");
    await file.writeAsString(
        ListToCsvConverter().convert([
          [screen.toString(), DateTime.now()]
        ]),
        mode: FileMode.append);
  }
}

class _MyHomePageState extends State<MyHomePage> {
  List<DrawerItem> drawerItemsBegin = [
    DrawerItem("Home", Icons.home, true, Text("Home"), drawerItemWidget: () {
      noteTime(Screens.home);
      return Predictions.PredictionsWidget();
    }),
    DrawerItem("Games", Icons.games, true, Text("Games"), drawerItemWidget: () {
      noteTime(Screens.games);
      return Games.MainScreen();
    }),
    DrawerItem("Graphs", Icons.insert_chart, true, Text("Graphs"),
        drawerItemWidget: () => Graphs.GraphsWidget()),
    DrawerItem("Sleep", Icons.hotel, true, Text("Sleep"),
        drawerItemWidget: () => Sleep.SleepScreen()),
    DrawerItem("Activities", Icons.list, false, Text("My Activities"),
        drawerItemWidget: () => Activities.MainScreen()),
    DrawerItem("Emotion Detect", Icons.list, true, Text("Detecting..."),
        drawerItemWidget: () => Emotion.EmotionWidget()),
    DrawerItem("Scheduler", Icons.schedule, true, Text("Scheduler"),
        drawerItemWidget: () => Schedular.MedicineScheduleWidget()),
    DrawerItem("Divider1", null, false, null, isDivider: true),
    DrawerItem(
        "Advice For Parents", Icons.help, false, Text("Advice for parents"),
        drawerItemWidget: () => Advice.AdviceWidget()),
    DrawerItem(
        "Emergency Contact", Icons.call, false, Text("Advice for parents"),
        drawerItemWidget: () => EmergencyCall.EmergencyCallWidget()),
    DrawerItem("About Us", Icons.info, true, Text("About Us"),
        drawerItemWidget: () => AboutUs.AboutUsWidget()),
  ];
  int _selectedDrawerIndex = 0;
  int get selectedDrawerIndex => _selectedDrawerIndex;
  set selectedDrawerIndex(int value) {
    _selectedDrawerIndex = value;
    setState(() {
      _selectedDrawerIndex = value;
      Navigator.of(context).pop();
    });
  }

  List<Widget> generateDrawerItems(List<DrawerItem> drawerItemList,
      {int startIndex = 0}) {
    List<Widget> drawerOptions = <Widget>[];
    for (var i = 0; i < drawerItemList.length; i++) {
      var dItem = drawerItemList[i];
      if (dItem.isDivider) {
        drawerOptions.add(Divider());
        continue;
      }
      drawerOptions.add(ListTile(
        leading: Icon(dItem.icon),
        title: Text(dItem.title),
        selected: (i + startIndex) == selectedDrawerIndex,
        onTap: () {
          dItem.ontapped();
          if (dItem.switchOnTap) {
            selectedDrawerIndex = i;
          }
        },
      ));
    }
    return drawerOptions;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> drawerOptionsBegin = <Widget>[];
    drawerOptionsBegin = generateDrawerItems(drawerItemsBegin);
    return Scaffold(
      appBar: drawerItemsBegin[_selectedDrawerIndex].appBarEnabled
          ? AppBar(
              title: drawerItemsBegin[_selectedDrawerIndex].appBarTitle,
            )
          : null,
      body: drawerItemsBegin[_selectedDrawerIndex].drawerItemWidget(),
      drawer: Drawer(
          child: ListView(
        children: <Widget>[
          DrawerHeader(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text("Drawer Header")])),
          Column(
            children: drawerOptionsBegin,
          ),
        ],
      )),
    );
  }
}

class DrawerItem {
  String title;
  IconData icon;
  bool appBarEnabled;
  Text appBarTitle;
  Function() drawerItemWidget;
  Function() ontapped;
  bool switchOnTap;
  bool isDivider;
  DrawerItem(this.title, this.icon, this.appBarEnabled, this.appBarTitle,
      {this.ontapped,
      this.switchOnTap,
      this.drawerItemWidget,
      this.isDivider}) {
    if (this.ontapped == null) {
      this.ontapped = () {
        return null;
      };
    }
    if (this.isDivider == null) {
      this.isDivider = false;
    }
    if (this.switchOnTap == null) {
      switchOnTap = true;
    }
    if (this.drawerItemWidget == null) {
      drawerItemWidget = () {
        return Container();
      };
    }
  }
}
