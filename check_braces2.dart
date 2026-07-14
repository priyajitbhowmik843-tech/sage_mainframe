
import "dart:io";

void main() {
  var file = File("lib/state/app_state.dart");
  var text = file.readAsStringSync();
  int count = 0;
  bool inString1 = false;
  bool inString2 = false;
  int lineNum = 1;
  for (int i = 0; i < text.length; i++) {
    var c = text[i];
    if (c == '\n') lineNum++;
    if (c == "'" && !inString2 && (i == 0 || text[i-1] != '\\')) inString1 = !inString1;
    if (c == '"' && !inString1 && (i == 0 || text[i-1] != '\\')) inString2 = !inString2;
    if (!inString1 && !inString2) {
      if (c == '{') count++;
      if (c == '}') count--;
    }
    if (count == 0 && lineNum > 10) {
      print("Class ends at line $lineNum");
      break;
    }
  }
}

