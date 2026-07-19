const fs = require('fs');

function updateDashboard(filename) {
    let content = fs.readFileSync(filename, 'utf-8');

    const target = `buildDetailChip("Type", f.expenseType!)`;
    const replacement = `buildDetailChip("Type", (f.expenseType == 'Salary' && (f.label.includes('Misc:') || f.label.includes('Sessions') || f.label.includes('Videos'))) ? 'Session Payment' : f.expenseType!)`;
    
    // Convert includes to contains for Dart
    const finalReplacement = replacement.replace(/includes/g, 'contains');

    if (content.includes(target)) {
        content = content.replace(target, finalReplacement);
        fs.writeFileSync(filename, content, 'utf-8');
        console.log(`Replaced successfully in ${filename}!`);
    } else {
        console.log(`Target not found in ${filename}!`);
    }
}

updateDashboard('lib/screens/ceo_dashboard.dart');
updateDashboard('lib/screens/cofounder_dashboard.dart');
