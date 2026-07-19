const fs = require('fs');
let code = fs.readFileSync('lib/widgets/employee_metrics_panel.dart', 'utf8');

// 1. Task type check
code = code.replace("t.taskType == 'session' &&", "(t.taskType == 'Session' || t.taskType == 'Miscellaneous Session' || t.taskType == 'session' || t.taskType == 'miscellaneous session') &&");

// 2. Client rate logic
let oldRateLogic = "final rate = employee.perSessionRate > 0 ? employee.perSessionRate : (client?.sessionRate ?? 0);";
let newRateLogic = "final rate = client?.sessionRate ?? 0;";
code = code.replace(oldRateLogic, newRateLogic);

// 3. Expanded child text -> Column with DateFormat
let oldExpanded = "Expanded(child: Text(client?.name ?? 'Unknown Client', style: const TextStyle(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis)),";
let newExpanded = "Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(client?.name ?? 'Unknown Client', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis), Text(DateFormat('dd MMM yyyy').format(t.deadline), style: const TextStyle(fontSize: 9, color: Colors.black54))])),";
code = code.replace(oldExpanded, newExpanded);

fs.writeFileSync('lib/widgets/employee_metrics_panel.dart', code, 'utf8');
console.log("Restored Videographer fixes");
