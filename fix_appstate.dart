import 'dart:io';

void main() {
  final f = File('lib/state/app_state.dart');
  String c = f.readAsStringSync();
  
  // Add to method signature
  c = c.replaceFirst(
    'double? perDesignRate,', 
    'double? perDesignRate,\n    double? pendingPayDeduction,'
  );
  
  // Add to assignment
  c = c.replaceFirst(
    'if (perDesignRate != null) emp.perDesignRate = perDesignRate;',
    'if (perDesignRate != null) emp.perDesignRate = perDesignRate;\n      if (pendingPayDeduction != null) emp.pendingPayDeduction = pendingPayDeduction;'
  );

  f.writeAsStringSync(c);
  print('Done app_state.dart');
}
