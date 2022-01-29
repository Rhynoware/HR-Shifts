import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen(
      {Key? key, required this.calendarData, required this.month})
      : super(key: key);

  final List<List<String>> calendarData;
  final DateTime month;

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  Widget _calendarWidget(List<List<String>> data) {
    return TableCalendar(
      firstDay: DateTime(widget.month.year, widget.month.month, 1),
      lastDay: DateTime(widget.month.year, widget.month.month + 1, 0),
      focusedDay: widget.month.month == DateTime.now().month
          ? DateTime.now()
          : DateTime(widget.month.year, widget.month.month, 1),
      availableCalendarFormats: {CalendarFormat.month: 'Month'},
      calendarStyle: CalendarStyle(
          todayDecoration:
              BoxDecoration(color: Colors.blue, shape: BoxShape.circle)),
      eventLoader: (day) {
        return data[day.day];
      },
      onDaySelected: (selectedDay, focusedDay) {
        HapticFeedback.heavyImpact();
        Navigator.of(context).pop(selectedDay.day - 1);
      },
      headerStyle: HeaderStyle(
          titleCentered: true,
          leftChevronVisible: false,
          rightChevronVisible: false),
      calendarBuilders:
          CalendarBuilders(singleMarkerBuilder: (context, date, event) {
        Color color = event == 'Mine' ? Colors.green : Colors.red;
        return Container(
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            width: 7,
            height: 7,
            margin: EdgeInsets.symmetric(horizontal: 1.5));
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            "Calendar",
            style: TextStyle(fontSize: 30, color: Colors.white),
          ),
        ),
        body: Column(
          children: [
            Padding(padding: EdgeInsets.all(3)),
            Row(
              children: [
                Spacer(),
                Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.green),
                  width: 10,
                  height: 10,
                  margin: EdgeInsets.symmetric(horizontal: 5),
                ),
                Text(
                  "My Shift",
                  style: TextStyle(fontSize: 24),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                ),
                Container(
                  decoration:
                      BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                  width: 10,
                  height: 10,
                  margin: EdgeInsets.symmetric(horizontal: 5),
                ),
                Text("Open Shift", style: TextStyle(fontSize: 24)),
                Spacer()
              ],
            ),
            _calendarWidget(widget.calendarData),
          ],
        ));
  }
}
