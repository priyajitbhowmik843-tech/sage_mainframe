import re

with open('lib/state/app_state.dart', 'r', encoding='utf-8') as f:
    content = f.read()

pattern = r'''            expenseType: 'Salary',
            employeeId: e\.id,
          \),'''

replacement = '''            expenseType: 'Salary',
            employeeId: e.id,
            serviceType: (e.role == 'Videographer' && monthStr.contains('Misc:')) ? 'Video Production' : null,
          ),'''

content = re.sub(pattern, replacement, content)

with open('lib/state/app_state.dart', 'w', encoding='utf-8') as f:
    f.write(content)
