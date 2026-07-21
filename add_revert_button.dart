import 'dart:io';

void main() {
  final file = File('lib/state/app_state.dart');
  var content = file.readAsStringSync();

  // Add the reset function to app_state.dart
  final funcToAdd = '''
  Future<void> revertEmployeePaymentState(String empId) async {
    final tasksSnap = await _db.collection('tasks').where('assignedTo', isEqualTo: empId).get();
    for (var doc in tasksSnap.docs) {
       doc.reference.update({'isPaidToVideographer': false});
    }
    _db.collection('employees').doc(empId).update({
      'paymentCleared': false,
      'paymentApprovedByEmployee': false,
      'pendingPayAmount': 0.0,
      'pendingPayMonth': FieldValue.delete(),
    });
    // Update local state too
    final idx = _employees.indexWhere((e) => e.id == empId);
    if (idx != -1) {
      _employees[idx].paymentCleared = false;
      _employees[idx].paymentApprovedByEmployee = false;
      _employees[idx].pendingPayAmount = 0.0;
      _employees[idx].pendingPayMonth = null;
    }
    for (var t in _tasks.where((t) => t.assignedTo == empId)) {
      t.isPaidToVideographer = false;
    }
    notifyListeners();
  }
''';

  // Inject it before the last closing brace
  content = content.replaceFirst(RegExp(r'\}\s*$'), '\n$funcToAdd\n}');
  file.writeAsStringSync(content);
  print('Added revert function to app_state.dart');

  final ceoFile = File('lib/screens/ceo_dashboard.dart');
  var ceoContent = ceoFile.readAsStringSync();

  final oldIconButton =
      r"IconButton(" +
      "\n" +
      r"                                  icon: const Icon(Icons.edit_outlined, color: Colors.black),";
  final newIconButton = r"""IconButton(
                                  icon: const Icon(Icons.undo, color: Colors.blue),
                                  onPressed: () {
                                    context.read<AppState>().revertEmployeePaymentState(employee.id);
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Payment state reset for employee!")));
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: Colors.black),""";

  ceoContent = ceoContent.replaceFirst(oldIconButton, newIconButton);
  ceoFile.writeAsStringSync(ceoContent);
  print('Added revert button to ceo_dashboard.dart');
}
