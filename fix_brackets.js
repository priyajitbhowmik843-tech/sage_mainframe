const fs = require('fs');

function fixBrackets(filepath) {
    let code = fs.readFileSync(filepath, 'utf8');
    
    // Find where children: is followed by EmployeeMetricsPanel
    code = code.replace(/children:\r?\n\s*EmployeeMetricsPanel/g, "children: [\n                      EmployeeMetricsPanel");
    
    fs.writeFileSync(filepath, code, 'utf8');
    console.log("Fixed brackets in " + filepath);
}

fixBrackets('lib/screens/ceo_dashboard.dart');
fixBrackets('lib/screens/cofounder_dashboard.dart');
