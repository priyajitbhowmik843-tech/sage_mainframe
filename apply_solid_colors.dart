import 'dart:io';

void main() {
  final files = [
    'lib/screens/ceo_dashboard.dart',
    'lib/screens/cofounder_dashboard.dart',
  ];

  for (final path in files) {
    final file = File(path);
    var content = file.readAsStringSync();

    // 1. Background color
    content = content.replaceAll(
      r'decoration: BoxDecoration(color: typeColor == Colors.black ? Colors.white : typeColor.withOpacity(0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: typeColor == Colors.black ? Colors.black : typeColor, width: 2.0)),',
      r'decoration: BoxDecoration(color: typeColor == Colors.black ? Colors.white : typeColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: typeColor == Colors.black ? Colors.black : typeColor, width: 2.0)),',
    );

    // 2. Title text color
    content = content.replaceAll(
      r'Text(t.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),',
      r'Text(t.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: typeColor == Colors.black ? Colors.black : Colors.white)),',
    );

    // 3. Description text color
    content = content.replaceAll(
      r'child: Text(t.description, style: const TextStyle(fontSize: 11, color: Colors.black54)),',
      r'child: Text(t.description, style: TextStyle(fontSize: 11, color: typeColor == Colors.black ? Colors.black54 : Colors.white70)),',
    );

    // 4. TaskType tag color
    content = content.replaceAll(
      r"Text((t.taskType ?? 'Task').toUpperCase(), style: TextStyle(color: typeColor == Colors.black ? Colors.grey : typeColor, fontSize: 9, fontWeight: FontWeight.bold)),",
      r"Text((t.taskType ?? 'Task').toUpperCase(), style: TextStyle(color: typeColor == Colors.black ? Colors.grey : Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),",
    );

    // 5. Deadline (My Tasks)
    content = content.replaceAll(
      r'Text("Deadline: ${t.deadline.day}/${t.deadline.month}", style: const TextStyle(color: SageColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),',
      r'Text("Deadline: ${t.deadline.day}/${t.deadline.month}", style: TextStyle(color: typeColor == Colors.black ? SageColors.primary : Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),',
    );

    // 6. Deadline (Pending Tasks)
    content = content.replaceAll(
      r'Text("${_getAssigneeName(t.assignedTo, state)} | ${t.deadline.day}/${t.deadline.month}", style: TextStyle(color: Colors.red.shade700, fontSize: 11, fontWeight: FontWeight.bold)),',
      r'Text("${_getAssigneeName(t.assignedTo, state)} | ${t.deadline.day}/${t.deadline.month}", style: TextStyle(color: typeColor == Colors.black ? Colors.red.shade700 : Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),',
    );

    file.writeAsStringSync(content);
    print("Updated $path");
  }
}
