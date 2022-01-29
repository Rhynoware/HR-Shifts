import 'dart:convert';

import 'package:hr_shifts/CalendarModel.dart' as CalendarModel;
import 'package:hr_shifts/NetDutyAPI.dart' as NetDutyAPI;
import 'package:http/http.dart';
import 'package:html/dom.dart';

Future<String> getCookie(String username, String password, String token) async {
  final StreamedResponse response =
      await NetDutyAPI.getCalendarData(username, password, token);
  String cookieStr = response.headers["set-cookie"]!;
  List<String> cookies = cookieStr.split(';');
  String netdutyCookie = "netduty=";
  for (String cookie in cookies) {
    if (cookie.contains("netduty") && !cookie.contains("cinetduty")) {
      List<String> cookieParts = cookie.split("netduty=");
      netdutyCookie += cookieParts[1];
      break;
    }
  }
  return netdutyCookie;
}

List<Map<String, String>> getRolesData(Document document) {
  List<Map<String, String>> rolesData = [{}];
  int daysInMonth =
      new DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day;

  for (int day = 1; day <= daysInMonth; day++) {
    Map<String, String> roles = CalendarModel.getRoles(day, document);
    rolesData.add(roles);
  }

  return rolesData;
}

Future<Map<String, dynamic>> getNewMonth(List parameters) async {
  DateTime newDate = parameters[0];
  String userIdentity = parameters[1];
  String username = parameters[2];
  String password = parameters[3];
  String token = parameters[4];
  String netdutyCookie = await getCookie(username, password, token);
  print(netdutyCookie);

  final Future<StreamedResponse> future =
      NetDutyAPI.getCalendarMonth(newDate.month, newDate.year, netdutyCookie);
  return future.then((StreamedResponse response) async {
    final String responseOneStr = await response.stream.bytesToString();
    List<dynamic> jsonResponse = jsonDecode(responseOneStr);
    String calendarStr = jsonResponse[0]['calendar_section'];
    calendarStr.replaceAll("\\/", "/");
    Document monthData = CalendarModel.loadDocument(calendarStr);
    List<Map<String, String>> rolesData = getRolesData(monthData);
    bool allDays = newDate.month != DateTime.now().month;
    List<List<String>> calendarData =
        getCalendarData([monthData, userIdentity], allDays: allDays);

    return {"roles": rolesData, "calendar": calendarData};
  });
}

