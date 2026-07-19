const fs = require('fs');

function fixDash(filepath) {
    let code = fs.readFileSync(filepath, 'utf8');
    
    if (!code.includes("import '../widgets/employee_metrics_panel.dart';")) {
        code = code.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport '../widgets/employee_metrics_panel.dart';");
    }

    let eIdx = code.indexOf('...state.employees.asMap().entries.map((entry) {');
    if (eIdx === -1) { console.log("Not found empIdx in " + filepath); return; }
    
    // We just look for the row containing "PAY SALARY" or "CLEAR PAYMENT"
    let target = '                        const SizedBox(height: 12),\n                        Row(\n                          mainAxisAlignment: MainAxisAlignment.spaceBetween,\n                          children: [\n                            Row(';
    let targetCRLF = target.replace(/\n/g, '\r\n');
    
    let tIdx = code.indexOf(target, eIdx);
    if (tIdx === -1) tIdx = code.indexOf(targetCRLF, eIdx);
    
    if (tIdx > -1) {
        let inject = `                        EmployeeMetricsPanel(
                          employee: employee,
                          state: state,
                          isVideo: isVideo,
                          isVideoEditorPerVideo: isVideoEditorPerVideo,
                          isEcomExec: isEcomExec,
                          isGraphicsEditor: isGraphicsEditor,
                          isME: isME,
                        ),\n`;
        code = code.substring(0, tIdx) + inject + code.substring(tIdx);
        console.log("Injected EmployeeMetricsPanel in " + filepath);
    } else {
        console.log("Could not find insertion point in " + filepath);
    }
    
    fs.writeFileSync(filepath, code, 'utf8');
}

fixDash('lib/screens/ceo_dashboard.dart');
fixDash('lib/screens/cofounder_dashboard.dart');
