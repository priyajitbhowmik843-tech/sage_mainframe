import 'dart:io';

String extractMethod(String content, String methodName) {
  int startIndex = content.indexOf(methodName);
  if (startIndex == -1) return '';
  int braceCount = 0;
  bool started = false;
  int endIndex = -1;
  for (int i = startIndex; i < content.length; i++) {
    if (content[i] == '{') {
      started = true;
      braceCount++;
    } else if (content[i] == '}') {
      braceCount--;
    }
    if (started && braceCount == 0) {
      endIndex = i + 1;
      break;
    }
  }
  if (endIndex != -1) {
    return content.substring(startIndex, endIndex);
  }
  return '';
}

void replaceMethod(File file, String methodName, String newMethod) {
  String content = file.readAsStringSync();
  int startIndex = content.indexOf(methodName);
  if (startIndex == -1) {
    // Append instead
    int lastBrace = content.lastIndexOf('}');
    if (lastBrace != -1) {
      content = content.substring(0, lastBrace) + '\n' + newMethod + '\n}';
    }
    file.writeAsStringSync(content);
    return;
  }
  int braceCount = 0;
  bool started = false;
  int endIndex = -1;
  for (int i = startIndex; i < content.length; i++) {
    if (content[i] == '{') {
      started = true;
      braceCount++;
    } else if (content[i] == '}') {
      braceCount--;
    }
    if (started && braceCount == 0) {
      endIndex = i + 1;
      break;
    }
  }
  if (endIndex != -1) {
    int methodStart = content.lastIndexOf('void ', startIndex);
    if (methodStart == -1 || methodStart < startIndex - 20) methodStart = startIndex;
    content = content.replaceRange(methodStart, endIndex, newMethod);
    file.writeAsStringSync(content);
  }
}

