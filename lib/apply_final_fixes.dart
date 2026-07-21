import 'dart:io';

void main() {
  final file = File('lib/screens/videographer_dashboard.dart');
  String content = file.readAsStringSync();

  // 1. Back button fix
  if (content.contains('return Scaffold(')) {
    final willPopScopeString = '''return WillPopScope(
      onWillPop: () async {
        if (_tab != 0) {
          setState(() => _tab = 0);
          return false;
        }
        return true;
      },
      child: Scaffold(''';

    content = content.replaceFirst('return Scaffold(', willPopScopeString);

    // The end of the build method is EXACTLY before `Widget _navIcon`
    final buildEndRegex = RegExp(
      r'\r?\n        \),\r?\n      \);\r?\n    \}\r?\n\r?\n  Widget _navIcon',
    );
    content = content.replaceFirstMapped(buildEndRegex, (match) {
      return '\n        ),\n      ),\n    );\n  }\n\n  Widget _navIcon';
    });
    print('Applied back button fix.');
  }

  // 2. Paid Till fix
  if (content.contains(
    'final displaySessions = emp.paymentCleared ? (emp.pendingPayMonth ?? "\$unpaidSessionsCount") : "\\\$unpaidSessionsCount";',
  )) {
    final videoInsert = '''
      final displaySessions = emp.paymentCleared ? (emp.pendingPayMonth ?? "\$unpaidSessionsCount") : "\\\$unpaidSessionsCount";
      final paidTillStr = emp.paidMonths.isEmpty ? 'None' : const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'].lastWhere((m) => emp.paidMonths.contains(m), orElse: () => emp.paidMonths.last);
''';
    content = content.replaceFirst(
      'final displaySessions = emp.paymentCleared ? (emp.pendingPayMonth ?? "\$unpaidSessionsCount") : "\\\$unpaidSessionsCount";',
      videoInsert,
    );

    final financeDataInsert = '''
            title: "FINANCE DATA",
            child: Column(
              children: [
                _profileRow("PAID TILL", paidTillStr),
''';
    content = content.replaceFirst('''
            title: "FINANCE DATA",
            child: Column(
              children: [
''', financeDataInsert);
    print('Applied paid till fix.');
  }

  file.writeAsStringSync(content);
}
