import 'dart:io';

void main() {
  final ceoCode = File('lib/screens/ceo_dashboard.dart').readAsStringSync();

  // Replace class names and state
  var cfoCode = ceoCode.replaceAll('CeoDashboard', 'CofounderDashboard');
  cfoCode = cfoCode.replaceAll(
    '_CeoDashboardState',
    '_CofounderDashboardState',
  );

  // Update the title
  cfoCode = cfoCode.replaceAll(
    'SOHINI // CEO',
    '\${persona.name.toUpperCase()} // COFOUNDER',
  );

  // Update the persona checking (if any hardcoded CEO checks are there)
  // Actually, CEO dashboard doesn't hardcode the persona name in the top app bar?
  // Let's check what it has:
  // "SOHINI // CEO" -> wait, does it have "SOHINI"?
  // Let's just leave the rest as is for now and we can check diffs.

  File('lib/screens/cofounder_dashboard_new.dart').writeAsStringSync(cfoCode);
  print('Created cofounder_dashboard_new.dart');
}
