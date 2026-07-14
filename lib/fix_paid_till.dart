import 'dart:io';

void main() {
  final file = File('lib/screens/employee_dashboard.dart');
  String content = file.readAsStringSync();
  
  final oldLogic = 'String paidTillStr = "\${months[emp.lastPaidDate.month - 1]} \${emp.lastPaidDate.year}";';
  final newLogic = "String paidTillStr = emp.paidMonths.isEmpty ? 'None' : const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'].lastWhere((m) => emp.paidMonths.contains(m), orElse: () => emp.paidMonths.last);";
  
  if (content.contains(oldLogic)) {
    content = content.replaceFirst(oldLogic, newLogic);
    file.writeAsStringSync(content);
    print("Fixed employee_dashboard paidTillStr!");
  } else {
    print("Could not find old paidTillStr logic in employee_dashboard.");
  }

  final videoFile = File('lib/screens/videographer_dashboard.dart');
  String videoContent = videoFile.readAsStringSync();
  
  if (videoContent.contains('final displaySessions = emp.paymentCleared ? (emp.pendingPayMonth ?? "\$unpaidSessionsCount") : "\\\$unpaidSessionsCount";')) {
    final videoInsert = '''
      final displaySessions = emp.paymentCleared ? (emp.pendingPayMonth ?? "\$unpaidSessionsCount") : "\$unpaidSessionsCount";
      final paidTillStr = emp.paidMonths.isEmpty ? 'None' : const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'].lastWhere((m) => emp.paidMonths.contains(m), orElse: () => emp.paidMonths.last);
''';
    videoContent = videoContent.replaceFirst('final displaySessions = emp.paymentCleared ? (emp.pendingPayMonth ?? "\$unpaidSessionsCount") : "\\\$unpaidSessionsCount";', videoInsert);
    
    final financeDataInsert = '''
            title: "FINANCE DATA",
            child: Column(
              children: [
                _profileRow("PAID TILL", paidTillStr),
''';
    videoContent = videoContent.replaceFirst('''
            title: "FINANCE DATA",
            child: Column(
              children: [
''', financeDataInsert);

    videoFile.writeAsStringSync(videoContent);
    print("Fixed videographer_dashboard paidTillStr!");
  } else {
    print("Could not find insertion points in videographer_dashboard.");
  }
}
