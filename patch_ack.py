import re
with open('lib/state/app_state.dart', 'r', encoding='utf-8') as f:
    content = f.read()

target = """  void acknowledgeVideographerPayment(String taskId) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      _tasks[idx].isPaymentAcknowledgedByVideographer = true;
      _db.collection('tasks').doc(taskId).update({
        'isPaymentAcknowledgedByVideographer': true,
      });"""

replacement = """  void acknowledgeVideographerPayment(String taskId) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final task = _tasks[idx];
      task.isPaymentAcknowledgedByVideographer = true;
      _db.collection('tasks').doc(taskId).update({
        'isPaymentAcknowledgedByVideographer': true,
      });

      final empIdx = _employees.indexWhere((e) => e.id == task.assignedTo);
      if (empIdx != -1) {
        final emp = _employees[empIdx];
        if (emp.pendingPayMonth != null && emp.pendingPayMonth!.isNotEmpty) {
          List<String> items = emp.pendingPayMonth!.split(',').map((e) => e.trim()).toList();
          String targetStr1 = 'Misc: ';
          String targetStr2 = task.title;
          bool removed = false;
          items.removeWhere((item) {
            if (item == targetStr1 || item == targetStr2) {
              removed = true;
              return true;
            }
            return false;
          });
          if (removed) {
            emp.pendingPayMonth = items.join(', ');
            if (emp.pendingPayMonth!.isEmpty) emp.pendingPayMonth = null;
            
            if (task.manualPaymentAmount != null && task.manualPaymentAmount! > 0) {
              emp.pendingPayAmount = (emp.pendingPayAmount ?? 0) - task.manualPaymentAmount!;
              if (emp.pendingPayAmount! < 0) emp.pendingPayAmount = 0.0;
            } else if (task.taskType == 'Session') {
              emp.pendingPayAmount = (emp.pendingPayAmount ?? 0) - emp.perSessionRate;
              if (emp.pendingPayAmount! < 0) emp.pendingPayAmount = 0.0;
            }

            _db.collection('employees').doc(emp.id).update({
              'pendingPayMonth': emp.pendingPayMonth,
              'pendingPayAmount': emp.pendingPayAmount,
            });
          }
        }
      }"""

content = content.replace(target, replacement)
with open('lib/state/app_state.dart', 'w', encoding='utf-8') as f:
    f.write(content)
