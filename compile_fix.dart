import 'dart:io';

void main() {
  String p; String t;

  // 1. ceo_dashboard.dart
  p = 'lib/screens/ceo_dashboard.dart';
  t = File(p).readAsStringSync();
  if (!t.contains('TextEditingController preferredNameCtrl')) {
    t = t.replaceFirst(
      'TextEditingController phoneCtrl = TextEditingController();',
      'TextEditingController phoneCtrl = TextEditingController();\n  TextEditingController preferredNameCtrl = TextEditingController();'
    );
  }
  // If the replace didn't work because phoneCtrl isn't there, let's just add it near the top of the state class.
  if (!t.contains('TextEditingController preferredNameCtrl = TextEditingController();')) {
     t = t.replaceFirst(
       'class _CeoDashboardState extends State<CeoDashboard> {',
       'class _CeoDashboardState extends State<CeoDashboard> {\n  TextEditingController preferredNameCtrl = TextEditingController();'
     );
  }
  File(p).writeAsStringSync(t);

  // 2. cofounder_dashboard.dart
  p = 'lib/screens/cofounder_dashboard.dart';
  t = File(p).readAsStringSync();
  if (!t.contains('TextEditingController preferredNameCtrl')) {
    t = t.replaceFirst(
      'class _CofounderDashboardState extends State<CofounderDashboard> {',
      'class _CofounderDashboardState extends State<CofounderDashboard> {\n  TextEditingController preferredNameCtrl = TextEditingController();'
    );
  }
  // fix syntax error in cofounder_dashboard.dart
  t = t.replaceFirst('      ),\n    );\n  }\n\n  Widget _buildBottomIcon', '    );\n  }\n\n  Widget _buildBottomIcon');
  // fix missing methods _showAddMemberDialog, _showAddLedgerDialog
  if (!t.contains('void _showAddMemberDialog(BuildContext context)')) {
    t = t.replaceFirst(
      '  Widget _buildTeamTab() {',
      '  void _showAddMemberDialog(BuildContext context) {}\n  void _showAddLedgerDialog(BuildContext context) {}\n\n  Widget _buildTeamTab() {'
    );
  }
  File(p).writeAsStringSync(t);

  // 3. employee_dashboard.dart
  p = 'lib/screens/employee_dashboard.dart';
  t = File(p).readAsStringSync();
  t = t.replaceFirst('      ),\n    );\n  }\n\n  Widget _buildBottomIcon', '    );\n  }\n\n  Widget _buildBottomIcon');
  t = t.replaceFirst('DateTime _selectedDate;', 'DateTime? _selectedDate;'); // It might be initialized already?
  if (t.contains('DateTime _selectedDate = DateTime.now();')) {
      t = t.replaceFirst('DateTime _selectedDate = DateTime.now();', 'DateTime? _selectedDate = DateTime.now();');
  } else {
      t = t.replaceFirst('DateTime _selectedDate;', 'DateTime? _selectedDate;');
  }
  File(p).writeAsStringSync(t);

  // 4. videographer_dashboard.dart
  p = 'lib/screens/videographer_dashboard.dart';
  t = File(p).readAsStringSync();
  t = t.replaceFirst('      ),\n    );\n  }\n\n  Widget _buildBottomIcon', '    );\n  }\n\n  Widget _buildBottomIcon');
  File(p).writeAsStringSync(t);

  // 5. sage_calendar.dart
  p = 'lib/widgets/sage_calendar.dart';
  t = File(p).readAsStringSync();
  t = t.replaceAll('SageColors.brutalistDecoration(color: Colors.white)', 'SageColors.brutalistDecoration()');
  File(p).writeAsStringSync(t);

  print('Fixes applied!');
}
