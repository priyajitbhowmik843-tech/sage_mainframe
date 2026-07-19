const fs = require('fs');
let code = fs.readFileSync('lib/widgets/employee_metrics_panel.dart', 'utf8');

// Use t.deadline instead of t.createdAt
code = code.replace("format(t.createdAt)", "format(t.deadline)");

// Change rate calculation back to client.sessionRate
let oldRateLogic = "final rate = employee.perSessionRate > 0 ? employee.perSessionRate : (client?.sessionRate ?? 0);";
let newRateLogic = "final rate = client?.sessionRate ?? 0;";
code = code.replace(oldRateLogic, newRateLogic);

// Add Miscellaneous Session
let oldType = "t.taskType == 'Session' &&";
let newType = "(t.taskType == 'Session' || t.taskType == 'Miscellaneous Session') &&";
code = code.replace(oldType, newType);

fs.writeFileSync('lib/widgets/employee_metrics_panel.dart', code, 'utf8');
console.log('Fixed Videographer rate, date field, and misc session type');
