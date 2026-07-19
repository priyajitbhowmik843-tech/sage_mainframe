import re

def patch(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        code = f.read()
        
    if "import '../widgets/employee_metrics_panel.dart';" not in code:
        code = code.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport '../widgets/employee_metrics_panel.dart';")
        
    # The employee block starts with state.employees
    parts = code.split('...state.employees.asMap().entries.map((entry) {')
    if len(parts) < 2:
        print(f"Emp block not found in {filepath}")
        return
        
    emp_block = parts[1]
    
    # We want to find the row that has 'PAY SALARY'
    # And we want to insert EmployeeMetricsPanel(...) right above its parent Row.
    # The row looks like this:
    # Row(
    #   mainAxisAlignment: MainAxisAlignment.spaceBetween,
    #   children: [ ... 'PAY SALARY' ... ]
    
    pattern = r'(Row\(\s*mainAxisAlignment:\s*MainAxisAlignment\.spaceBetween,\s*children:\s*\[\s*Row\(\s*children:\s*\[[\s\S]*?"PAY SALARY")'
    match = re.search(pattern, emp_block)
    if not match:
        print(f"Pattern not found in {filepath}")
        return
        
    # Insert right before the match
    inject = """                        EmployeeMetricsPanel(
                          employee: employee,
                          state: state,
                          isVideo: isVideo,
                          isVideoEditorPerVideo: isVideoEditorPerVideo,
                          isEcomExec: isEcomExec,
                          isGraphicsEditor: isGraphicsEditor,
                          isME: isME,
                        ),
                        const SizedBox(height: 12),
                        """
    
    new_emp_block = emp_block[:match.start()] + inject + emp_block[match.start():]
    
    code = parts[0] + '...state.employees.asMap().entries.map((entry) {' + new_emp_block
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(code)
    print(f"Injected in {filepath}")

patch('lib/screens/ceo_dashboard.dart')
patch('lib/screens/cofounder_dashboard.dart')
