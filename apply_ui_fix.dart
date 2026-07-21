import 'dart:io';

void fixCeoDashboard() {
  final file = File('lib/screens/ceo_dashboard.dart');
  var content = file.readAsStringSync();

  // 1. Update MyTasks filter (CEO)
  final oldMyTasks =
      r"final myTasks = state.tasks.where((t) => t.assignedTo == state.activePersona.id && !t.isCompleted).toList();";
  final newMyTasks =
      r"final myTasks = state.tasks.where((t) => t.assignedTo == state.activePersona.id && !t.isCompleted && !(t.taskType ?? '').toLowerCase().contains('upload')).toList();";
  content = content.replaceAll(oldMyTasks, newMyTasks);

  // 2. Update PendingTasks filter (CEO)
  final oldPendingTasks = r'''final pendingTasks = state.tasks.where((t) {
      if (t.isCompleted) return false;''';
  final newPendingTasks = r'''final pendingTasks = state.tasks.where((t) {
      if (t.isCompleted) return false;
      if ((t.taskType ?? '').toLowerCase().contains('upload')) return false;''';
  content = content.replaceAll(oldPendingTasks, newPendingTasks);

  // 3. Update CEO MyTasks rendering
  final oldBuilder = '''              Builder(
                builder: (ctx) {
                  String dateLabel = '';
                  final typeStr = (t.taskType ?? '').toLowerCase();
                  if (typeStr == 'daily video' || typeStr == 'daily post') {
                    dateLabel = "Deadline: \${t.deadline.day}/\${t.deadline.month}";
                  } else if (typeStr == 'session') {
                    dateLabel = "Session Date: \${t.deadline.day}/\${t.deadline.month}";
                  } else if (typeStr == 'miscellaneous' || typeStr == 'misc') {
                    dateLabel = "Misc | Deadline: \${t.deadline.day}/\${t.deadline.month}";
                  } else {
                    dateLabel = "\${t.taskType ?? 'Task'} | Deadline: \${t.deadline.day}/\${t.deadline.month}";
                  }
                  return Text(dateLabel, style: const TextStyle(color: SageColors.primary, fontSize: 11, fontWeight: FontWeight.bold));
                }
              ),''';

  final newBuilder = '''              Builder(
                builder: (ctx) {
                  final typeStr = (t.taskType ?? '').toLowerCase();
                  Color typeColor = Colors.grey;
                  if (typeStr.contains('video')) typeColor = Colors.blue;
                  else if (typeStr.contains('post') || typeStr.contains('photo')) typeColor = Colors.orange;
                  else if (typeStr.contains('session') || typeStr.contains('meeting')) typeColor = Colors.purple;
                  else if (typeStr.contains('product')) typeColor = Colors.brown;
                  else if (typeStr.contains('upload')) typeColor = Colors.teal;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: typeColor)),
                        child: Text((t.taskType ?? 'Task').toUpperCase(), style: TextStyle(color: typeColor, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 4),
                      Text("Deadline: \${t.deadline.day}/\${t.deadline.month}", style: const TextStyle(color: SageColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  );
                }
              ),''';

  if (content.contains(oldBuilder)) {
    content = content.replaceAll(oldBuilder, newBuilder);
  } else {
    print("Could not find old_builder in CEO");
  }

  // 4. Update CEO PendingTasks rendering
  final oldPendingRender =
      '''              Text("\${_getAssigneeName(t.assignedTo, state)} | \${t.deadline.day}/\${t.deadline.month}", style: TextStyle(color: Colors.red.shade700, fontSize: 12, fontWeight: FontWeight.bold)),''';
  final newPendingRender = '''              Builder(
                builder: (ctx) {
                  final typeStr = (t.taskType ?? '').toLowerCase();
                  Color typeColor = Colors.grey;
                  if (typeStr.contains('video')) typeColor = Colors.blue;
                  else if (typeStr.contains('post') || typeStr.contains('photo')) typeColor = Colors.orange;
                  else if (typeStr.contains('session') || typeStr.contains('meeting')) typeColor = Colors.purple;
                  else if (typeStr.contains('product')) typeColor = Colors.brown;
                  else if (typeStr.contains('upload')) typeColor = Colors.teal;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: typeColor)),
                        child: Text((t.taskType ?? 'Task').toUpperCase(), style: TextStyle(color: typeColor, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 4),
                      Text("\${_getAssigneeName(t.assignedTo, state)} | \${t.deadline.day}/\${t.deadline.month}", style: TextStyle(color: Colors.red.shade700, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  );
                }
              ),''';

  if (content.contains(oldPendingRender)) {
    content = content.replaceAll(oldPendingRender, newPendingRender);
  } else {
    print("Could not find old_pending_render in CEO");
  }

  file.writeAsStringSync(content);
  print("Fixed CEO dashboard");
}

