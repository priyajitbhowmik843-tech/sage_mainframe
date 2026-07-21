import "dart:io";

void main() {
  var file = File("lib/state/app_state.dart");
  var text = file.readAsStringSync();

  var firstIdx = text.indexOf(
    "  void updateClientStatus(String clientId, String status) {",
  );
  var secondIdx = text.indexOf(
    "  void updateClientStatus(String clientId, String status) {",
    firstIdx + 1,
  );

  if (firstIdx != -1 && secondIdx != -1) {
    print("Found duplicate blocks!");
    print("First index: $firstIdx");
    print("Second index: $secondIdx");

    // Delete everything between firstIdx and secondIdx
    var newText = text.substring(0, firstIdx) + text.substring(secondIdx);
    file.writeAsStringSync(newText);
    print("Fixed duplicates successfully.");
  } else {
    print("Could not find both indexes.");
  }
}
