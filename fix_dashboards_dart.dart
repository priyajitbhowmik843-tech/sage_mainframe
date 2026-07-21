import 'dart:io';

void inject(String path) {
  var file = File(path);
  var lines = file.readAsLinesSync();

  int injectedCount = 0;
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains('label: "Fixed Monthly Salary') &&
        lines[i].contains('\u20B9')) {
      if (lines[i + 2].contains(')')) {
        // check if already injected
        if (i + 4 < lines.length && lines[i + 4].contains('deductionCtrl')) {
          continue;
        }

        List<String> toInsert = [
          '                  SageTextField(',
          '                    controller: deductionCtrl,',
          '                    label: "Deductions (\u20B9)",',
          '                    keyboardType: TextInputType.number,',
          '                  ),',
          '                  const SizedBox(height: 10),',
        ];
        lines.insertAll(i + 4, toInsert);
        injectedCount++;
        i += toInsert.length;
      }
    }
  }

  if (injectedCount > 0) {
    file.writeAsStringSync(lines.join('\n'));
    print('Injected $injectedCount in $path');
  } else {
    print('Found 0 in $path');
  }
}

void main() {
  inject('lib/screens/ceo_dashboard.dart');
  inject('lib/screens/cofounder_dashboard.dart');
}
