const fs = require('fs');

function injectHeadings(filepath) {
    let code = fs.readFileSync(filepath, 'utf8');

    // Find the start of personas map
    let pIdx = code.indexOf('...AppState.personas.asMap().entries.map((entry) {');
    if (pIdx > -1) {
        let header1 = 'const Text("LEADERSHIP", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: SageColors.onSurfaceVariant)),\n        const SizedBox(height: 12),\n        ';
        code = code.substring(0, pIdx) + header1 + code.substring(pIdx);
        console.log('Injected LEADERSHIP heading in ' + filepath);
    }

    // Since we just injected text, the index of employees changes, so we search again
    let eIdx = code.indexOf('...state.employees.asMap().entries.map((entry) {');
    if (eIdx > -1) {
        let header2 = 'const SizedBox(height: 24),\n        const Text("EMPLOYEES", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: SageColors.onSurfaceVariant)),\n        const SizedBox(height: 12),\n        ';
        code = code.substring(0, eIdx) + header2 + code.substring(eIdx);
        console.log('Injected EMPLOYEES heading in ' + filepath);
    }

    fs.writeFileSync(filepath, code, 'utf8');
}

injectHeadings('lib/screens/ceo_dashboard.dart');
injectHeadings('lib/screens/cofounder_dashboard.dart');

