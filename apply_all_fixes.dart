import 'dart:io';

void main() {
  final file = File('lib/state/app_state.dart');
  var content = file.readAsStringSync();

  // 1. Add payMiscVideographerSession
  if (!content.contains('void payMiscVideographerSession')) {
    final payMiscStr = '''
  void payMiscVideographerSession(String taskId) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final t = _tasks[idx];
      t.isPaidToVideographer = true;
      _db.collection('tasks').doc(taskId).update({
        'isPaidToVideographer': true,
      });

      final empIdx = _employees.indexWhere((e) => e.id == t.assignedTo);
      if (empIdx != -1) {
        final emp = _employees[empIdx];
        final amount = t.manualPaymentAmount ?? 0;
        emp.pendingPayAmount = (emp.pendingPayAmount ?? 0) + amount;
        
        final newStr = 'Misc: \${t.title}';
        if (emp.pendingPayMonth == null || emp.pendingPayMonth!.isEmpty) {
          emp.pendingPayMonth = newStr;
        } else {
          emp.pendingPayMonth = '\${emp.pendingPayMonth}, \$newStr';
        }
        
        emp.paymentCleared = true;
        emp.paymentApprovedByEmployee = false;

        _db.collection('employees').doc(emp.id).update({
          'paymentCleared': true,
          'paymentApprovedByEmployee': false,
          'pendingPayAmount': emp.pendingPayAmount,
          'pendingPayMonth': emp.pendingPayMonth,
        });

        _addLog('MISC SESSION PAID: \${emp.name} for \${t.title}');
        _addNotification(
          'Payment cleared for \${emp.name}: \${t.title}',
          'payment',
        );
        notifyListeners();
      }
    }
  }

  void updateClientPaymentsDue''';
    content = content.replaceFirst('  void updateClientPaymentsDue', payMiscStr);
  }

  // 2. Add manualPaymentAmount to assignTask
  if (!content.contains('double? manualPaymentAmount,')) {
    content = content.replaceFirst(
      'bool isApprovedByVideographer = false,\n  }) async {',
      'bool isApprovedByVideographer = false,\n    double? manualPaymentAmount,\n  }) async {'
    );
    content = content.replaceFirst(
      'isApprovedByVideographer: isApprovedByVideographer,\n    );',
      'isApprovedByVideographer: isApprovedByVideographer,\n      manualPaymentAmount: manualPaymentAmount,\n    );'
    );
  }

  // 3. Fix toggleEmployeePaymentApproved
  if (!content.contains("serviceType: (e.role == 'Videographer'")) {
    content = content.replaceFirst(
      "employeeId: e.id,\n          ),",
      "employeeId: e.id,\n            serviceType: (e.role == 'Videographer' && monthStr.contains('Misc:')) ? 'Video Production' : null,\n          ),"
    );
  }

  // 4. Fix acknowledgeVideographerPayment string cleaning
  final ackOld = '''        if (emp.pendingPayMonth != null && emp.pendingPayMonth!.isNotEmpty) {
          List<String> items = emp.pendingPayMonth!.split(',').map((e) => e.trim()).toList();
          items.removeWhere((item) => item.contains(task.title));
          emp.pendingPayMonth = items.join(', ');
        }''';
  final ackNew = '''        if (emp.pendingPayMonth != null && emp.pendingPayMonth!.isNotEmpty) {
          List<String> items = emp.pendingPayMonth!.split(',').map((e) => e.trim()).toList();
          String targetStr1 = 'Misc: \${task.title}';
          String targetStr2 = task.title;
          bool removed = false;
          items.removeWhere((item) {
            if (item == targetStr1 || item == targetStr2) {
              removed = true;
              return true;
            }
            return false;
          });
          emp.pendingPayMonth = items.join(', ');
          if (removed && task.manualPaymentAmount != null) {
            emp.pendingPayAmount = (emp.pendingPayAmount ?? 0) - task.manualPaymentAmount!;
            if (emp.pendingPayAmount! < 0) emp.pendingPayAmount = 0;
          }
        }''';
  if (content.contains(ackOld)) {
    content = content.replaceFirst(ackOld, ackNew);
  }

  file.writeAsStringSync(content);
}
