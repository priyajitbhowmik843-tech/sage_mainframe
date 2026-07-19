const fs = require('fs');

function inject(filepath) {
    let content = fs.readFileSync(filepath, 'utf8');

    // Windows usually has \r\n, but git might checkout with \n. We will match using regex to be safe.
    // The exact regex pattern to match:
    const pattern = /                  SageTextField\(\s*controller: salaryCtrl,\s*label: "Fixed Monthly Salary \(?\)",\s*keyboardType: TextInputType\.number,\s*\),\s*const SizedBox\(height: 10\),/g;

    let matches = 0;
    const newContent = content.replace(pattern, (match) => {
        matches++;
        return match + `\n                  SageTextField(\n                    controller: deductionCtrl,\n                    label: "Deductions (?)",\n                    keyboardType: TextInputType.number,\n                  ),\n                  const SizedBox(height: 10),`;
    });

    fs.writeFileSync(filepath, newContent, 'utf8');
    console.log(`Replaced ${matches} occurrences in ${filepath}`);
}

inject('lib/screens/ceo_dashboard.dart');
inject('lib/screens/cofounder_dashboard.dart');
