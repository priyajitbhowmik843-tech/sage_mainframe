const fs = require('fs');
let code = fs.readFileSync('lib/widgets/employee_metrics_panel.dart', 'utf8');

code = code.split('"?${rate.toStringAsFixed(0)}"').join('"?${rate.toStringAsFixed(0)}"');
code = code.split('"?${totalPayout.toStringAsFixed(0)}"').join('"?${totalPayout.toStringAsFixed(0)}"');
code = code.split("'?${t.videoEditorPayRate ?? 0}'").join("'?${t.videoEditorPayRate ?? 0}'");

fs.writeFileSync('lib/widgets/employee_metrics_panel.dart', code, 'utf8');
console.log('Fixed INR symbols strictly');
