import 'package:flutter/material.dart';
import 'package:hr_shifts/ui/components/shifts_sheet_item.dart';
import 'package:intl/intl.dart';

class ShiftsSheet extends StatefulWidget {
  const ShiftsSheet(
      {Key? key,
      required this.online,
      required this.shiftsData,
      required this.showOfflineDialog,
      required this.showRefreshing,
      required this.userIdentity,
      required this.updateWithNewMonthData,
      required this.updateShownDate,
      required this.jumpToPage})
      : super(key: key);

  final bool online;
  final List<String> shiftsData;
  final Function showOfflineDialog;
  final Function showRefreshing;
  final String userIdentity;
  final Function updateWithNewMonthData;
  final Function updateShownDate;
  final Function jumpToPage;

  @override
  _ShiftsSheetState createState() => _ShiftsSheetState();
}

class _ShiftsSheetState extends State<ShiftsSheet> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
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
              padding: const EdgeInsets.all(6.0),
              child: Text("My Shifts", style: TextStyle(fontSize: 30)),
            ),
            Divider(
              thickness: 1.5,
              indent: 10,
              endIndent: 10,
            ),
            SizedBox(
              height: 300,
              child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                  itemCount: widget.shiftsData.length,
                  itemBuilder: (BuildContext context, int index) {
                    DateFormat shiftFormat = DateFormat("MMM dd");
                    String shiftDate = widget.shiftsData[index].split(' : ')[0];
                    DateTime shift = shiftFormat.parse(shiftDate);
                    shift =
                        DateTime(DateTime.now().year, shift.month, shift.day);

                    return ShiftsSheetItem(
                        online: widget.online,
                        shift: shift,
                        showOfflineDialog: widget.showOfflineDialog,
                        showRefreshing: widget.showRefreshing,
                        userIdentity: widget.userIdentity,
                        updateWithNewMonthData: widget.updateWithNewMonthData,
                        updateShownDate: widget.updateShownDate,
                        jumpToPage: widget.jumpToPage,
                        shiftsData: widget.shiftsData,
                        index: index);
                  }),
            )
          ])),
    );
  }
}
