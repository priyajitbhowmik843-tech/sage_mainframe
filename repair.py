import re

with open('lib/state/app_state.dart', 'r') as f:
    content = f.read()

target = '''    if (totalPayout > 0) {
        if (monthStr != \\'Unknown\\' && !monthStr.contains(\\'Videos\\') && !monthStr.contains(\\'Sessions\\')) {
          monthsPaid = monthStr.split(\\'/\\').length;'''

# Wait, split(',') not '/'
target = '''    if (totalPayout > 0) {
        if (monthStr != 'Unknown' && !monthStr.contains('Videos') && !monthStr.contains('Sessions')) {
          monthsPaid = monthStr.split(',').length;'''

replacement = '''    if (totalPayout > 0) {
      emp.paymentCleared = true;
      emp.paymentApprovedByEmployee = false;
      emp.pendingPayAmount = totalPayout;
      emp.pendingPayMonth = ' ';
      
      _db.collection('employees').doc(videographerId).update({
        'paymentCleared': true,
        'paymentApprovedByEmployee': false,
        'pendingPayAmount': emp.pendingPayAmount,
        'pendingPayMonth': emp.pendingPayMonth,
      });
    }

    _addLog(' CLEARED FOR APPROVAL:  items to  by ');
    notifyListeners();
  }

  void payEcomExecutiveSkus(String employeeId, int skuCount, double totalPayout) {
    final emp = _employees.where((e) => e.id == employeeId).firstOrNull;
    if (emp == null) return;
    
    emp.skusPaid += skuCount;
    emp.paymentCleared = true;
    emp.paymentApprovedByEmployee = false;
    emp.pendingPayAmount = totalPayout;
    emp.pendingPayMonth = ' SKUs';
    
    _db.collection('employees').doc(employeeId).update({
      'skusPaid': emp.skusPaid,
      'paymentCleared': true,
      'paymentApprovedByEmployee': false,
      'pendingPayAmount': totalPayout,
      'pendingPayMonth': emp.pendingPayMonth,
    });
    
    _addLog('SKUS CLEARED FOR APPROVAL:  SKUs to  by ');
    notifyListeners();
  }

  void toggleEmployeePaymentApproved(String id, bool value) {
    final idx = _employees.indexWhere((e) => e.id == id);
    if (idx != -1) {
      if (value) {
        final e = _employees[idx];
        e.paymentApprovedByEmployee = true;
        e.paymentCleared = false;
        

        final monthStr = e.pendingPayMonth ?? 'Unknown';
        if (monthStr != 'Unknown' && !monthStr.contains('Videos') && !monthStr.contains('Sessions')) {
          monthsPaid = monthStr.split(',').length;'''

content = content.replace(target, replacement)

with open('lib/state/app_state.dart', 'w') as f:
    f.write(content)
print('Repair attempt completed.')
