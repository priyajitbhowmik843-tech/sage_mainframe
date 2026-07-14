import 'dart:io';

void main() {
  void fixFile(String path) {
    final file = File(path);
    if (!file.existsSync()) return;
    
    String content = file.readAsStringSync();
    bool changed = false;

    // Undo incorrect Rs. replacements
    if (content.contains('Rs. \${_tasks[idx].title}"')) {
      content = content.replaceAll('Rs. \${_tasks[idx].title}"', '"\${_tasks[idx].title}"');
      changed = true;
    }
    if (content.contains('emp.name} Rs. \${months')) {
      content = content.replaceAll('emp.name} Rs. \${months', 'emp.name} (\${months');
      changed = true;
    }
    if (content.contains('Sessions Rs. \${empName})')) {
      content = content.replaceAll('Sessions Rs. \${empName})', 'Sessions (\${empName})');
      changed = true;
    }
    if (content.contains('Rs. \${DateTime.now().toString().substring(0, 10)}] \$remark')) {
      content = content.replaceAll('Rs. \${DateTime.now().toString().substring(0, 10)}] \$remark', '[\${DateTime.now().toString().substring(0, 10)}] \$remark');
      changed = true;
    }
    if (content.contains('Rs. \${DateTime.now().toString().substring(0, 10)}] \$note')) {
      content = content.replaceAll('Rs. \${DateTime.now().toString().substring(0, 10)}] \$note', '[\${DateTime.now().toString().substring(0, 10)}] \$note');
      changed = true;
    }

    // Now fix the ACTUAL question marks
    if (content.contains('?\$')) {
      content = content.replaceAll('?\$', '₹\$');
      changed = true;
    }
    if (content.contains('?{')) {
      content = content.replaceAll('?{', '₹{');
      changed = true;
    }

    // Fix the specific CEO dashboard salary issue: Text("SALARY: ?\${
    if (content.contains('SALARY: ?\${')) {
       content = content.replaceAll('SALARY: ?\${', 'SALARY: ₹\${');
       changed = true;
    }

    if (changed) {
      file.writeAsStringSync(content);
      print('Restored bugs in \$path');
    }
  }

  fixFile('lib/state/app_state.dart');
  fixFile('lib/screens/ceo_dashboard.dart');
  fixFile('lib/screens/cofounder_dashboard.dart');
  fixFile('lib/screens/marketing_executive_dashboard.dart');
}
