import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hr_shifts/NetDutyAPI.dart' as NetDutyAPI;

class FeedbackSheet extends StatefulWidget {
  const FeedbackSheet(
      {Key? key,
      required this.feedbackController,
      required this.feedbackFocusNode})
      : super(key: key);

  final TextEditingController feedbackController;
  final FocusNode feedbackFocusNode;

  @override
  _FeedbackSheetState createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<FeedbackSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
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
          padding: const EdgeInsets.fromLTRB(10, 8, 0, 0),
          child: Text("Enter your feedback below:",
              style: TextStyle(fontSize: 28)),
        ),
        Divider(
          thickness: 1.5,
          indent: 10,
          endIndent: 10,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: TextField(
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.newline,
              maxLines: 3,
              controller: widget.feedbackController,
              focusNode: widget.feedbackFocusNode,
              style: TextStyle(fontSize: 20),
              decoration: InputDecoration(
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.all(15),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide()))),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(50, 5, 50, 5),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            SizedBox(
              width: 100,
              height: 50,
              child: TextButton(
                style: ButtonStyle(
                  foregroundColor: MaterialStateColor.resolveWith(
                      (Set<MaterialState> states) {
                    return Colors.white;
                  }),
                  backgroundColor: MaterialStateColor.resolveWith(
                      (Set<MaterialState> states) {
                    return Colors.grey[400]!;
                  }),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
            SizedBox(
              width: 100,
              height: 50,
              child: TextButton(
                style: ButtonStyle(
                  foregroundColor: MaterialStateColor.resolveWith(
                      (Set<MaterialState> states) {
                    return Colors.white;
                  }),
                  backgroundColor: MaterialStateColor.resolveWith(
                      (Set<MaterialState> states) {
                    return Colors.blue;
                  }),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  HapticFeedback.mediumImpact();

                  final storage = FlutterSecureStorage();
                  String? email = await storage.read(key: "username");
                  if (email == null) return;

                  NetDutyAPI.submitFeedback(
                      email, widget.feedbackController.text);
                },
                child: Text(
                  'Done',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
          ]),
        ),
        Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom))
      ],
    ));
  }
}