Future<Map<String, List<String>>> getShiftsAndChecks(List parameters) async {
  String cookie = parameters[0];
  String userIdentity = parameters[1];
  Document monthOne;
  Document monthTwo;
  Document monthThree;
  int year = DateTime.now().year;
  int month = DateTime.now().month;
  int first = 0;
  int second = 0;
  if (month == 1) {
    print("Need 2 and 3");
    first = 2;
    second = 3;
  } else if (month == 2) {
    print("Need 1 and 3");
    first = 1;
    second = 3;
  } else if (month == 3) {
    print("Need 1 and 2");
    first = 1;
    second = 2;
  } else if (month == 4) {
    print("Need 5 and 6");
    first = 5;
    second = 6;
  } else if (month == 5) {
    print("Need 4 and 6");
    first = 4;
    second = 6;
  } else if (month == 6) {
    print("Need 4 and 5");
    first = 4;
    second = 5;
  } else if (month == 7) {
    print("Need 8 and 9");
    first = 8;
    second = 9;
  } else if (month == 8) {
    print("Need 7 and 9");
    first = 7;
    second = 9;
  } else if (month == 9) {
    print("Need 7 and 8");
    first = 7;
    second = 8;
  } else if (month == 10) {
    print("Need 11 and 12");
    first = 11;
    second = 12;
  } else if (month == 11) {
    print("Need 10 and 12");
    first = 10;
    second = 12;
  } else if (month == 12) {
    print("Need 10 and 11");
    first = 10;
    second = 11;
  }

  final Future<StreamedResponse> futureOne =
      NetDutyAPI.getCalendarMonth(first, year, cookie);
  final Future<StreamedResponse> futureTwo =
      NetDutyAPI.getCalendarMonth(second, year, cookie);
  final Future<StreamedResponse> futureThree =
      NetDutyAPI.getCalendarMonth(month, year, cookie);
  return Future.wait([futureOne, futureTwo, futureThree])
      .then((List<StreamedResponse> response) async {
    final String responseOneStr = await response[0].stream.bytesToString();
    List<dynamic> jsonResponse = jsonDecode(responseOneStr);
    String calendarStr = jsonResponse[0]['calendar_section'];
    calendarStr.replaceAll("\\/", "/");
    monthOne = CalendarModel.loadDocument(calendarStr);

    final String responseTwoStr = await response[1].stream.bytesToString();
    jsonResponse = jsonDecode(responseTwoStr);
    calendarStr = jsonResponse[0]['calendar_section'];
    calendarStr.replaceAll("\\/", "/");
    monthTwo = CalendarModel.loadDocument(calendarStr);

    final String responseThreeStr = await response[2].stream.bytesToString();
    jsonResponse = jsonDecode(responseThreeStr);
    calendarStr = jsonResponse[0]['calendar_section'];
    calendarStr.replaceAll("\\/", "/");
    monthThree = CalendarModel.loadDocument(calendarStr);

    List<String> allShifts = [];
    List<String> allChecks = [];
    String currentMonth = "${DateTime.now().month}";
    List<String> months = [currentMonth, "$first", "$second"];

    [monthThree, monthOne, monthTwo].asMap().forEach((index, month) {
      int day = 0;
      while (day < 31) {
        Map<String, String> roles = CalendarModel.getRoles(day, month);
        if (roles.isEmpty) {
          day += 1;
          continue;
        }

        roles.remove("checkers");
        for (String key in roles.values) {
          if (userIdentity == key) {
            allShifts.add("${months[index]}/${day < 10 ? "0$day" : day}");
          }
        }
        day += 1;
      }

      day = 0;
      while (day < 30) {
        Map<String, String> roles = CalendarModel.getRoles(day, month);
        if (roles.containsKey("checkers")) {
          List<String> checkers = roles["checkers"]!.split(';');
          if (checkers.contains(userIdentity)) {
            allChecks.add("${months[index]}/${day < 10 ? "0$day" : day}");
          }
        }
        day += 1;
      }
    });

    allShifts.sort((a, b) {
      return a.compareTo(b);
    });
    allChecks.sort((a, b) {
      return a.compareTo(b);
    });

    return {"shifts": allShifts, "checks": allChecks};
  });
}

List<List<String>> getCalendarData(List parameters, {bool allDays = false}) {
  Document document = parameters[0];
  String userIdentity = parameters[1];
  List<List<String>> calendarData = [[]];
  int daysInMonth =
      new DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day;
  for (int day = 1; day <= daysInMonth; day++) {
    List<String> events = [];
    if (!allDays && day < DateTime.now().day) {
      calendarData.add(events);
      continue;
    }
    Map<String, String> roles = CalendarModel.getRoles(day, document);

    bool myShift = false;
    bool openShift = false;
    for (String value in roles.values) {
      if (value.contains(userIdentity)) {
        myShift = true;
        break;
      }
    }

    if (!roles.containsKey("EMT 7A-7P") || !roles.containsKey("EMT 7P-7A"))
      openShift = true;
    for (MapEntry<String, String> entry in roles.entries) {
      if (entry.key.contains("ALS") ||
          entry.key.contains("BLS") ||
          entry.key.contains("EMT")) {
        if (entry.value == "") {
          openShift = true;
          break;
        }
      }
    }
    if (myShift) events.add("Mine");
    if (openShift) events.add("Open");
    calendarData.add(events);
  }

  return calendarData;
}