void main() {
  final ceoFile = File('lib/screens/ceo_dashboard.dart');
  
  String addMemberMethod = '''
  void _showAddMemberDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final salaryCtrl = TextEditingController(text: "0");
    final rateCtrl1 = TextEditingController(text: "0");
    final rateCtrl2 = TextEditingController(text: "0");
    List<String> selectedRoles = ['Video Editor'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Dialog(
          backgroundColor: SageColors.background,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: TerminalPanel(
              title: "ADD TEAM MEMBER",
              child: Column(children: [
                SageTextField(controller: nameCtrl, label: "Full Name"),
                const SizedBox(height: 10),
                const Text("Select Roles", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 6,
                  runSpacing: -8,
                  children: ['Video Editor', 'Graphics Editor', 'Videographer', 'Marketing Executive', 'Page Management Executive'].map((role) {
                    final isSelected = selectedRoles.contains(role);
                    return FilterChip(
                      label: Text(role, style: const TextStyle(fontSize: 10)),
                      selected: isSelected,
                      onSelected: (val) {
                        setS(() {
                          if (val) selectedRoles.add(role);
                          else selectedRoles.remove(role);
                          if (selectedRoles.isEmpty) selectedRoles.add('Video Editor');
                        });
                      },
                      selectedColor: SageColors.yellowAccent,
                      checkmarkColor: Colors.black,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                SageTextField(controller: salaryCtrl, label: "Fixed Monthly Salary (₹)", keyboardType: TextInputType.number),
                const SizedBox(height: 10),
                SageTextField(controller: rateCtrl1, label: "Per Video/Reel Rate (₹)", keyboardType: TextInputType.number),
                const SizedBox(height: 10),
                SageTextField(controller: rateCtrl2, label: "Per Session Rate (₹)", keyboardType: TextInputType.number),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL", style: TextStyle(color: Colors.white))),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: SageColors.primary),
                      onPressed: () {
                        context.read<AppState>().addEmployee(
                          name: nameCtrl.text,
                          role: selectedRoles.join(', '),
                          department: 'Operations',
                          monthlySalary: double.tryParse(salaryCtrl.text) ?? 0.0,
                          perSessionRate: double.tryParse(rateCtrl2.text) ?? 0.0,
                          perVideoRate: double.tryParse(rateCtrl1.text) ?? 0.0,
                        );
                        Navigator.pop(ctx);
                      },
                      child: const Text("SAVE"),
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
''';

  String editMemberMethod = '''
  void _showEditEmployeeDialog(BuildContext context, Employee e) {
    final rolesList = e.role.split(',').map((s) => s.trim()).toList();
    List<String> selectedRoles = rolesList.isNotEmpty ? List.from(rolesList) : ['Video Editor'];
    final nameCtrl = TextEditingController(text: e.name);
    final salaryCtrl = TextEditingController(text: e.monthlySalary.toString());
    final rateCtrl1 = TextEditingController(text: e.perVideoRate.toString());
    final rateCtrl2 = TextEditingController(text: e.perSessionRate.toString());

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Dialog(
          backgroundColor: SageColors.background,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: TerminalPanel(
              title: "EDIT TEAM RECORD",
              child: Column(children: [
                SageTextField(controller: nameCtrl, label: "Full Name"),
                const SizedBox(height: 10),
                const Text("Select Roles", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 6,
                  runSpacing: -8,
                  children: ['Video Editor', 'Graphics Editor', 'Videographer', 'Marketing Executive', 'Page Management Executive'].map((role) {
                    final isSelected = selectedRoles.contains(role);
                    return FilterChip(
                      label: Text(role, style: const TextStyle(fontSize: 10)),
                      selected: isSelected,
                      onSelected: (val) {
                        setS(() {
                          if (val) selectedRoles.add(role);
                          else selectedRoles.remove(role);
                          if (selectedRoles.isEmpty) selectedRoles.add('Video Editor');
                        });
                      },
                      selectedColor: SageColors.yellowAccent,
                      checkmarkColor: Colors.black,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                SageTextField(controller: salaryCtrl, label: "Fixed Monthly Salary (₹)", keyboardType: TextInputType.number),
                const SizedBox(height: 10),
                SageTextField(controller: rateCtrl1, label: "Per Video/Reel Rate (₹)", keyboardType: TextInputType.number),
                const SizedBox(height: 10),
                SageTextField(controller: rateCtrl2, label: "Per Session Rate (₹)", keyboardType: TextInputType.number),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        context.read<AppState>().terminateEmployee(e.id);
                        Navigator.pop(ctx);
                      },
                      child: const Text("TERMINATE", style: TextStyle(color: Colors.red)),
                    ),
                    Row(
                      children: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL", style: TextStyle(color: Colors.white))),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: SageColors.primary),
                          onPressed: () {
                            context.read<AppState>().updateEmployee(
                              e.id,
                              name: nameCtrl.text,
                              role: selectedRoles.join(', '),
                              monthlySalary: double.tryParse(salaryCtrl.text),
                              perSessionRate: double.tryParse(rateCtrl2.text),
                              perVideoRate: double.tryParse(rateCtrl1.text),
                            );
                            Navigator.pop(ctx);
                          },
                          child: const Text("SAVE"),
                        ),
                      ],
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
''';

  String addLedgerMethod = '''
  void _showAddLedgerDialog(BuildContext context) {
    final labelCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    bool isIncome = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Dialog(
          backgroundColor: SageColors.background,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: TerminalPanel(
              title: "NEW LEDGER ENTRY",
              child: Column(children: [
                SageTextField(controller: labelCtrl, label: "Description"),
                const SizedBox(height: 10),
                SageTextField(controller: amountCtrl, label: "Amount (₹)", keyboardType: TextInputType.number),
                const SizedBox(height: 10),
                SwitchListTile(
                  title: Text(isIncome ? "Incoming (Credit)" : "Outgoing (Debit)", style: const TextStyle(fontSize: 12)),
                  value: isIncome,
                  onChanged: (v) => setS(() => isIncome = v),
                  activeColor: SageColors.green,
                  inactiveTrackColor: SageColors.red.withOpacity(0.5),
                  inactiveThumbColor: SageColors.red,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL", style: TextStyle(color: Colors.white))),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: SageColors.primary),
                      onPressed: () {
                        context.read<AppState>().addFinance(FinanceEntry(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          label: labelCtrl.text,
                          amount: double.tryParse(amountCtrl.text) ?? 0.0,
                          isIncome: isIncome,
                          date: DateTime.now(),
                          category: 'Custom Entry',
                        ));
                        Navigator.pop(ctx);
                      },
                      child: const Text("SAVE"),
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
''';

  replaceMethod(ceoFile, 'void _showAddMemberDialog', addMemberMethod);
  replaceMethod(ceoFile, 'void _showAddLedgerDialog', addLedgerMethod);
  replaceMethod(ceoFile, 'void _showEditEmployeeDialog', editMemberMethod);
  
  print('Done patching CEO dashboard');
}
