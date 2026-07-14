import re
import os

file_path = "lib/screens/employee_dashboard.dart"
with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

# Replace the constructor
content = re.sub(r'class EmployeeDashboard extends StatefulWidget \{\n  final List<String> roles;\n\n  const EmployeeDashboard\(\{super\.key, required this\.roles\}\);\n\n  @override\n  State<EmployeeDashboard> createState\(\) => _EmployeeDashboardState\(\);\n\}',
                 'class EmployeeDashboard extends StatefulWidget {\n  const EmployeeDashboard({super.key});\n\n  @override\n  State<EmployeeDashboard> createState() => _EmployeeDashboardState();\n}', content)

# In _EmployeeDashboardState, replace widget.roles.any calls
# hasVideographer logic
content = re.sub(r'final hasVideographer = widget\.roles\.any\(\(r\) => r\.toLowerCase\(\)\.contains\(\'videographer\'\)\);', 'final hasVideographer = false;', content)
content = re.sub(r'final hasVideoEditor = widget\.roles\.any\(\(r\) => r\.toLowerCase\(\)\.contains\(\'video editor\'\)\);', 'final hasVideoEditor = emp.role.toLowerCase().contains(\'video editor\') || emp.role.toLowerCase().contains(\'video\');', content)

content = re.sub(r'if \(widget\.roles\.any\(\(r\) => r\.toLowerCase\(\)\.contains\(\'videographer\'\)\)\) \.\.\.\[\n\s*_buildTaskCalendarSubTab\(myTasks\),\n\s*const SizedBox\(height: 16\),\n\s*\],', '', content)

with open(file_path, "w", encoding="utf-8") as f:
    f.write(content)

print("Done")
