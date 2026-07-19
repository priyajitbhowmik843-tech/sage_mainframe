const fs = require('fs');
let code = fs.readFileSync('lib/widgets/employee_metrics_panel.dart', 'utf8');
code = code.replace("t.taskType == 'session'", "t.taskType == 'Session'");
code = code.replace(/"\?\\\$\{rate.toStringAsFixed\(0\)\}"/g, '"\\u20B9${rate.toStringAsFixed(0)}"');
code = code.replace(/"\?\\\$\{totalPayout.toStringAsFixed\(0\)\}"/g, '"\\u20B9${totalPayout.toStringAsFixed(0)}"');
fs.writeFileSync('lib/widgets/employee_metrics_panel.dart', code, 'utf8');
console.log('Fixed Videographer Metrics rendering');
