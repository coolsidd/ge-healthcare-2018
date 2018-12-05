import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart";

class AboutUsWidget extends StatelessWidget {
  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                    },
                    splashColor: Colors.pink,
                    child: CircleAvatar(                      
                      child: Image(image: AssetImage("assets/images/logo.png")),
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      radius: 80.0,
                    ),
                  ),
                  Container(
                    child: Center(
                      child: Text(
                        "Adorer",
                        style: TextStyle(fontSize: 30.0),
                      ),
                    ),
                    padding: EdgeInsets.all(15.0),
                  ),
                  Center(
                      child: Text(
                    "Made with \u2764 for GE Healthcare Hackathon 2018",
                    style:
                        TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                  )),
                ],
              ),
              margin: EdgeInsets.all(30.0),
            ),
            Divider(),
            ListTile(
                onTap: () {
                  _launchURL("http://github.com/coolsidd");
                },
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                      'https://avatars0.githubusercontent.com/u/8058854?s=460&v=4'),
                ),
                title: Text(
                  "Siddharth Singh",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("coolsidd")),
            Divider(),
            ListTile(
                onTap: () {
                  _launchURL("http://github.com/guptasamarth61");
                },
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                      "https://avatars3.githubusercontent.com/u/31878654?s=400&v=4"),
                ),
                title: Text(
                  "Samarth Gupta",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("guptasamarth61")),
            Divider(),
          ],
        )
      ],
    );
  }
}
