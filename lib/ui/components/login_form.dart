import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hr_shifts/NetDutyAPI.dart' as NetDutyAPI;
import 'package:hr_shifts/Isolates.dart' as Isolates;
import 'package:hr_shifts/CalendarModel.dart' as CalendarModel;
import 'package:hr_shifts/ui/screens/RolesScreen.dart';

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _usernameTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  double _formProgress = 0;
  bool invalid = false;
  bool _loggingIn = false;
  bool _online = true;
  String _loginToken = "";
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();

    _checkConnectivity();
  }

  void _showInitializer() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              insetPadding: EdgeInsets.all(130),
              child: Container(
                  width: 50,
                  height: 90,
                  child: Column(
                    children: [
                      Padding(padding: EdgeInsets.all(10)),
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          strokeWidth: 6,
                          valueColor: AlwaysStoppedAnimation(Colors.blue),
                        ),
                      )
                    ],
                  )));
        });
  }

  void _checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      Navigator.of(context).pop();

      final directory = await getApplicationDocumentsDirectory();
      String path = "${directory.path}/schedule.html";
      if (File(path).existsSync()) {
        _online = false;
        _loadCalendarData(online: false);
        return;
      }

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Builder(builder: (context) {
                return Container(
                  width: 200,
                  height: 85,
                  child: Column(
                    children: [
                      Text(
                        "No Connection Detected",
                        style: TextStyle(fontSize: 24),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                      ),
                      Text(
                        "Your device is not connected to the internet",
                        style: TextStyle(fontSize: 22),
                      ),
                    ],
                  ),
                );
              }),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "OK",
                      style: TextStyle(fontSize: 20),
                    ))
              ],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            );
          });
    } else {
      _getToken();
    }
  }

  void _saveCredentials(String username, String password) async {
    await storage.write(key: 'username', value: username);
    await storage.write(key: 'password', value: password);
  }

  void _getToken() {
    Future future = NetDutyAPI.getToken();
    future.then((response) {
      int tokenStart = response.body.indexOf("token' value='") + 14;
      String token = response.body.substring(tokenStart, tokenStart + 10);
      print("Token: $token");
      _loginToken = token;
      storage.write(key: "token", value: token);
      _checkRefresh().then((value) {
        if (value)
          _login();
        else
          _loadCalendarData();
      });
    });
  }

  Future _checkRefresh() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int loadedDay = prefs.getInt("loaded") ?? 0;
    if (DateTime.now().day != loadedDay) {
      print("Refreshing");
      String? username = await storage.read(key: 'username');
      String? password = await storage.read(key: 'password');
      if (username != null && password != null) {
        _usernameTextController.text = username;
        _passwordTextController.text = password;
        int loadedDay = DateTime.now().day;
        prefs.setInt("loaded", loadedDay);
        return true;
      }
    }
    return false;
  }

  Future _login() async {
    HapticFeedback.mediumImpact();

    setState(() {
      _loggingIn = true;
    });

    final Future<StreamedResponse> future = NetDutyAPI.getCalendarData(
        _usernameTextController.text,
        _passwordTextController.text,
        _loginToken);
    future.then((response) async {
      setState(() {
        _loggingIn = false;
      });

      final String responseStr = await response.stream.bytesToString();

      if (!responseStr.contains("login_label")) {
        print("Login failed");
        //int tokenStart = responseStr.indexOf("token' value='") + 14;
        //String token = responseStr.substring(tokenStart, tokenStart + 10);
        //print("Got new token: $token");
        //_loginToken = token;
        _loginFailed();

        return;
      }

      final directory = await getApplicationDocumentsDirectory();
      final file = File("${directory.path}/schedule.html");
      file.writeAsString(responseStr);
      print("Saved to: ${directory.path}/schedule.html");
      _saveCredentials(
          _usernameTextController.text, _passwordTextController.text);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int loadedDay = DateTime.now().day;
      prefs.setInt("loaded", loadedDay);
      _showInitializer();
      _loadCalendarData();
    });
  }

  void _loginFailed() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Builder(builder: (context) {
              return Container(
                width: 250,
                height: 130,
                child: Column(
                  children: [
                    Text(
                      "Login Failed",
                      style: TextStyle(fontSize: 28),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                    ),
                    Text(
                      "Incorrect email or password, please try again.",
                      style: TextStyle(fontSize: 22),
                    ),
                  ],
                ),
              );
            }),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "OK",
                    style: TextStyle(fontSize: 20),
                  ))
            ],
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          );
        });
  }

  void _loadCalendarData({bool online = true}) async {
    final directory = await getApplicationDocumentsDirectory();
    String path = "${directory.path}/schedule.html";
    if (!File(path).existsSync()) {
      Navigator.of(context).pop();
      return;
    }
    print("Loading from file");

    if (!online) {
      _showInitializer();
    }

    final file = File(path);
    final String contents = await file.readAsString();
    var document = await compute(CalendarModel.loadDocument, contents);
    String userIdentity = CalendarModel.getUserIdentity(document);
    String rosterId = CalendarModel.getRosterId(document);
    List<Map<String, String>> rolesData =
        await compute(Isolates.getRolesData, document);
    List<String> shifts = CalendarModel.getShifts(document);
    List<List<String>> calendarData =
        await compute(Isolates.getCalendarData, [document, userIdentity]);
    Navigator.of(context).pop();
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => RolesScreen(
              loginToken: _loginToken,
              online: online,
              userIdentity: userIdentity,
              rosterId: rosterId,
              rolesData: rolesData,
              shifts: shifts,
              calendarScreenData: calendarData,
            )));
  }

  @override
  Widget build(BuildContext context) {
    if (_loginToken == "" && _online)
      Future.delayed(Duration.zero, () => _showInitializer());

    return Form(
      onChanged: () => setState(() {}),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(value: _formProgress),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
                keyboardType: TextInputType.emailAddress,
                textCapitalization: TextCapitalization.none,
                textInputAction: TextInputAction.next,
                controller: _usernameTextController,
                onChanged: (value) {
                  setState(() {
                    if (value.length == 0)
                      _formProgress = 0;
                    else
                      _formProgress = 0.5;
                  });
                },
                style: TextStyle(fontSize: 24),
                decoration: InputDecoration(
                    labelText: "Email",
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.all(15),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide()))),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
                keyboardType: TextInputType.text,
                obscureText: true,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.go,
                onSubmitted: (value) => _login(),
                onChanged: (value) {
                  setState(() {
                    if (value.length == 0)
                      _formProgress = 0.5;
                    else
                      _formProgress = 1;
                  });
                },
                controller: _passwordTextController,
                style: TextStyle(fontSize: 24),
                decoration: InputDecoration(
                    labelText: "Password",
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.all(15),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide()))),
          ),
          Visibility(
            child: Column(children: [
              Padding(
                padding: EdgeInsets.all(8.0),
              ),
              Text(
                "Invalid username or password",
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
              ),
            ]),
            visible: invalid,
          ),
          Container(
            width: 275,
            height: 50,
            child: TextButton(
              style: ButtonStyle(
                foregroundColor:
                    MaterialStateColor.resolveWith((Set<MaterialState> states) {
                  return Colors.white;
                }),
                backgroundColor:
                    MaterialStateColor.resolveWith((Set<MaterialState> states) {
                  return Colors.blue;
                }),
              ),
              onPressed: _usernameTextController.text.isNotEmpty &&
                      _passwordTextController.text.isNotEmpty
                  ? _login
                  : null,
              child: _loggingIn
                  ? Container(
                      width: 25,
                      height: 25,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Text(
                      'Login',
                      style: TextStyle(fontSize: 24),
                    ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(5),
          )
        ],
      ),
    );
  }
}
