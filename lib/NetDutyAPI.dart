import 'dart:convert';

import 'package:http/http.dart' as http;

Future<http.Response> getToken() async {
  Uri uri = Uri.parse('https://www4.netdutyonline.com/index.php/main/');
  final http.Response response = await http.get(uri);

  return response;
}

Future<http.StreamedResponse> getCalendarData(
    String username, String password, String token) async {
  Uri uri = Uri.parse('https://www4.netdutyonline.com/index.php/main/');
  final request = http.MultipartRequest("POST", uri);
  request.fields['action'] = "login";
  request.fields['token'] = token;
  request.fields['width'] = '';
  request.fields['username'] = username;
  request.fields['password'] = password;
  final Future<http.StreamedResponse> response = request.send();

  return response;
}

Future<http.StreamedResponse> getCalendarMonth(
    int month, int year, String cookie) async {
  DateTime date = DateTime(year, month, 1, 6);
  int timestamp = date.millisecondsSinceEpoch ~/ 1000;
  Uri uri = Uri.parse(
      'https://www4.netdutyonline.com/index.php/main/calendar_section');
  final request = http.MultipartRequest("POST", uri);
  request.headers['cookie'] = cookie;
  request.fields['action'] = "view_month";
  request.fields['seldate'] = "$timestamp";
  final Future<http.StreamedResponse> response = request.send();

  return response;
}

Future<http.StreamedResponse> getDutyId(String epoch, String cookie) {
  Uri uri = Uri.parse(
      'https://www4.netdutyonline.com/index.php/main/calendar_section');
  final request = http.MultipartRequest("POST", uri);
  request.headers['cookie'] = cookie;
  request.fields['action'] = 'view_day';
  request.fields['seldate'] = epoch;
  final Future<http.StreamedResponse> response = request.send();

  return response;
}

Future<http.StreamedResponse> signUp(
    String dutyId, String rosterId, String date, String cookie) {
  Uri uri = Uri.parse('https://www4.netdutyonline.com/index.php/shifts/signup');
  final request = http.MultipartRequest("POST", uri);
  request.headers['cookie'] = cookie;
  request.fields['action'] = 'signup';
  request.fields['duty_id'] = dutyId;
  request.fields['dutydate'] = date;
  request.fields['source'] = 'full_sday';
  request.fields['roster_id'] = rosterId;
  request.fields['notes'] = '';
  final Future<http.StreamedResponse> response = request.send();

  return response;
}

Future submitFeedback(String email, String feedback) async {
  Uri uri = Uri.parse(
      "https://lilra8vwm9.execute-api.us-west-2.amazonaws.com/default/collectFeedback");
  Map<String, String> feedbackData = {"email": email, "feedback": feedback};
  final response = await http.post(uri,
      headers: {
        "X-Api-Key": "5evNgxJgaT9P1mbyaw86t77wye3ZcsWG4wYQi7F7",
        "Content-Type": "application/json"
      },
      body: jsonEncode(feedbackData));

  http.Response httpResponse = response;
  print(httpResponse.statusCode);
  return response;
}
