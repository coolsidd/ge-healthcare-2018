import 'package:flutter/material.dart';
import 'games.dart' as Games;

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
  final drawerItems = [
    DrawerItem("Home", Icons.developer_board, true, Text("Screen 1")),
    DrawerItem("Games", Icons.developer_board, true, Text("Screen 2"), ontapped: (){print("Well");},drawerItemWidget: Games.MainScreen()),
    DrawerItem("Activities", Icons.developer_board, true, Text("Screen 3")),
    DrawerItem("Stats", Icons.developer_board, true, Text("Screen 4")),
  ];
  @override
  _MyHomePageState createState() => new _MyHomePageState();
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
  List<Widget> generateDrawerItems(List <DrawerItem> drawerItemList){
    List<Widget> drawerOptions = <Widget> [];
    for (var i = 0; i < widget.drawerItems.length; i++) {
      var dItem = widget.drawerItems[i];
      drawerOptions.add(ListTile(
        leading: Icon(dItem.icon),
        title: Text(dItem.title),
        selected: i == selectedDrawerIndex,
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
    List<Widget> drawerOptions = <Widget>[];
    drawerOptions = generateDrawerItems(widget.drawerItems);
    return Scaffold(
      appBar: widget.drawerItems[_selectedDrawerIndex].appBarEnabled
          ? AppBar(
              title: widget.drawerItems[_selectedDrawerIndex].appBarTitle,
            )
          : null,
      body: widget.drawerItems[_selectedDrawerIndex].drawerItemWidget,
      drawer: Drawer(
          child: ListView(
        children: <Widget>[
          DrawerHeader(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text("Drawer Header")])),
          Column(
            children: drawerOptions,
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
  Widget drawerItemWidget;
  Function() ontapped;
  bool switchOnTap;
  DrawerItem(this.title, this.icon, this.appBarEnabled, this.appBarTitle,
      {this.ontapped, this.switchOnTap, this.drawerItemWidget}) {
    if (this.ontapped == null) {
      this.ontapped =() {
        return null;
      };
    }
    if (this.switchOnTap == null) {
      switchOnTap = true;
    }
  }
}
