import 'dart:io';

void main() {
  var file = File('lib/screens/videographer_dashboard.dart');
  var content = file.readAsStringSync();

  content = content.replaceAll(
    "Text('Rate: Rs.', style: TextStyle(fontSize: 11, color: SageColors.primary, fontWeight: FontWeight.bold)),",
    "Text('Rate: Rs.\${client?.sessionRate.toStringAsFixed(0) ?? 0}', style: TextStyle(fontSize: 11, color: SageColors.primary, fontWeight: FontWeight.bold)),",
  );

  content = content.replaceAll(
    "Text('Fixed Rate: Rs./session', style: const TextStyle(fontSize: 11, color: Colors.black54)),",
    "Text('Fixed Rate: Rs.\${c.sessionRate.toStringAsFixed(0)}/session', style: const TextStyle(fontSize: 11, color: Colors.black54)),",
  );

  content = content.replaceAll(
    "Text('Completed:   |  Upcoming: ', style: const TextStyle(fontSize: 10, color: Colors.black38)),",
    '''Builder(builder: (context) {
      final cTasks = state.tasks.where((x) => x.clientId == c.id && x.taskType == 'Session' && x.assignedTo == persona.id);
      final completed = cTasks.where((x) => x.isCompleted).length;
      final upcoming = cTasks.where((x) => !x.isCompleted).length;
      return Text('Completed: \$completed  |  Upcoming: \$upcoming', style: const TextStyle(fontSize: 10, color: Colors.black38));
    }),''',
  );

  content = content.replaceAll(
    "Text('//',\n                      style: const TextStyle(fontSize: 11, color: Colors.black54)),",
    "Text('\${t.deadline.day}/\${t.deadline.month}/\${t.deadline.year}',\n                      style: const TextStyle(fontSize: 11, color: Colors.black54)),",
  );

  content = content.replaceAll(
    "Text('/ | Rs.',\n                                  style: const TextStyle(fontSize: 11, color: Colors.black54)),",
    "Text('\${t.deadline.day}/\${t.deadline.month}/\${t.deadline.year} | Rs.\${client?.sessionRate.toStringAsFixed(0) ?? 0}',\n                                  style: const TextStyle(fontSize: 11, color: Colors.black54)),",
  );

  file.writeAsStringSync(content);
  print('Fixed missing variable interpolations in videographer dashboard!');
}
