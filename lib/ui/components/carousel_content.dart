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
    String amALSRoleText = "ALS: ${widget.roles["ALS 7A-7P"] ?? ""}";
    String amBLSRoleText = "BLS: ${widget.roles["BLS 7A-7P"] ?? ""}";
    String amEMTRoleText = "EMT: ${widget.roles["EMT 7A-7P"] ?? ""}";
    String am4thOnRoleText = "4th On: ${widget.roles["4th On AM"] ?? ""}";

    String pmALSRoleText = "ALS: ${widget.roles["ALS 7P-7A"] ?? ""}";
    String pmBLSRoleText = "BLS: ${widget.roles["BLS 7P-7A"] ?? ""}";
    String pmEMTRoleText = "EMT: ${widget.roles["EMT 7P-7A"] ?? ""}";
    String pm4thOnRoleText = "4th On: ${widget.roles["4th On AM"] ?? ""}";

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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            amALSRoleText,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.fade,
                            style: TextStyle(
                              fontSize: 24,
                            ),
                          ),
                          Text(
                            amBLSRoleText,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.fade,
                            style: TextStyle(
                              fontSize: 24,
                            ),
                          ),
                          Text(
                            amEMTRoleText,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.fade,
                            style: TextStyle(
                              fontSize: 24,
                            ),
                          ),
                          Visibility(
                            visible: widget.roles["4th On AM"] != null,
                            child: Text(
                              am4thOnRoleText,
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.fade,
                              style: TextStyle(
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ],
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pmALSRoleText,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.fade,
                            style: TextStyle(
                              fontSize: 24,
                            ),
                          ),
                          Text(
                            pmBLSRoleText,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.fade,
                            style: TextStyle(
                              fontSize: 24,
                            ),
                          ),
                          Text(
                            pmEMTRoleText,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.fade,
                            style: TextStyle(
                              fontSize: 24,
                            ),
                          ),
                          Visibility(
                            visible: widget.roles["4th On PM"] != null,
                            child: Text(
                              pm4thOnRoleText,
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.fade,
                              style: TextStyle(
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ],
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
