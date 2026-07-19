const fs = require('fs');

let content = fs.readFileSync('lib/state/app_state.dart', 'utf-8').replace(/\r\n/g, '\n');

const target = `            expenseType: 'Salary',`;

const replacement = `            expenseType: (monthStr.contains('Misc:') || monthStr.contains('Sessions') || monthStr.contains('Videos')) ? 'Session Payment' : 'Salary',`;

if (content.includes(target)) {
    content = content.replace(target, replacement);
    fs.writeFileSync('lib/state/app_state.dart', content, 'utf-8');
    console.log("Replaced successfully!");
} else {
    console.log("Target not found!");
}
