import 'dart:io';

void main() {
  for (var path in [
    'lib/screens/ceo_dashboard.dart',
    'lib/screens/cofounder_dashboard.dart',
  ]) {
    var file = File(path);
    var content = file.readAsStringSync();

    var pattern = RegExp(
      r'final emp = Employee\(.*?state\.addEmployee\(emp\);',
      dotAll: true,
    );
    var replacement =
        'state.addEmployee(name: _employeeNameCtrl.text, role: _employeeRole, department: _employeeDeptCtrl.text, monthlySalary: double.tryParse(_employeeSalaryCtrl.text) ?? 0.0);';

    content = content.replaceAll(pattern, replacement);
    file.writeAsStringSync(content);
    print('Updated \$path');
  }
}
