import 'dart:io';

void main() {
  var file = File('lib/screens/videographer_dashboard.dart');
  var content = file.readAsStringSync();

  content = content.replaceAll(
    "Text(' ',\n                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1)),",
    "Text('\${months[_calendarMonth.month-1]} \${_calendarMonth.year}',\n                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1)),",
  );

  content = content.replaceAll(
    "Text('', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,",
    "Text('\$day', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,",
  );

  file.writeAsStringSync(content);
  print('Fixed calendar rendering issues!');
}
