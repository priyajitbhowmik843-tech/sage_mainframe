const fs = require('fs');

function fixDash(filepath) {
    let code = fs.readFileSync(filepath, 'utf8');
    
    // Remove isCofounder: isCofounder,
    code = code.replace(/isCofounder: isCofounder,\s*/g, "");
    
    fs.writeFileSync(filepath, code, 'utf8');
    console.log("Fixed " + filepath);
}

fixDash('lib/screens/ceo_dashboard.dart');
fixDash('lib/screens/cofounder_dashboard.dart');

function fixWidget(filepath) {
    let code = fs.readFileSync(filepath, 'utf8');
    
    code = code.replace(/final bool isCofounder;\s*/g, "");
    code = code.replace(/required this.isCofounder,\s*/g, "");
    
    fs.writeFileSync(filepath, code, 'utf8');
    console.log("Fixed " + filepath);
}
fixWidget('lib/widgets/employee_metrics_panel.dart');