void fixCfoDashboard() {
  final file = File('lib/screens/cofounder_dashboard.dart');
  var content = file.readAsStringSync();

  // 1. Update MyTasks filter (CFO)
  final oldMyTasks =
      r"final myTasks = state.tasks.where((t) => t.assignedTo == state.activePersona.id && !t.isCompleted).toList();";
  final newMyTasks =
      r"final myTasks = state.tasks.where((t) => t.assignedTo == state.activePersona.id && !t.isCompleted && !(t.taskType ?? '').toLowerCase().contains('upload')).toList();";
  content = content.replaceAll(oldMyTasks, newMyTasks);

  if (!content.contains(
    r"myTasks.sort((a, b) => a.deadline.compareTo(b.deadline));",
  )) {
    content = content.replaceAll(
      newMyTasks,
      newMyTasks +
          "\n    myTasks.sort((a, b) => a.deadline.compareTo(b.deadline));",
    );
  }

  // 2. Update PendingTasks filter (CFO)
  final oldPendingTasks = r'''final pendingTasks = state.tasks.where((t) {
      if (t.isCompleted) return false;''';
  final newPendingTasks = r'''final pendingTasks = state.tasks.where((t) {
      if (t.isCompleted) return false;
      if ((t.taskType ?? '').toLowerCase().contains('upload')) return false;''';
  content = content.replaceAll(oldPendingTasks, newPendingTasks);

  if (content.contains(
    r"}).toList();" + "\n    \n    " + r"if (pendingTasks.isEmpty)",
  )) {
    content = content.replaceAll(
      r"}).toList();" + "\n    \n    " + r"if (pendingTasks.isEmpty)",
      r"}).toList();" +
          "\n    pendingTasks.sort((a, b) => a.deadline.compareTo(b.deadline));\n    \n    " +
          r"if (pendingTasks.isEmpty)",
    );
  } else if (content.contains(
    r"}).toList();" + "\n    " + r"if (pendingTasks.isEmpty)",
  )) {
    content = content.replaceAll(
      r"}).toList();" + "\n    " + r"if (pendingTasks.isEmpty)",
      r"}).toList();" +
          "\n    pendingTasks.sort((a, b) => a.deadline.compareTo(b.deadline));\n    " +
          r"if (pendingTasks.isEmpty)",
    );
  }

  // 3. Update CFO MyTasks rendering
  final oldMyRender =
      '''              Text("\${t.deadline.day}/\${t.deadline.month}", style: const TextStyle(color: SageColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),''';
  final newMyRender = '''              Builder(
                builder: (ctx) {
                  final typeStr = (t.taskType ?? '').toLowerCase();
                  Color typeColor = Colors.grey;
                  if (typeStr.contains('video')) typeColor = Colors.blue;
                  else if (typeStr.contains('post') || typeStr.contains('photo')) typeColor = Colors.orange;
                  else if (typeStr.contains('session') || typeStr.contains('meeting')) typeColor = Colors.purple;
                  else if (typeStr.contains('product')) typeColor = Colors.brown;
                  else if (typeStr.contains('upload')) typeColor = Colors.teal;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: typeColor)),
                        child: Text((t.taskType ?? 'Task').toUpperCase(), style: TextStyle(color: typeColor, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 4),
                      Text("Deadline: \${t.deadline.day}/\${t.deadline.month}", style: const TextStyle(color: SageColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  );
                }
              ),''';

  if (content.contains(oldMyRender)) {
    content = content.replaceAll(oldMyRender, newMyRender);
  } else {
    print("Could not find old_my_render in CFO");
  }

  // 4. Update CFO PendingTasks rendering
  final oldPendingRender =
      '''              Text("\${_getAssigneeName(t.assignedTo, state)} | \${t.deadline.day}/\${t.deadline.month}", style: TextStyle(color: Colors.red.shade700, fontSize: 12, fontWeight: FontWeight.bold)),''';
  final newPendingRender = '''              Builder(
                builder: (ctx) {
                  final typeStr = (t.taskType ?? '').toLowerCase();
                  Color typeColor = Colors.grey;
                  if (typeStr.contains('video')) typeColor = Colors.blue;
                  else if (typeStr.contains('post') || typeStr.contains('photo')) typeColor = Colors.orange;
                  else if (typeStr.contains('session') || typeStr.contains('meeting')) typeColor = Colors.purple;
                  else if (typeStr.contains('product')) typeColor = Colors.brown;
                  else if (typeStr.contains('upload')) typeColor = Colors.teal;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: typeColor)),
                        child: Text((t.taskType ?? 'Task').toUpperCase(), style: TextStyle(color: typeColor, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 4),
                      Text("\${_getAssigneeName(t.assignedTo, state)} | \${t.deadline.day}/\${t.deadline.month}", style: TextStyle(color: Colors.red.shade700, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  );
                }
              ),''';

  if (content.contains(oldPendingRender)) {
    content = content.replaceAll(oldPendingRender, newPendingRender);
  } else {
    print("Could not find old_pending_render in CFO");
  }

  file.writeAsStringSync(content);
  print("Fixed CFO dashboard");
}

void main() {
  fixCeoDashboard();
  fixCfoDashboard();
}
