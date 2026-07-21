import 'dart:io';

void main() {
  final f = File('lib/state/app_state.dart');
  String c = f.readAsStringSync();

  // Add to addEmployee signature
  c = c.replaceFirst(
    'double perDesignRate = 0.0,',
    'double perDesignRate = 0.0,\n    double pendingPayDeduction = 0.0,',
  );

  // Add to Employee creation in addEmployee
  c = c.replaceFirst(
    'perDesignRate: perDesignRate,',
    'perDesignRate: perDesignRate,\n      pendingPayDeduction: pendingPayDeduction,',
  );

  f.writeAsStringSync(c);
  print('Done app_state.dart');
}
