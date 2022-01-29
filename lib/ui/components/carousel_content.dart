import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CarouselContent extends StatefulWidget {
  const CarouselContent(
      {Key? key,
      required this.width,
      required this.roles,
      required this.showSignupSheet})
      : super(key: key);

  final double width;
  final Map<String, String> roles;
  final Function showSignupSheet;

  @override
  _CarouselContentState createState() => _CarouselContentState();
}

class _CarouselContentState extends State<CarouselContent> {
  @override
  Widget build(BuildContext context) {
    String amRolesText = "ALS: ${widget.roles["ALS 7A-7P"] ?? ""}\n" +
        "BLS: ${widget.roles["BLS 7A-7P"] ?? ""}\n" +
        "EMT: ${widget.roles["EMT 7A-7P"] ?? ""}";
    if (widget.roles["4th On AM"] != null) {
      amRolesText += "\n4th On: ${widget.roles["4th On AM"]}";
    }
    String pmRolesText = "ALS: ${widget.roles["ALS 7P-7A"] ?? ""}\n" +
        "BLS: ${widget.roles["BLS 7P-7A"] ?? ""}\n" +
        "EMT: ${widget.roles["EMT 7P-7A"] ?? ""}";
    if (widget.roles["4th On PM"] != null) {
      pmRolesText += "\n4th On: ${widget.roles["4th On PM"]}";
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: SizedBox(
            width: widget.width - 10,
            child: GestureDetector(
              onTap: () {
                if (widget.roles["ALS 7A-7P"] != "" &&
                    widget.roles["ALS 7A-7P"] != null &&
                    widget.roles["BLS 7A-7P"] != "" &&
                    widget.roles["BLS 7A-7P"] != null &&
                    widget.roles["EMT 7A-7P"] != "" &&
                    widget.roles["EMT 7A-7P"] != null) return;
                HapticFeedback.mediumImpact();
                widget.showSignupSheet(widget.roles, true);
              },
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Spacer(),
                        Text("AM", style: TextStyle(fontSize: 30)),
                        Spacer()
                      ],
                    ),
                    Divider(thickness: 1.5, indent: 5, endIndent: 5),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                      child: Text(
                        amRolesText,
                        style: TextStyle(
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
          child: SizedBox(
            width: widget.width - 10,
            child: GestureDetector(
              onTap: () {
                if (widget.roles["ALS 7P-7A"] != "" &&
                    widget.roles["ALS 7P-7A"] != null &&
                    widget.roles["BLS 7P-7A"] != "" &&
                    widget.roles["BLS 7P-7A"] != null &&
                    widget.roles["EMT 7P-7A"] != "" &&
                    widget.roles["EMT 7P-7A"] != null) return;
                HapticFeedback.mediumImpact();
                widget.showSignupSheet(widget.roles, false);
              },
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Spacer(),
                        Text("PM", style: TextStyle(fontSize: 30)),
                        Spacer()
                      ],
                    ),
                    Divider(thickness: 1.5, indent: 5, endIndent: 5),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                      child: Text(
                        pmRolesText,
                        style: TextStyle(
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Visibility(
          visible: widget.roles["events"] != null,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
            child: SizedBox(
              width: widget.width - 10,
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Spacer(),
                        Text("Events", style: TextStyle(fontSize: 30)),
                        Spacer()
                      ],
                    ),
                    Divider(thickness: 1.5, indent: 5, endIndent: 5),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                      child: Text(widget.roles["events"] ?? "",
                          style: TextStyle(fontSize: 24)),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        Visibility(
          visible: widget.roles["check"] != null,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
            child: SizedBox(
              width: widget.width - 10,
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Spacer(),
                        Text("Check", style: TextStyle(fontSize: 30)),
                        Spacer()
                      ],
                    ),
                    Divider(thickness: 1.5, indent: 5, endIndent: 5),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                      child: Text(widget.roles["check"] ?? "",
                          style: TextStyle(fontSize: 24)),
                    )
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
