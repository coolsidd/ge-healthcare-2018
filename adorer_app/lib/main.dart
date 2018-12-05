import 'package:flutter/material.dart';
import 'games.dart' as Games;
import 'graphs.dart' as Graphs;
import 'sleep.dart' as Sleep;
import 'activities.dart' as Activities;
import 'emotion.dart' as Emotion;
import 'aboutUs.dart' as AboutUs;

void main() {
  runApp(MaterialApp(
    title: "Adorer",
    debugShowCheckedModeBanner: false,
    home: new MyHomePage(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyHomePage();
  }
}

class MyHomePage extends StatefulWidget {
  final drawerItemsBegin = [
    DrawerItem("Home", Icons.home, true, Text("Screen 1")),
    DrawerItem("Games", Icons.games, true, Text("Screen 2"),
        drawerItemWidget: () => Games.MainScreen()),
    DrawerItem("Graphs", Icons.insert_chart, true, Text("Graphs"),
        drawerItemWidget: () => Graphs.GraphsWidget()),
    DrawerItem("Sleep", Icons.hotel, true, Text("Sleep"),
        drawerItemWidget: () => Sleep.SleepScreen()),
    DrawerItem("Activities", Icons.list, true, Text("My Activities"),
        drawerItemWidget: () => Activities.MainScreen()),
    DrawerItem("Emotion Detect", Icons.list, true, Text("Detecting..."),
        drawerItemWidget: () => Emotion.EmotionWidget()),
    DrawerItem("Divider1", null, false, null, isDivider: true),
    DrawerItem("About Us", Icons.info, true, Text("About Us"),
        drawerItemWidget: () => AboutUs.AboutUsWidget()),
  ];
  @override
  _MyHomePageState createState() {
    return new _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
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
      if(dItem.isDivider){
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
    drawerOptionsBegin = generateDrawerItems(widget.drawerItemsBegin);
    return Scaffold(
      appBar: widget.drawerItemsBegin[_selectedDrawerIndex].appBarEnabled
          ? AppBar(
              title: widget.drawerItemsBegin[_selectedDrawerIndex].appBarTitle,
            )
          : null,
      body: widget.drawerItemsBegin[_selectedDrawerIndex].drawerItemWidget(),
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
      {this.ontapped, this.switchOnTap, this.drawerItemWidget, this.isDivider}) {
    if (this.ontapped == null) {
      this.ontapped = () {
        return null;
      };
    }
    if(this.isDivider== null){
      this.isDivider =false;
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
