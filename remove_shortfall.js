const fs = require('fs');

function removeShortfall(filePath) {
    let code = fs.readFileSync(filePath, 'utf8');
    
    code = code.replace(/int assignedCount = tasksForDay\.length;\s+int shortfall = 0;\s+if \(d\.isBefore\(today\)\) {\s+shortfall = 5 - assignedCount;\s+if \(shortfall < 0\) shortfall = 0;\s+}\s+int rejectedOrManuallyMissed = tasksForDay\.where\(\(t\) => t\.isMissed == true \|\| t\.rejectedAt != null\)\.length;\s+int totalMissedForDay = shortfall \+ rejectedOrManuallyMissed;/g, `int rejectedOrManuallyMissed = tasksForDay.where((t) => t.isMissed == true || t.rejectedAt != null).length;\n        \n        int totalMissedForDay = rejectedOrManuallyMissed;`);
    
    fs.writeFileSync(filePath, code, 'utf8');
    console.log(`Removed shortfall logic from ${filePath}`);
}

removeShortfall('lib/widgets/employee_metrics_panel.dart');
removeShortfall('lib/screens/graphics_editor_dashboard.dart');
