import sys

def inject(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # We need to find `controller: salaryCtrl,` block and insert `deductionCtrl` below it.
    # It appears exactly twice.
    
    # We will just split by `label: "Fixed Monthly Salary (?)",` and do our replacement.
    # Wait, the exact block is:
    #                   SageTextField(
    #                     controller: salaryCtrl,
    #                     label: "Fixed Monthly Salary (?)",
    #                     keyboardType: TextInputType.number,
    #                   ),
    #                   const SizedBox(height: 10),
    
    target = """                  SageTextField(
                    controller: salaryCtrl,
                    label: "Fixed Monthly Salary (?)",
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),"""
                  
    replacement = target + """
                  SageTextField(
                    controller: deductionCtrl,
                    label: "Deductions (?)",
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),"""

    new_content = content.replace(target, replacement)
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(new_content)
    print(f"Replaced {new_content.count('controller: deductionCtrl')} occurrences in {filepath}")

inject('lib/screens/ceo_dashboard.dart')
inject('lib/screens/cofounder_dashboard.dart')
