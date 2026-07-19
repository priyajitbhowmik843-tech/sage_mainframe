const fs = require('fs');

let empCode = fs.readFileSync('lib/widgets/employee_metrics_panel.dart', 'utf8');

// Fix actualStart in employee_metrics_panel
empCode = empCode.replace(/final actualStart = DateTime\(2026, 7, 20\);/g, `DateTime actualStart = DateTime(now.year, now.month, 1);\n      if (now.year == 2026 && now.month == 7) {\n        actualStart = DateTime(2026, 7, 20);\n      }`);

// Fix shortfall logic in employee_metrics_panel
empCode = empCode.replace(/int assignedCount = tasksForDay\.length;\s+int shortfall = 5 - assignedCount;\s+if \(shortfall < 0\) shortfall = 0;/g, `int assignedCount = tasksForDay.length;\n        int shortfall = 0;\n        if (d.isBefore(today)) {\n          shortfall = 5 - assignedCount;\n          if (shortfall < 0) shortfall = 0;\n        }`);

fs.writeFileSync('lib/widgets/employee_metrics_panel.dart', empCode, 'utf8');

let geCode = fs.readFileSync('lib/screens/graphics_editor_dashboard.dart', 'utf8');

// Fix shortfall logic in graphics_editor_dashboard
geCode = geCode.replace(/int assignedCount = tasksForDay\.length;\s+int shortfall = 5 - assignedCount;\s+if \(shortfall < 0\) shortfall = 0;/g, `int assignedCount = tasksForDay.length;\n        int shortfall = 0;\n        if (d.isBefore(today)) {\n          shortfall = 5 - assignedCount;\n          if (shortfall < 0) shortfall = 0;\n        }`);

fs.writeFileSync('lib/screens/graphics_editor_dashboard.dart', geCode, 'utf8');
console.log('Fixed shortfall logic');
