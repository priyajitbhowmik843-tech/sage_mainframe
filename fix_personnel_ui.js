const fs = require('fs');

function fixDash(filepath) {
    let code = fs.readFileSync(filepath, 'utf8');
    
    if (!code.includes("import '../widgets/employee_metrics_panel.dart';")) {
        code = code.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport '../widgets/employee_metrics_panel.dart';");
    }

    const startSearch = "                  child: Column(\n                    crossAxisAlignment: CrossAxisAlignment.start,\n                    children: [";
    let startIdx = code.indexOf(startSearch);
    
    // We only want to replace it inside `_buildPersonnelTab`.
    // Wait, let's make sure we find the one inside `state.employees` map!
    let empIdx = code.indexOf("...state.employees.asMap().entries.map((entry) {");
    if (empIdx === -1) { console.log("Not found empIdx in " + filepath); return; }
    
    let targetIdx = code.indexOf(startSearch, empIdx);
    if (targetIdx === -1) {
        // Maybe CRLF?
        const startSearchCRLF = "                  child: Column(\r\n                    crossAxisAlignment: CrossAxisAlignment.start,\r\n                    children: [";
        targetIdx = code.indexOf(startSearchCRLF, empIdx);
    }
    
    if (targetIdx > -1) {
        // Find where the children array ends. It ends at:
        //                     ],
        //                   ),
        //                 ),
        //               ],
        //             ),
        //           );
        //         }).toList(),
        
        let endIdx = code.indexOf("                      Row(\n                        mainAxisAlignment: MainAxisAlignment.spaceBetween,\n                        children: [", targetIdx);
        if (endIdx === -1) endIdx = code.indexOf("                      Row(\r\n                        mainAxisAlignment: MainAxisAlignment.spaceBetween,\r\n                        children: [", targetIdx);
        
        if (endIdx > -1) {
            let inject = `                      EmployeeMetricsPanel(
                        employee: employee,
                        state: state,
                        isVideo: isVideo,
                        isVideoEditorPerVideo: isVideoEditorPerVideo,
                        isEcomExec: isEcomExec,
                        isGraphicsEditor: isGraphicsEditor,
                        isME: isME,
                        isCofounder: isCofounder,
                      ),\n                      const SizedBox(height: 12),\n`;
                      
            code = code.substring(0, targetIdx + startSearch.length) + "\n" + inject + code.substring(endIdx);
            console.log("Injected in " + filepath);
        } else {
            console.log("End idx not found in " + filepath);
        }
    } else {
        console.log("Target idx not found in " + filepath);
    }
    
    fs.writeFileSync(filepath, code, 'utf8');
}

fixDash('lib/screens/ceo_dashboard.dart');
fixDash('lib/screens/cofounder_dashboard.dart');
