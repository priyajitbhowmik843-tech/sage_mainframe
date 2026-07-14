
import "dart:io";

void main() {
  var file = File("lib/state/app_state.dart");
  var text = file.readAsStringSync();
  var start = text.indexOf("void toggleClientPaidMonth");
  var end = text.indexOf("void addClientAddOn", start);
  var methodText = text.substring(start, end);
  print(methodText);
}

