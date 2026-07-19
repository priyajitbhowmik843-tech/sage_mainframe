import 'dart:io';

void main() {
  final file = File('lib/state/app_state.dart');
  var content = file.readAsStringSync();

  final oldFinance = '''        addFinance(
          FinanceEntry(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            label: 'Payment - \${e.name} (\$monthStr)',
            amount: amt,
            isIncome: false,
            date: DateTime.now(),
            category: 'Employee Salary',
            expenseType: 'Salary',
            employeeId: e.id,
          ),
        );''';

  final newFinance = '''        addFinance(
          FinanceEntry(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            label: 'Payment - \${e.name} (\$monthStr)',
            amount: amt,
            isIncome: false,
            date: DateTime.now(),
            category: 'Employee Salary',
            expenseType: 'Salary',
            employeeId: e.id,
            serviceType: (e.role == 'Videographer' && monthStr.contains('Misc:')) ? 'Video Production' : null,
          ),
        );''';

  if (content.contains(oldFinance)) {
    content = content.replaceFirst(oldFinance, newFinance);
    file.writeAsStringSync(content);
    print("Replaced successfully.");
  } else {
    print("Could not find the target code.");
  }
}
