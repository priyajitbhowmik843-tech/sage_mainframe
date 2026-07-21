import 'dart:io';

void fixFile(String path) {
  var file = File(path);
  if (!file.existsSync()) return;

  var content = file.readAsStringSync();

  // Fix state.addEmployee(emp)
  content = content.replaceAll(
    'state.addEmployee(emp);',
    'state.addEmployee(name: _employeeNameCtrl.text, role: _employeeRole, department: _employeeDeptCtrl.text, monthlySalary: double.tryParse(_employeeSalaryCtrl.text) ?? 0.0);',
  );

  // Fix payVideographerSessions
  content = content.replaceAll(
    'payVideographerSessions(e.id, count);',
    'payVideographerSessions(e.id, count, true);',
  );

  // Fix _showCFMyTasksOnly
  if (path.contains('cofounder')) {
    if (!content.contains('bool _showCFMyTasksOnly')) {
      content = content.replaceAll(
        'bool _showCFForm = false;',
        'bool _showCFForm = false;\n  bool _showCFMyTasksOnly = false;',
      );
    }
  }

  // Fix broken character in videographer
  if (path.contains('videographer')) {
    content = content.replaceAll('ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¹', 'Rs.');
    content = content.replaceAll('A\'A,AAAA?sAA.AA?sA,A1', 'Rs.');
  }

  file.writeAsStringSync(content);
  print('Fixed $path');
}

void main() {
  fixFile('lib/screens/ceo_dashboard.dart');
  fixFile('lib/screens/cofounder_dashboard.dart');
  fixFile('lib/screens/videographer_dashboard.dart');
}
