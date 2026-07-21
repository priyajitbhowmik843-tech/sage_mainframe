import 'dart:io';

void main() {
  String p;
  String t;

  // 1. ceo_dashboard.dart
  p = 'lib/screens/ceo_dashboard.dart';
  t = File(p).readAsStringSync();
  t = t.replaceAll(
    '      ),\n    );\n  }\n\n  Widget _buildBottomIcon',
    '    );\n  }\n\n  Widget _buildBottomIcon',
  );
  if (!t.contains('void _showAddMemberDialog(BuildContext context) {}')) {
    t = t.replaceAll(
      '  Widget _buildTeamTab() {',
      '  void _showAddMemberDialog(BuildContext context) {}\n  void _showAddLedgerDialog(BuildContext context) {}\n\n  Widget _buildTeamTab() {',
    );
  }
  File(p).writeAsStringSync(t);

  // 2. cofounder_dashboard.dart
  p = 'lib/screens/cofounder_dashboard.dart';
  t = File(p).readAsStringSync();
  t = t.replaceAll(
    '      ),\n    );\n  }\n\n  Widget _buildBottomIcon',
    '    );\n  }\n\n  Widget _buildBottomIcon',
  );
  if (!t.contains('void _showAddMemberDialog(BuildContext context) {}')) {
    t = t.replaceAll(
      '  Widget _buildTeamTab() {',
      '  void _showAddMemberDialog(BuildContext context) {}\n  void _showAddLedgerDialog(BuildContext context) {}\n\n  Widget _buildTeamTab() {',
    );
  }
  File(p).writeAsStringSync(t);

  // 3. employee_dashboard.dart
  p = 'lib/screens/employee_dashboard.dart';
  t = File(p).readAsStringSync();
  t = t.replaceAll(
    '      ),\n    );\n  }\n\n  Widget _buildBottomIcon',
    '    );\n  }\n\n  Widget _buildBottomIcon',
  );
  t = t.replaceAll('_selectedDate.day', '_selectedDate!.day');
  t = t.replaceAll('_selectedDate.month', '_selectedDate!.month');
  t = t.replaceAll('_selectedDate.year', '_selectedDate!.year');
  t = t.replaceAll(
    'selectedDate: _selectedDate,',
    'selectedDate: _selectedDate!,',
  );
  File(p).writeAsStringSync(t);

  // 4. videographer_dashboard.dart
  p = 'lib/screens/videographer_dashboard.dart';
  t = File(p).readAsStringSync();
  t = t.replaceAll(
    '      ),\n    );\n  }\n\n  Widget _buildBottomIcon',
    '    );\n  }\n\n  Widget _buildBottomIcon',
  );
  File(p).writeAsStringSync(t);

  print('Fixes 2 applied!');
}
