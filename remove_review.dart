import 'dart:io';

void main() {
  final path = 'lib/screens/cofounder_dashboard.dart';
  final file = File(path);
  if (!file.existsSync()) return;
  
  var content = file.readAsStringSync();
  
  // 1. Remove the CLIENTS REVIEW tab button
  final clientReviewTabBtn = '''
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => setState(() => _clientSubTab = 'REVIEW'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _clientSubTab == 'REVIEW' ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: Text(
                  "REVIEW (\${reviewClients.length})",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _clientSubTab == 'REVIEW' ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
''';
  content = content.replaceAll(clientReviewTabBtn, '');
  
  // 2. Modify displayedClients logic so it doesn't default to reviewClients if 'REVIEW'
  // Actually, if we just remove the button, they can never click it. But we should also make sure the ternary doesn't fail.
  // "final displayedClients = _clientSubTab == 'ACTIVE' ? activeClients : (_clientSubTab == 'LEADS' ? leadClients : reviewClients);"
  content = content.replaceAll(
    "final displayedClients = _clientSubTab == 'ACTIVE' ? activeClients : (_clientSubTab == 'LEADS' ? leadClients : reviewClients);",
    "final displayedClients = _clientSubTab == 'ACTIVE' ? activeClients : leadClients;"
  );
  
  // 3. Remove the TASKS REVIEW tab button
  final taskReviewTabBtn = '''
              _buildTaskSubTabBtn('REVIEW'),
              const SizedBox(width: 4),
''';
  content = content.replaceAll(taskReviewTabBtn, '');
  
  // 4. Remove the rendering of the review tasks subtab
  content = content.replaceAll(
    "if (_taskSubTab == 'REVIEW') _buildTaskReviewSubTab(),",
    ""
  );
  
  // If we remove those buttons, `_clientSubTab` and `_taskSubTab` can never become 'REVIEW'.
  // Thus, the app won't crash even if we leave the unused methods in there, but just to be clean, let's leave them.
  // Wait, what if they were already 'REVIEW'?
  // Initial states: `String _clientSubTab = 'ACTIVE';`, `String _taskSubTab = 'PENDING';`
  
  file.writeAsStringSync(content);
  print('Removed REVIEW tabs from cofounder_dashboard.dart');
}
