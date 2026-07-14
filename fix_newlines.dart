import 'dart:io';

void fixVideoDashboard(String filename) {
  var file = File(filename);
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();

  content = content.replaceAll(r"\n", "\n");
  
  file.writeAsStringSync(content);
}

void main() {
  fixVideoDashboard('lib/screens/videographer_dashboard.dart');
  print('Done!');
}
