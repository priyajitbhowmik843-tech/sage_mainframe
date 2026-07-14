import 'dart:io';

void main() {
  final file = File('lib/state/app_state.dart');
  var content = file.readAsStringSync();

  // 1. Replace payEmployeeSalary
  final oldPayEmployeeSalary = RegExp(r'void payEmployeeSalary.*?notifyListeners\(\);\s*\}\s*\}', dotAll: true);
  final newPayEmployeeSalary = '''
  void payEmployeeSalary(String employeeId, List<String> months, double amount) {
    final idx = _employees.indexWhere((e) => e.id == employeeId);
    if (idx != -1) {
      final emp = _employees[idx];
      for (final m in months) {
        if (!emp.paidMonths.contains(m)) emp.paidMonths.add(m);
      }
      emp.paymentCleared = true;
      emp.paymentApprovedByEmployee = false;
      emp.pendingPayAmount = amount;
      emp.pendingPayMonth = months.join(", ");
      
      if (emp.paymentsDue >= months.length) {
        emp.paymentsDue -= months.length;
      } else {
        emp.paymentsDue = 0;
      }
      _db.collection('employees').doc(employeeId).update({
        'paidMonths': emp.paidMonths,
        'paymentCleared': true,
        'paymentApprovedByEmployee': false,
        'pendingPayAmount': amount,
        'pendingPayMonth': emp.pendingPayMonth,
        'paymentsDue': emp.paymentsDue,
      });

      _addLog('SALARY CLEARED FOR APPROVAL: \${emp.name} for \${months.join(", ")} by \${_activePersona.name}');
      notifyListeners();
    }
  }
''';
  content = content.replaceFirst(oldPayEmployeeSalary, newPayEmployeeSalary.trim());

  // 2. Replace payVideographerSessions
  final oldPayVideographerSessions = RegExp(r'void payVideographerSessions.*?notifyListeners\(\);\s*\}', dotAll: true);
  final newPayVideographerSessions = '''
  void payVideographerSessions(String videographerId, int sessionCount) {
    final emp = _employees.where((e) => e.id == videographerId).firstOrNull;
    if (emp == null) return;
    
    final isVideoEditor = emp.role.toLowerCase().contains('video editor');
    
    // Find all unpaid completed sessions for this videographer
    final unpaidSessions = _tasks.where((t) => t.assignedTo == videographerId && (isVideoEditor ? (t.taskType == 'Reel' || t.taskType == 'Video') : t.taskType == 'Session') && t.isCompleted && !t.isPaidToVideographer).toList();
    
    // Sort by deadline to pay oldest first
    unpaidSessions.sort((a, b) => a.deadline.compareTo(b.deadline));
    
    int sessionsToPay = sessionCount;
    if (sessionsToPay > unpaidSessions.length) sessionsToPay = unpaidSessions.length;
    
    double totalPayout = 0;
    
    for (int i = 0; i < sessionsToPay; i++) {
      final t = unpaidSessions[i];
      t.isPaidToVideographer = true;
      _db.collection('tasks').doc(t.id).update({'isPaidToVideographer': true});
      
      if (isVideoEditor) {
        totalPayout += emp.perSessionRate;
      } else {
        final c = _clients.where((client) => client.id == t.clientId).firstOrNull;
        if (c != null) {
          totalPayout += c.sessionRate;
        }
      }
    }
    
    if (totalPayout > 0) {
      emp.paymentCleared = true;
      emp.paymentApprovedByEmployee = false;
      emp.pendingPayAmount = totalPayout;
      emp.pendingPayMonth = '\$sessionsToPay \${isVideoEditor ? "Videos" : "Sessions"}';
      
      _db.collection('employees').doc(videographerId).update({
        'paymentCleared': true,
        'paymentApprovedByEmployee': false,
        'pendingPayAmount': emp.pendingPayAmount,
        'pendingPayMonth': emp.pendingPayMonth,
      });
    }

    _addLog('\${isVideoEditor ? "VIDEOS" : "SESSIONS"} CLEARED FOR APPROVAL: \$sessionsToPay items to \${emp.name} by \${_activePersona.name}');
    notifyListeners();
  }
''';
  content = content.replaceFirst(oldPayVideographerSessions, newPayVideographerSessions.trim());

  // 3. Replace toggleEmployeePaymentApproved
  final oldToggleEmployeePaymentApproved = RegExp(r'void toggleEmployeePaymentApproved.*?notifyListeners\(\);\s*\}\s*\}', dotAll: true);
  final newToggleEmployeePaymentApproved = '''
  void toggleEmployeePaymentApproved(String id, bool value) {
    final idx = _employees.indexWhere((e) => e.id == id);
    if (idx != -1) {
      if (value) {
        final e = _employees[idx];
        e.paymentApprovedByEmployee = true;
        e.paymentCleared = false;
        if (e.paymentsDue > 0) {
          e.paymentsDue -= 1;
        }
        final currentPaid = e.lastPaidDate;
        e.lastPaidDate = DateTime(currentPaid.year, currentPaid.month + 1, currentPaid.day);
        
        final amt = e.pendingPayAmount > 0 ? e.pendingPayAmount : (e.monthlySalary > 0 ? e.monthlySalary : (e.perSessionRate * e.sessionsPerMonth));
        final monthStr = e.pendingPayMonth ?? 'Unknown';
        
        e.pendingPayAmount = 0.0;
        e.pendingPayMonth = null;
        
        _db.collection('employees').doc(id).update({
          'paymentApprovedByEmployee': true,
          'paymentCleared': false,
          'paymentsDue': e.paymentsDue,
          'lastPaidDate': Timestamp.fromDate(e.lastPaidDate),
          'pendingPayAmount': 0.0,
          'pendingPayMonth': FieldValue.delete(),
        });

        // Record the salary expense in the ledger when the payment is finalized
        addFinance(FinanceEntry(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          label: 'Payment - \${e.name} (\$monthStr)',
          amount: amt,
          isIncome: false,
          date: DateTime.now(),
          category: 'Employee Salary',
          expenseType: 'Salary',
          employeeId: e.id,
        ));
      } else {
        _employees[idx].paymentApprovedByEmployee = false;
        _db.collection('employees').doc(id).update({'paymentApprovedByEmployee': false});
      }
      notifyListeners();
    }
  }
''';
  content = content.replaceFirst(oldToggleEmployeePaymentApproved, newToggleEmployeePaymentApproved.trim());

  file.writeAsStringSync(content);
  print('Successfully updated app_state.dart!');
}
