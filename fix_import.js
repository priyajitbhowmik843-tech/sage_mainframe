const fs = require('fs');
let code = fs.readFileSync('lib/widgets/employee_metrics_panel.dart', 'utf8');
code = code.replace("import '../theme/sage_colors.dart';\n", "");
fs.writeFileSync('lib/widgets/employee_metrics_panel.dart', code, 'utf8');
console.log("Fixed import");
