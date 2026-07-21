import 'dart:io';

void main() {
  var file = File('lib/screens/videographer_dashboard.dart');
  var content = file.readAsStringSync();

  content = content.replaceAll(
    RegExp(
      r"Text\(' ',\s*style: const TextStyle\(fontWeight: FontWeight\.bold, fontSize: 15, letterSpacing: 1\)\),",
    ),
    "Text('\${months[_calendarMonth.month-1]} \${_calendarMonth.year}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1)),",
  );

  file.writeAsStringSync(content);
  print('Fixed calendar month label!');
}
