const fs = require('fs');

function inject(filepath) {
    let content = fs.readFileSync(filepath, 'utf8');

    const target = `                  SageTextField(
                    controller: salaryCtrl,
                    label: "Fixed Monthly Salary (\u20B9)",
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),`;
                  
    const replacement = target + `
                  SageTextField(
                    controller: deductionCtrl,
                    label: "Deductions (\u20B9)",
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),`;

    const newContent = content.split(target).join(replacement);
    fs.writeFileSync(filepath, newContent, 'utf8');
    const count = newContent.split('controller: deductionCtrl').length - 1;
    console.log(`Replaced occurrences in ${filepath}, found ${count} deductionCtrls total.`);
}

inject('lib/screens/ceo_dashboard.dart');
inject('lib/screens/cofounder_dashboard.dart');
