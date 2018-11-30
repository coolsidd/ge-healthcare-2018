import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MainScreenState();
  }
}

class MainScreenState extends State<MainScreen> {
  List<Activity> sampleActivities = [
    Activity("Chess", "Played a game of chess", []),
  ];
  Future<void> launchActivityDialog(Activity activity) async {
    DateTime dateAdded = DateTime.now();
    TimeOfDay timeBegan, timeEnded;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add activity'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ListTile(
                  title: Text('Day:'),
                  trailing: Icon(Icons.date_range),
                  onTap: () async {
                    dateAdded = await showDatePicker(
                      context: context,
                      lastDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      initialDate: DateTime(DateTime.now().year,
                          DateTime.now().month, DateTime.now().day),
                    );
                  },
                ),
                ListTile(
                  title: Text('Begin:'),
                  trailing: Icon(Icons.date_range),
                  onTap: () async {
                    timeBegan = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    setState(() {});
                  },
                ),
                ListTile(
                  title: Text('End:'),
                  trailing: Icon(Icons.date_range),
                  onTap: () async {
                    timeEnded = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('CANCEL'),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('ADD'),
              onPressed: () async {
                if (timeBegan != null &&
                    timeEnded != null &&
                    dateAdded != null) {
                  activity.data.add([
                    dateAdded.toIso8601String(),
                    timeBegan.format(context),
                    timeEnded.format(context)
                  ]);
                  setState(() {});
                  await autoSaveData();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> autoSaveData() {
    return Future.delayed(Duration(seconds: 3), () => true);
  }

  Widget getActivityWidget(Activity activity) {
    return ListTile(
      leading: Icon(Icons.check),
      title: Text("${activity.name}"),
      subtitle: Text("${activity.description}"),
      trailing: IconButton(
        icon: Icon(Icons.add_box),
        onPressed: () {
          launchActivityDialog(activity);
        },
      ),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ActivityScreen(activity)));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[getActivityWidget(sampleActivities[0])],
    );
  }
}

class ActivityScreen extends StatefulWidget {
  final Activity myActivity;
  ActivityScreen(this.myActivity);
  @override
  State<StatefulWidget> createState() {
    return ActivityScreenState(this.myActivity);
  }
}

class ActivityScreenState extends State<ActivityScreen> {
  Activity myActivity;
  ActivityScreenState(this.myActivity);

  Future<void> launchActivityDialog(Activity activity) async {
    DateTime dateAdded = DateTime.now();
    TimeOfDay timeBegan, timeEnded;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add activity'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ListTile(
                  title: Text('Day:'),
                  trailing: Icon(Icons.date_range),
                  onTap: () async {
                    dateAdded = await showDatePicker(
                      context: context,
                      lastDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      initialDate: DateTime(DateTime.now().year,
                          DateTime.now().month, DateTime.now().day),
                    );
                  },
                ),
                ListTile(
                  title: Text('Begin:'),
                  trailing: Icon(Icons.date_range),
                  onTap: () async {
                    timeBegan = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    setState(() {});
                  },
                ),
                ListTile(
                  title: Text('End:'),
                  trailing: Icon(Icons.date_range),
                  onTap: () async {
                    timeEnded = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('CANCEL'),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('ADD'),
              onPressed: () async {
                if (timeBegan != null &&
                    timeEnded != null &&
                    dateAdded != null) {
                  activity.data.add([
                    dateAdded.toIso8601String(),
                    timeBegan.format(context),
                    timeEnded.format(context)
                  ]);
                  setState(() {});
                  //await autoSaveData();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget activityDescriptionWidget(Activity act) {
    List<Widget> entries = List<Widget>.generate(act.data.length, (i) {
      return ListTile(
        title: Text(act.data[i][0].toString().substring(0, 10)),
        subtitle: Text("Start ${act.data[i][1]}\tEnd ${act.data[i][2]}"),
        isThreeLine: true,
        trailing: IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            setState(() {
              act.data.removeAt(i);
            });
          },
        ),
      );
    });
    return ListView(
      children: entries,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(myActivity.name),
      ),
      body: activityDescriptionWidget(myActivity),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          launchActivityDialog(myActivity);
        },
      ),
    );
  }
}

class Activity {
  String name;
  String description;
  List<List> data;
  Activity(this.name, this.description, this.data) {
    List<String> words = name.split(" ");
    List<String> capitalized = [];
    words.forEach((f) {
      if (f.length > 0) {
        capitalized.add(f[0].toUpperCase() + f.substring(1));
      } else {
        capitalized.add(f);
      }
    });
    this.name = capitalized.reduce((a, b) {
      return a + b;
    });
  }
}
