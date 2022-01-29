import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MenuDrawer extends StatefulWidget {
  const MenuDrawer(
      {Key? key,
      required this.userIdentity,
      required this.online,
      required this.refresh,
      required this.jumpToDay,
      required this.updateShownDate,
      required this.showShiftsBottomSheet,
      required this.showCalendarScreen,
      required this.showReportScreen,
      required this.showAboutBottomSheet,
      required this.showFeedbackBottomSheet,
      required this.logout})
      : super(key: key);

  final String userIdentity;
  final bool online;
  final Function refresh;
  final Function jumpToDay;
  final Function updateShownDate;
  final Function showShiftsBottomSheet;
  final Function showCalendarScreen;
  final Function showReportScreen;
  final Function showAboutBottomSheet;
  final Function showFeedbackBottomSheet;
  final Function logout;

  @override
  _MenuDrawerState createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Image(
              width: 100,
              height: 60,
              image: AssetImage('images/logo.png'),
            ),
            Text("HR Shifts", style: TextStyle(fontSize: 30)),
            Text(widget.userIdentity, style: TextStyle(fontSize: 20)),
            Divider(
              thickness: 2,
            ),
            Container(
              height: 60,
              width: width,
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: TextButton(
                onPressed: widget.online
                    ? () async {
                        widget.refresh();
                      }
                    : null,
                clipBehavior: Clip.hardEdge,
                child: Row(children: <Widget>[
                  Icon(
                    Icons.refresh,
                    size: 30,
                    color: widget.online ? Colors.black : Colors.grey,
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(10, 0, 0, 0)),
                  Text(
                    'Refresh',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: widget.online ? Colors.black : Colors.grey,
                        fontSize: 24),
                  ),
                  Spacer(),
                  Visibility(
                      visible: !widget.online,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          padding: EdgeInsets.fromLTRB(7, 3, 7, 3),
                          child: Text("OFFLINE",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              )),
                        ),
                      ))
                ]),
              ),
            ),
            Container(
              height: 60,
              width: width,
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: TextButton(
                onPressed: () async {
                  HapticFeedback.mediumImpact();
                  Navigator.of(context).pop();
                  widget.showCalendarScreen();
                },
                clipBehavior: Clip.hardEdge,
                child: Row(children: <Widget>[
                  Icon(
                    Icons.calendar_today,
                    size: 30,
                    color: Colors.black,
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(10, 0, 0, 0)),
                  Text(
                    'Calendar',
                    textAlign: TextAlign.left,
                    style: TextStyle(color: Colors.black, fontSize: 24),
                  )
                ]),
              ),
            ),
            Container(
              height: 60,
              width: width,
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: TextButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  Navigator.of(context).pop();
                  widget.showShiftsBottomSheet();
                },
                clipBehavior: Clip.hardEdge,
                child: Row(children: <Widget>[
                  Icon(
                    Icons.list,
                    size: 30,
                    color: Colors.black,
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(10, 0, 0, 0)),
                  Text(
                    'My Shifts',
                    textAlign: TextAlign.left,
                    style: TextStyle(color: Colors.black, fontSize: 24),
                  )
                ]),
              ),
            ),
            Container(
              height: 60,
              width: width,
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: TextButton(
                onPressed: widget.online
                    ? () {
                        Navigator.of(context).pop();
                        widget.showReportScreen();
                      }
                    : null,
                clipBehavior: Clip.hardEdge,
                child: Row(children: <Widget>[
                  Icon(
                    Icons.report,
                    size: 30,
                    color: widget.online ? Colors.black : Colors.grey,
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(10, 0, 0, 0)),
                  Text(
                    'Shifts/Checks Report',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: widget.online ? Colors.black : Colors.grey,
                        fontSize: 24),
                  )
                ]),
              ),
            ),
            Container(
              height: 60,
              width: width,
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: TextButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  Navigator.of(context).pop();
                  widget.showAboutBottomSheet();
                },
                clipBehavior: Clip.hardEdge,
                child: Row(children: <Widget>[
                  Icon(
                    Icons.info,
                    size: 30,
                    color: Colors.black,
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(10, 0, 0, 0)),
                  Text(
                    'About',
                    textAlign: TextAlign.left,
                    style: TextStyle(color: Colors.black, fontSize: 24),
                  )
                ]),
              ),
            ),
            Container(
              height: 60,
              width: width,
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: TextButton(
                onPressed: widget.online
                    ? () {
                        Navigator.of(context).pop();
                        widget.showFeedbackBottomSheet();
                      }
                    : null,
                clipBehavior: Clip.hardEdge,
                child: Row(children: <Widget>[
                  Icon(
                    Icons.feedback,
                    size: 30,
                    color: widget.online ? Colors.black : Colors.grey,
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(10, 0, 0, 0)),
                  Text(
                    'Feedback',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: widget.online ? Colors.black : Colors.grey,
                        fontSize: 24),
                  )
                ]),
              ),
            ),
            Container(
              height: 60,
              width: width,
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: TextButton(
                onPressed: () {
                  widget.logout();
                },
                clipBehavior: Clip.hardEdge,
                child: Row(children: <Widget>[
                  Icon(
                    Icons.logout,
                    size: 30,
                    color: Colors.black,
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(10, 0, 0, 0)),
                  Text(
                    'Logout',
                    textAlign: TextAlign.left,
                    style: TextStyle(color: Colors.black, fontSize: 24),
                  )
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
