
import "dart:io";

void main() {
  var file = File("lib/state/app_state.dart");
  var text = file.readAsStringSync();
  var start = text.indexOf("void toggleClientPaidMonth");
  var end = text.indexOf("void addClientAddOn", start);
  if (start != -1 && end != -1) {
    print(text.substring(start, end));
  } else {
    print("Could not find method.");
  }
}

