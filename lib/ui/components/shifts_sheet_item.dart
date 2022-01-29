import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hr_shifts/Isolates.dart' as Isolates;

class ShiftsSheetItem extends StatefulWidget {
  const ShiftsSheetItem(
      {Key? key,
      required this.online,
      required this.shift,
      required this.showOfflineDialog,
      required this.showRefreshing,
      required this.userIdentity,
      required this.updateWithNewMonthData,
      required this.updateShownDate,
      required this.jumpToPage,
      required this.shiftsData,
      required this.index})
      : super(key: key);

  final bool online;
  final DateTime shift;
  final Function showOfflineDialog;
  final Function showRefreshing;
  final String userIdentity;
  final Function updateWithNewMonthData;
  final Function updateShownDate;
  final Function jumpToPage;
  final List<String> shiftsData;
  final int index;

  @override
  _ShiftsSheetItemState createState() => _ShiftsSheetItemState();
}

class _ShiftsSheetItemState extends State<ShiftsSheetItem> {
  @override
  Widget build(BuildContext context) {
    final storage = FlutterSecureStorage();

    return GestureDetector(
      onTap: () async {
        HapticFeedback.mediumImpact();
        bool loadedNew = false;

        if (widget.shift.month != DateTime.now().month) {
          if (!widget.online) {
            widget.showOfflineDialog();
            return;
          }

          loadedNew = true;
          widget.showRefreshing();

          String? username = await storage.read(key: "username");
          String? password = await storage.read(key: "password");
          String? token = await storage.read(key: "token");
          Map<String, dynamic> newMonthData = await compute(
              Isolates.getNewMonth,
              [widget.shift, widget.userIdentity, username, password, token]);
          widget.updateWithNewMonthData(newMonthData, widget.shift);

          Navigator.of(context).pop();
        }
        int selectedDate = widget.shift.day;
        Navigator.of(context).pop();

        widget.updateShownDate(
            DateTime(widget.shift.year, widget.shift.month, selectedDate));

        if (loadedNew) await Future.delayed(Duration(milliseconds: 200));
        widget.jumpToPage(selectedDate - 1);
      },
      child: SizedBox(
          height: 50,
          child: Card(
              color: widget.shift.month == DateTime.now().month || widget.online
                  ? Colors.green
                  : Colors.grey,
              child: Center(
                  child: Text(widget.shiftsData[widget.index],
                      style: TextStyle(fontSize: 28, color: Colors.white))))),
    );
  }
}
