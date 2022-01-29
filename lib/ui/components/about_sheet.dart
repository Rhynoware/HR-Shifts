import 'package:flutter/material.dart';

class AboutSheet extends StatefulWidget {
  const AboutSheet({Key? key}) : super(key: key);

  @override
  _AboutSheetState createState() => _AboutSheetState();
}

class _AboutSheetState extends State<AboutSheet> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(padding: EdgeInsets.all(4)),
            Container(
                width: 100,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.all(Radius.circular(8)))),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text("About", style: TextStyle(fontSize: 30)),
            ),
            Divider(
              thickness: 1.5,
              indent: 10,
              endIndent: 10,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 20),
              child: Text(
                  "I made this because the website is hard to use on phones. "
                  "I work on this entirely in my spare time, "
                  "it will always be free for our team. "
                  "If you want to help contribute, please submit feedback. Enjoy! 😊",
                  style: TextStyle(
                    fontSize: 24,
                  )),
            )
          ]),
    );
  }
}
