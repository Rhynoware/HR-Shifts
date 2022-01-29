import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hr_shifts/Isolates.dart' as Isolates;

Future<Map<String, List<String>>> fetchShiftsAndChecks(
    String userIdentity) async {
  final storage = FlutterSecureStorage();
  String? username = await storage.read(key: "username");
  String? password = await storage.read(key: "password");
  String? token = await storage.read(key: "token");
  String netdutyCookie = await Isolates.getCookie(username!, password!, token!);
  print(netdutyCookie);
  return await compute(
      Isolates.getShiftsAndChecks, [netdutyCookie, userIdentity]);
}

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key, required this.userIdentity}) : super(key: key);

  final String userIdentity;

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  Widget _shiftsList(List<String> shifts) {
    return ListView.builder(
        padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
        itemCount: shifts.length,
        itemBuilder: (BuildContext context, int index) {
          return SizedBox(
              height: 50,
              child: Card(
                  color: Colors.green,
                  child: Center(
                      child: Text("${shifts[index]}",
                          style:
                              TextStyle(fontSize: 28, color: Colors.white)))));
        });
  }

  Widget _checksList(List<String> checks) {
    return ListView.builder(
        padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
        itemCount: checks.length,
        itemBuilder: (BuildContext context, int index) {
          return SizedBox(
              height: 50,
              child: Card(
                  color: Colors.green,
                  child: Center(
                      child: Text("${checks[index]}",
                          style:
                              TextStyle(fontSize: 28, color: Colors.white)))));
        });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, List<String>>>(
        future: fetchShiftsAndChecks(widget.userIdentity),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("Error"),
            );
          } else if (snapshot.hasData) {
            Map<String, List<String>> data = snapshot.data!;
            int shifts = data["shifts"]?.length ?? 0;
            int checks = data["checks"]?.length ?? 0;

            return DefaultTabController(
                length: 2,
                child: Scaffold(
                    appBar: AppBar(
                      centerTitle: true,
                      title: Text(
                        "Report",
                        style: TextStyle(fontSize: 30, color: Colors.white),
                      ),
                      bottom: TabBar(
                        tabs: [
                          Tab(
                            child: Text("Shifts ($shifts/9)",
                                style: TextStyle(
                                    fontSize: 24, color: Colors.white)),
                          ),
                          Tab(
                            child: Text("Checks ($checks/3)",
                                style: TextStyle(
                                    fontSize: 24, color: Colors.white)),
                          )
                        ],
                      ),
                    ),
                    body: TabBarView(children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: _shiftsList(data["shifts"] ?? []),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: _checksList(data["checks"] ?? []),
                      ),
                    ])));
          } else {
            return Scaffold(
              appBar: AppBar(
                  centerTitle: true,
                  title: Text(
                    "Report",
                    style: TextStyle(fontSize: 30, color: Colors.white),
                  )),
              body: Center(child: CircularProgressIndicator()),
            );
          }
        });
  }
}
