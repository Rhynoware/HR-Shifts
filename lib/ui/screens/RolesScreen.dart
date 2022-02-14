import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hr_shifts/ui/screens/CalendarScreen.dart';
import 'package:hr_shifts/ui/components/menu_drawer.dart';
import 'package:hr_shifts/ui/screens/ReportScreen.dart';
import 'package:hr_shifts/ui/components/about_sheet.dart';
import 'package:hr_shifts/ui/components/carousel_content.dart';
import 'package:hr_shifts/ui/components/feedback_sheet.dart';
import 'package:hr_shifts/ui/components/shifts_sheet.dart';
import 'package:hr_shifts/ui/components/signup_sheet.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:hr_shifts/Isolates.dart' as Isolates;
import 'package:hr_shifts/CalendarModel.dart' as CalendarModel;
import 'package:hr_shifts/NetDutyAPI.dart' as NetDutyAPI;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RolesScreen extends StatefulWidget {
  const RolesScreen(
      {Key? key,
      required this.loginToken,
      required this.online,
      required this.userIdentity,
      required this.rosterId,
      required this.rolesData,
      required this.shifts,
      required this.calendarScreenData})
      : super(key: key);

  final String loginToken;
  final bool online;
  final String userIdentity;
  final String rosterId;
  final List<Map<String, String>> rolesData;
  final List<String> shifts;
  final List<List<String>> calendarScreenData;

  @override
  _RolesScreenState createState() => _RolesScreenState();
}

class _RolesScreenState extends State<RolesScreen> with WidgetsBindingObserver {
  List<Map<String, String>> rolesData = [];
  List<String> shiftsData = [];
  List<List<String>> calendarScreenData = [];
  DateTime calendarScreenMonth = DateTime.now();

