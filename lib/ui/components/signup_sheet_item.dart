import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class SignupSheetItem extends StatefulWidget {
  const SignupSheetItem(
      {Key? key,
      required this.index,
      required this.openShifts,
      required this.shownDate,
      required this.showRefreshing,
      required this.signUp})
      : super(key: key);

  final int index;
  final List<String> openShifts;
  final DateTime shownDate;
  final Function showRefreshing;
  final Function signUp;

  @override
  _SignupSheetItemState createState() => _SignupSheetItemState();
}

class _SignupSheetItemState extends State<SignupSheetItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        Navigator.of(context).pop();
        widget.showRefreshing();

        DateFormat shiftFormat = DateFormat("yyyy-MM-dd");
        String formattedDate = shiftFormat.format(widget.shownDate);
        widget.signUp(widget.openShifts[widget.index], formattedDate);
      },
      child: SizedBox(
          height: 50,
          child: Card(
              color: Colors.red,
              child: Center(
                  child: Text(widget.openShifts[widget.index],
                      style: TextStyle(fontSize: 28, color: Colors.white))))),
    );
  }
}
