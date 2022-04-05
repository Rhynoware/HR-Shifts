import 'package:html/dom.dart';
import 'package:html/parser.dart';

Document loadDocument(String contents) {
  Document document = parse(contents);
  return document;
}

String getUserIdentity(Document document) {
  Element label = document.querySelector("[id='login_label']")!;
  return label.innerHtml.trim();
}

Map<String, String> getRoles(int day, Document document) {
  Map<String, String> roles = {};
  List<String> checkers = [];
  int epoch = 0;

  List<Element> dayLinks = document.querySelectorAll('a');
  for (Element link in dayLinks) {
    String content = link.innerHtml.trim();
    if (content.length <= 2 && content == "$day") {
      epoch = int.parse(link.previousElementSibling?.attributes['value'] ?? "");
      break;
    }
  }

  roles['epoch'] = "$epoch";
  List<Element> finders = document.querySelectorAll("[value='$epoch']");
  if (finders.isEmpty) return {};
  Element finder = finders.last;
  Element dayBox = finder.nextElementSibling!;

  Element? eventCheck = finder.parent?.parent?.parent?.parent?.parent;
  eventCheck = eventCheck?.querySelector("[title^='Events:']");
  if (eventCheck != null) {
    String eventsString = eventCheck.attributes["title"]!;
    eventsString =
        eventsString.replaceAll("Events:\n", "").replaceAll("\n", "");
    List<String> events = eventsString.split("* ");
    events.removeAt(0);
    roles["events"] = events.join("\n");
  }

  bool pmShift = false;

  List<Element> dayData = dayBox.querySelectorAll("td");
  String lastKey = "";
  for (Element e in dayData) {
    Element? ignore = e.querySelector("u, img");
    if (ignore != null) continue;

    String text = "";
    if (day == 0) {
      Element? label = e.querySelector("b");
      if (label != null) {
        text = label.innerHtml;
      } else {
        text = e.innerHtml;
      }
    } else {
      Element? nested = e.querySelector("div");
      if (nested != null) {
        text = nested.innerHtml;
      } else {
        text = text.replaceAll('&nbsp;', '');
        text = e.innerHtml.trim();
        if (text.contains("Shift")) {
          if (text.contains("PM Shift")) pmShift = true;
          text = "";
        }
        if (text != "") text = text.substring(1);
      }
    }

    text = text.replaceAll('&nbsp;', '');
    text = text.replaceAll('nbsp;', '');
    text = text.trim();
    if (text != "") {
      if (text.contains("4th On")) {
        text = text.replaceAll("-4th On", "4th On ${pmShift ? 'PM' : 'AM'}");
        lastKey = text;
      } else if (text.contains(" 7") && text.contains("-")) {
        if (lastKey == "check") lastKey = "";
        lastKey = lastKey
            .replaceAll('-ALS', 'ALS')
            .replaceAll('-BLS', 'BLS')
            .replaceAll('-EMT', 'EMT');
        if (text.contains(" 7") && lastKey != "") roles[lastKey] = "";
        lastKey = text;
      } else if (text.contains("Check")) {
        text = text.replaceAll('-AMB', 'AMB');
        roles["check"] = text;
        lastKey = "check";
      } else if (lastKey == "check") {
        checkers.add(text);
      } else if (text != "") {
        if (lastKey == "check") lastKey = "";
        lastKey = lastKey
            .replaceAll('-ALS', 'ALS')
            .replaceAll('-BLS', 'BLS')
            .replaceAll('-EMT', 'EMT');
        if (lastKey != "") roles[lastKey] = text;
        lastKey = "";
      }
    }
  }

  if (checkers.length > 0) roles["checkers"] = checkers.join(';');
  return roles;
}

List<String> getShifts(Document useDocument) {
  List<String> shifts = [];
  Element shiftsBox = useDocument
      .querySelector(".box_display_myshifts_box")!
      .querySelector(".red_table")!;
  shifts = shiftsBox.innerHtml.trim().replaceAll("\n", "").split("<br>");
  shifts.removeWhere((element) => element.contains("Check"));
  return shifts.sublist(1, shifts.length);
}

String getRosterId(Document document) {
  String name = getUserIdentity(document);
  List<Element> options = document.querySelectorAll('option');

  Element? option;
  for (Element element in options) {
    if (element.innerHtml.contains(name)) {
      option = element;
      break;
    }
  }

  return option!.attributes['value']!;
}

String getDutyId(String html, String shift) {
  Document calendar = loadDocument(html);
  List<Element> labels = calendar.querySelectorAll('td');
  Element? shiftLabel;

  for (Element element in labels) {
    if (element.innerHtml == shift) {
      shiftLabel = element;
      break;
    }
  }

  Element formParent = shiftLabel!.previousElementSibling!;
  Element dutyIdElement = formParent.querySelector("[name='duty_id']")!;
  String dutyId = dutyIdElement.attributes['value']!;
  return dutyId;
}