  Map<String, String> roles = {};
  int currentDate = DateTime.now().day;
  DateTime shownDate = DateTime.now();
  int daysInMonth = 0;
  CarouselController carouselController = CarouselController();
  final storage = FlutterSecureStorage();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state.index == 0) {
      print("application state: $state");

      bool newMonth = shownDate.month != DateTime.now().month;
      setState(() {
        currentDate = DateTime.now().day;
        _jumpToDay(currentDate - 1);
      });

      if (newMonth) {
        _refreshData();
      }
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addObserver(this);

    rolesData = widget.rolesData;
    shiftsData = widget.shifts;
    calendarScreenData = widget.calendarScreenData;
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);

    super.dispose();
  }

  void _updateWithNewMonthData(
      Map<String, dynamic> newMonthData, DateTime shift) {
    rolesData = newMonthData["roles"];
    calendarScreenData = newMonthData["calendar"];
    calendarScreenMonth = shift;
  }

  void _jumpToDay(int day) {
    carouselController.jumpToPage(day);
  }

  void _updateShownDate(DateTime date) {
    setState(() {
      shownDate = date;
    });
  }

  void _showRefreshing() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              insetPadding: EdgeInsets.all(130),
              child: Container(
                  width: 50,
                  height: 90,
                  child: Column(
                    children: [
                      Padding(padding: EdgeInsets.all(10)),
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          strokeWidth: 6,
                          valueColor: AlwaysStoppedAnimation(Colors.blue),
                        ),
                      )
                    ],
                  )));
        });
  }

  void _refreshData() async {
    Navigator.of(context).pop();
    _showRefreshing();

    final directory = await getApplicationDocumentsDirectory();
    final file = File("${directory.path}/schedule.html");
    file.deleteSync();

    String? username = await storage.read(key: "username");
    String? password = await storage.read(key: "password");
    final Future<http.StreamedResponse> future =
        NetDutyAPI.getCalendarData(username!, password!, widget.loginToken);
    future.then((response) async {
      final String responseStr = await response.stream.bytesToString();
      file.writeAsString(responseStr);

      var document = await compute(CalendarModel.loadDocument, responseStr);
      String userIdentity = CalendarModel.getUserIdentity(document);
      List<Map<String, String>> newRolesData =
          await compute(Isolates.getRolesData, document);
      List<String> newShiftsData = CalendarModel.getShifts(document);
      List<List<String>> newCalendarData =
          await compute(Isolates.getCalendarData, [document, userIdentity]);

      setState(() {
        rolesData = newRolesData;
        shiftsData = newShiftsData;
        calendarScreenData = newCalendarData;

        Navigator.of(context).pop();
      });
    });
  }

  void _logout() async {
    Navigator.of(context).pop();
    await Future.delayed(Duration(milliseconds: 300));
    Navigator.of(context).pop();

    storage.delete(key: "username");
    storage.delete(key: "password");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("loaded");

    final directory = await getApplicationDocumentsDirectory();
    final file = File("${directory.path}/schedule.html");
    file.deleteSync();
  }

  void _showOfflineDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("No Connection"),
          content: Text("Please check your connection and restart the app."),
          actions: [
            TextButton(
              child: Text("OK", style: TextStyle(fontSize: 20)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSignupSheet(Map<String, String> roles, bool top) {
    List<String> open = [];
    for (String key in [
      "ALS ${top ? '7A-7P' : '7P-7A'}",
      "BLS ${top ? '7A-7P' : '7P-7A'}",
      "EMT ${top ? '7A-7P' : '7P-7A'}"
    ]) {
      if (roles[key] == "" || roles[key] == null) {
        open.add(key);
      }
    }

    showModalBottomSheet(
        context: context,
        elevation: 1.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
        ),
        isScrollControlled: true,
        builder: (context) {
          return SignupSheet(
              openShifts: open,
              shownDate: shownDate,
              showRefreshing: _showRefreshing,
              signUp: _signUpForShift);
        });
  }

  void _signUpForShift(String shift, String date) async {
    String epoch = rolesData[shownDate.day]['epoch']!;
    String? username = await storage.read(key: "username");
    String? password = await storage.read(key: "password");
    String? token = await storage.read(key: "token");
    String cookie = await Isolates.getCookie(username!, password!, token!);

    final Future<http.StreamedResponse> future =
        NetDutyAPI.getDutyId(epoch, cookie);
    future.then((response) async {
      final String responseStr = await response.stream.bytesToString();
      final List<dynamic> responseJson = jsonDecode(responseStr);
      String calendarStr = responseJson[0]['calendar_section']!;
      String dutyId = CalendarModel.getDutyId(calendarStr, shift);

      DateFormat shiftFormat = DateFormat("yyyy-MM-dd");
      DateTime newMonth = shiftFormat.parse(date);
      final Future<http.StreamedResponse> future =
          NetDutyAPI.signUp(dutyId, widget.rosterId, date, cookie);
      future.then((response) async {
        Map<String, dynamic> newMonthData = await compute(Isolates.getNewMonth,
            [newMonth, widget.userIdentity, username, password, token]);
        rolesData = newMonthData["roles"];
        calendarScreenData = newMonthData["calendar"];
        calendarScreenMonth = newMonth;

        setState(() {});
        Navigator.of(context).pop();
      });
    });
  }

  void _showShiftsSheet() {
    showModalBottomSheet(
        context: context,
        elevation: 1.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
        ),
        isScrollControlled: true,
        builder: (context) {
          return ShiftsSheet(
              online: widget.online,
              shiftsData: shiftsData,
              showOfflineDialog: _showOfflineDialog,
              showRefreshing: _showRefreshing,
              userIdentity: widget.userIdentity,
              updateWithNewMonthData: _updateWithNewMonthData,
              updateShownDate: _updateShownDate,
              jumpToPage: _jumpToDay);
        });
  }

  void _showCalendarScreen() async {
    await Future.delayed(Duration(milliseconds: 300));
    final int? selectedDate =
        await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => CalendarScreen(
                  calendarData: calendarScreenData,
                  month: calendarScreenMonth,
                )));
    if (selectedDate == null) return;

    await Future.delayed(Duration(milliseconds: 500));
    _jumpToDay(selectedDate);
    print(selectedDate);
    _updateShownDate(
        DateTime(shownDate.year, shownDate.month, selectedDate + 1));
  }

  void _showReportScreen() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ReportScreen(userIdentity: widget.userIdentity)));
  }

  void _showFeedbackBottomSheet() {
    FocusNode feedbackFocusNode = FocusNode();
    TextEditingController feedbackController = TextEditingController();

    showModalBottomSheet(
        context: context,
        elevation: 1.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
        ),
        isScrollControlled: true,
        builder: (context) {
          return FeedbackSheet(
              feedbackController: feedbackController,
              feedbackFocusNode: feedbackFocusNode);
        });

    feedbackFocusNode.requestFocus();
  }

  void _showAboutBottomSheet() {
    showModalBottomSheet(
        context: context,
        elevation: 1.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
        ),
        isScrollControlled: true,
        builder: (context) {
          return AboutSheet();
        });
  }

  void _onDateChanged(int index, CarouselPageChangedReason reason) async {
    print("Now showing: $index");

    if (reason == CarouselPageChangedReason.manual &&
        ((shownDate.day == 1 && index == daysInMonth - 1) ||
            (shownDate.day == daysInMonth && index == 0))) {
      if (!widget.online) {
        setState(() {
          shownDate =
              DateTime(DateTime.now().year, DateTime.now().month, index + 1);
        });
        _showOfflineDialog();
        return;
      }

      _showRefreshing();

      DateTime newDate;
      if (shownDate.day == daysInMonth) {
        newDate = DateTime(shownDate.year, shownDate.month + 1, 1);
      } else {
        newDate = DateTime(shownDate.year, shownDate.month, 0);
      }
      String? username = await storage.read(key: "username");
      String? password = await storage.read(key: "password");
      String? token = await storage.read(key: "token");
      Map<String, dynamic> newMonthData = await compute(Isolates.getNewMonth,
          [newDate, widget.userIdentity, username, password, token]);
      rolesData = newMonthData["roles"];
      calendarScreenData = newMonthData["calendar"];
      calendarScreenMonth = newDate;

      Navigator.of(context).pop();

      setState(() {
        shownDate = newDate;
      });
      if (index >= newDate.day) {
        int newIndex = index;
        while (newIndex >= newDate.day) newIndex -= 1;
        _jumpToDay(newIndex);
      }
      if (shownDate.day == 1) {
        await Future.delayed(Duration(milliseconds: 200));
        carouselController.jumpToPage(0);
      } else {
        await Future.delayed(Duration(milliseconds: 200));
        carouselController.jumpToPage(daysInMonth - 1);
      }
    } else {
      setState(() {
        shownDate = DateTime(shownDate.year, shownDate.month, index + 1);
      });
    }
  }

  void _onDateTapped() async {
    HapticFeedback.mediumImpact();
    bool loadedNew = false;

    if (shownDate.month != DateTime.now().month) {
      loadedNew = true;
      _showRefreshing();

      String? username = await storage.read(key: "username");
      String? password = await storage.read(key: "password");
      String? token = await storage.read(key: "token");
      Map<String, dynamic> newMonthData = await compute(Isolates.getNewMonth,
          [DateTime.now(), widget.userIdentity, username, password, token]);
      rolesData = newMonthData["roles"];
      calendarScreenData = newMonthData["calendar"];
      calendarScreenMonth = DateTime.now();

      Navigator.of(context).pop();
    }

    setState(() {
      shownDate =
          DateTime(DateTime.now().year, DateTime.now().month, currentDate);
    });

    if (loadedNew) await Future.delayed(Duration(milliseconds: 200));
    carouselController.jumpToPage(currentDate - 1);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    DateFormat formatter = DateFormat('M/d/yy');
    DateFormat dayOfWeek = DateFormat('EEEE');
    daysInMonth = new DateTime(shownDate.year, shownDate.month + 1, 0).day;
    String dateLabel = "Today, ${formatter.format(shownDate)}";
    if (!(shownDate.month == DateTime.now().month &&
        shownDate.day == currentDate)) {
      dateLabel =
          "${dayOfWeek.format(shownDate)}, ${formatter.format(shownDate)}";
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.white),
            centerTitle: true,
            title: GestureDetector(
              onTap: _onDateTapped,
              child: Text(
                dateLabel,
                style: TextStyle(fontSize: 30, color: Colors.white),
              ),
            ),
          ),
          onDrawerChanged: (bool isOpened) {
            if (isOpened) HapticFeedback.mediumImpact();
          },
          drawer: MenuDrawer(
              userIdentity: widget.userIdentity,
              online: widget.online,
              refresh: _refreshData,
              jumpToDay: _jumpToDay,
              updateShownDate: _updateShownDate,
              showShiftsBottomSheet: _showShiftsSheet,
              showCalendarScreen: _showCalendarScreen,
              showReportScreen: _showReportScreen,
              showAboutBottomSheet: _showAboutBottomSheet,
              showFeedbackBottomSheet: _showFeedbackBottomSheet,
              logout: _logout),
          body: Container(
            color: Colors.lightBlue,
            child: CarouselSlider.builder(
                itemCount: daysInMonth,
                carouselController: carouselController,
                itemBuilder:
                    (BuildContext context, int itemIndex, int pageViewIndex) {
                  roles = rolesData[itemIndex + 1];

                  return CarouselContent(
                      width: width,
                      roles: roles,
                      showSignupSheet: _showSignupSheet);
                },
                options: CarouselOptions(
                    height: height,
                    initialPage: currentDate - 1,
                    viewportFraction: 1,
                    onPageChanged: _onDateChanged,
                    scrollDirection: Axis.vertical)),
          )),
    );
  }
}
