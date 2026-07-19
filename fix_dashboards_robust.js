const fs = require('fs');

function inject(filepath) {
    let content = fs.readFileSync(filepath, 'utf8');

    // Find the exact line index for "Fixed Monthly Salary"
    let lines = content.split('\n');
    let matches = 0;
    
    for (let i = 0; i < lines.length; i++) {
        if (lines[i].includes('label: "Fixed Monthly Salary') && lines[i].includes('?')) {
            // Check if the next few lines contain the end of the SageTextField widget
            if (lines[i+2] && lines[i+2].includes(')')) {
                // Now check if we already have Deductions right after
                if (lines[i+4] && lines[i+4].includes('deductionCtrl')) {
                    continue; // Already injected
                }
                
                // Inject the deduction field after the SizedBox
                // usually at i+3 is `const SizedBox(height: 10),`
                let insertIdx = i + 4;
                
                const injectText = `                  SageTextField(
                    controller: deductionCtrl,
                    label: "Deductions (\\u20B9)",
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),`;
                  
                // split injectText by \n so we don't assume \r\n vs \n
                const injectLines = injectText.split('\n').map(l => lines[i].endsWith('\r') ? l + '\r' : l);
                
                lines.splice(insertIdx, 0, ...injectLines);
                matches++;
                i += injectLines.length; // Skip the lines we just added
            }
        }
    }

    if (matches > 0) {
        fs.writeFileSync(filepath, lines.join('\n'), 'utf8');
    }
    console.log(`Replaced ${matches} occurrences in ${filepath}`);
}

inject('lib/screens/ceo_dashboard.dart');
inject('lib/screens/cofounder_dashboard.dart');
