import 'package:flutter/material.dart';

import 'package:hr_shifts/ui/components/signup_sheet_item.dart';

class SignupSheet extends StatefulWidget {
  const SignupSheet(
      {Key? key,
      required this.openShifts,
      required this.shownDate,
      required this.showRefreshing,
      required this.signUp})
      : super(key: key);

  final List<String> openShifts;
  final DateTime shownDate;
  final Function showRefreshing;
  final Function signUp;

  @override
  _SignupSheetState createState() => _SignupSheetState();
}

class _SignupSheetState extends State<SignupSheet> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
          height: 200,
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
                  child: Text("Sign Up", style: TextStyle(fontSize: 30)),
                ),
                Divider(
                  thickness: 1.5,
                  indent: 10,
                  endIndent: 10,
                ),
                Expanded(
                  child: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                      itemCount: widget.openShifts.length,
                      itemBuilder: (BuildContext context, int index) {
                        return SignupSheetItem(
                            index: index,
                            openShifts: widget.openShifts,
                            shownDate: widget.shownDate,
                            showRefreshing: widget.showRefreshing,
                            signUp: widget.signUp);
                      }),
                ),
              ])),
    );
  }
}
