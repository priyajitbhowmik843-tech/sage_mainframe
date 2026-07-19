const fs = require('fs');

function updateDashboard(filename) {
    let content = fs.readFileSync(filename, 'utf-8');

    const target = `"\${f.category} // \${f.date.toString().substring(0, 10)}"`;
    const replacement = `"\${(f.category == 'Employee Salary' && (f.label.contains('Misc:') || f.label.contains('Sessions') || f.label.contains('Videos'))) ? 'Session Payment' : f.category} // \${f.date.toString().substring(0, 10)}"`;

    if (content.includes(target)) {
        content = content.replace(target, replacement);
        fs.writeFileSync(filename, content, 'utf-8');
        console.log(`Replaced successfully in ${filename}!`);
    } else {
        console.log(`Target not found in ${filename}!`);
    }
}

updateDashboard('lib/screens/ceo_dashboard.dart');
updateDashboard('lib/screens/cofounder_dashboard.dart');
