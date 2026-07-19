const fs = require('fs');

function patch(filepath) {
    let code = fs.readFileSync(filepath, 'utf8');
    
    if (!code.includes("import '../widgets/employee_metrics_panel.dart';")) {
        code = code.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport '../widgets/employee_metrics_panel.dart';");
    }

    let parts = code.split('...state.employees.asMap().entries.map((entry) {');
    if (parts.length < 2) {
        console.log("Emp block not found in " + filepath);
        return;
    }
    
    let emp_block = parts[1];
    
    let pattern = /(Row\(\s*mainAxisAlignment:\s*MainAxisAlignment\.spaceBetween,\s*children:\s*\[\s*Row\(\s*children:\s*\[[\s\S]*?"PAY SALARY")/;
    let match = emp_block.match(pattern);
    
    if (!match) {
        console.log("Pattern not found in " + filepath);
        return;
    }
    
    let inject = `                        EmployeeMetricsPanel(
                          employee: employee,
                          state: state,
                          isVideo: isVideo,
                          isVideoEditorPerVideo: isVideoEditorPerVideo,
                          isEcomExec: isEcomExec,
                          isGraphicsEditor: isGraphicsEditor,
                          isME: isME,
                        ),
                        const SizedBox(height: 12),
`;
    
    let new_emp_block = emp_block.substring(0, match.index) + inject + emp_block.substring(match.index);
    
    code = parts[0] + '...state.employees.asMap().entries.map((entry) {' + new_emp_block;
    
    fs.writeFileSync(filepath, code, 'utf8');
    console.log("Injected in " + filepath);
}

patch('lib/screens/ceo_dashboard.dart');
patch('lib/screens/cofounder_dashboard.dart');
