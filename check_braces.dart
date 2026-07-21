import "dart:io";

void main() {
  var file = File("lib/state/app_state.dart");
  var lines = file.readAsLinesSync();
  int count = 0;
  for (int i = 0; i < lines.length; i++) {
    var line = lines[i];
    // Very naive, just to get an idea
    for (int j = 0; j < line.length; j++) {
      if (line[j] == '{') count++;
      if (line[j] == '}') count--;
    }
    if (count == 0 && i > 10) {
      print("Class ends at line ${i + 1}");
      break;
    }
  }
}
