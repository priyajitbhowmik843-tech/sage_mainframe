import 'dart:io';

void main() {
  final ceoFile = File('lib/screens/ceo_dashboard.dart');
  var ceoContent = ceoFile.readAsStringSync();
  ceoContent = replaceMyTasks(ceoContent);
  ceoContent = replacePendingTasks(ceoContent);
  ceoFile.writeAsStringSync(ceoContent);
  print("Updated ceo_dashboard.dart");

  final cfoFile = File('lib/screens/cofounder_dashboard.dart');
  var cfoContent = cfoFile.readAsStringSync();
  cfoContent = replaceMyTasks(cfoContent);
  cfoContent = replacePendingTasks(cfoContent);
  cfoFile.writeAsStringSync(cfoContent);
  print("Updated cofounder_dashboard.dart");
}

String replaceMyTasks(String content) {
  final oldPrefix = '''      children: myTasks.map((t) {
        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black, width: 1.5)),''';
          
  final newPrefix = '''      children: myTasks.map((t) {
        final typeStr = (t.taskType ?? '').toLowerCase();
        Color typeColor = Colors.black;
        if (typeStr.contains('video')) typeColor = Colors.blue;
        else if (typeStr.contains('post') || typeStr.contains('photo')) typeColor = Colors.orange;
        else if (typeStr.contains('session') || typeStr.contains('meeting')) typeColor = Colors.purple;
        else if (typeStr.contains('product')) typeColor = Colors.brown;
        else if (typeStr.contains('upload')) typeColor = Colors.orange;
        else if (typeStr.contains('misc')) typeColor = Colors.grey;

        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: typeColor == Colors.black ? Colors.white : typeColor.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: typeColor == Colors.black ? Colors.black : typeColor, width: 1.5)),''';
          
  if (content.contains(oldPrefix)) {
    content = content.replaceAll(oldPrefix, newPrefix);
  }

  final oldSuffix = '''              Builder(
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

  final newSuffix = '''              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text((t.taskType ?? 'Task').toUpperCase(), style: TextStyle(color: typeColor == Colors.black ? Colors.grey : typeColor, fontSize: 9, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("Deadline: \${t.deadline.day}/\${t.deadline.month}", style: const TextStyle(color: SageColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),''';

  if (content.contains(oldSuffix)) {
    content = content.replaceAll(oldSuffix, newSuffix);
  }
  return content;
}

String replacePendingTasks(String content) {
  final oldPrefix = '''      children: pendingTasks.map((t) {
        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.shade200)),''';
          
  final newPrefix = '''      children: pendingTasks.map((t) {
        final typeStr = (t.taskType ?? '').toLowerCase();
        Color typeColor = Colors.black;
        if (typeStr.contains('video')) typeColor = Colors.blue;
        else if (typeStr.contains('post') || typeStr.contains('photo')) typeColor = Colors.orange;
        else if (typeStr.contains('session') || typeStr.contains('meeting')) typeColor = Colors.purple;
        else if (typeStr.contains('product')) typeColor = Colors.brown;
        else if (typeStr.contains('upload')) typeColor = Colors.orange;
        else if (typeStr.contains('misc')) typeColor = Colors.grey;

        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: typeColor == Colors.black ? Colors.white : typeColor.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: typeColor == Colors.black ? Colors.black : typeColor, width: 1.5)),''';
          
  if (content.contains(oldPrefix)) {
    content = content.replaceAll(oldPrefix, newPrefix);
  }

  final oldSuffix = '''              Builder(
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

  final newSuffix = '''              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text((t.taskType ?? 'Task').toUpperCase(), style: TextStyle(color: typeColor == Colors.black ? Colors.grey : typeColor, fontSize: 9, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("\${_getAssigneeName(t.assignedTo, state)} | \${t.deadline.day}/\${t.deadline.month}", style: TextStyle(color: Colors.red.shade700, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),''';

  if (content.contains(oldSuffix)) {
    content = content.replaceAll(oldSuffix, newSuffix);
  }
  return content;
}
