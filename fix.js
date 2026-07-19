const fs = require('fs');

let content = fs.readFileSync('lib/state/app_state.dart', 'utf-8');

const target = `            expenseType: 'Salary',
            employeeId: e.id,
          ),`;

const replacement = `            expenseType: 'Salary',
            employeeId: e.id,
            serviceType: (e.role == 'Videographer' && monthStr.includes('Misc:')) ? 'Video Production' : null,
          ),`;

if (content.includes(target)) {
    content = content.replace(target, replacement);
    fs.writeFileSync('lib/state/app_state.dart', content, 'utf-8');
    console.log("Replaced successfully!");
} else {
    console.log("Target not found!");
}
