const fs = require('fs');
let code = fs.readFileSync('lib/widgets/employee_metrics_panel.dart', 'utf8');

code = code.split('"?${').join('"\\u20B9${');
code = code.split("'?${").join("'\\u20B9${");
code = code.split("'? '").join("'\\u20B9 '");

fs.writeFileSync('lib/widgets/employee_metrics_panel.dart', code, 'utf8');
console.log('Fixed INR symbols finally');
