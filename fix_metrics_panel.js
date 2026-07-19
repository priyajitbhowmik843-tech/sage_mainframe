const fs = require('fs');
let code = fs.readFileSync('lib/widgets/employee_metrics_panel.dart', 'utf8');
code = code.replace(/!t\.isPaidToVideoEditor/g, "!t.isPaidToVideographer");
fs.writeFileSync('lib/widgets/employee_metrics_panel.dart', code, 'utf8');
console.log("Fixed isPaidToVideoEditor");
