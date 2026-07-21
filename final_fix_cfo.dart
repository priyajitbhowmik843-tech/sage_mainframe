import 'dart:io';

String extractMethod(String content, String methodName) {
  int startIndex = content.indexOf(methodName);
  if (startIndex == -1) return '';
  int braceCount = 0;
  bool started = false;
  int endIndex = -1;
  for (int i = startIndex; i < content.length; i++) {
    if (content[i] == '{') {
      started = true;
      braceCount++;
    } else if (content[i] == '}') {
      braceCount--;
    }
    if (started && braceCount == 0) {
      endIndex = i + 1;
      break;
    }
  }
  if (endIndex != -1) {
    return content.substring(startIndex, endIndex);
  }
  return '';
}

void main() {
  final cfoFile = File('lib/screens/cofounder_dashboard.dart');
  final tempCfoFile = File('temp_cfo_client.txt');
  final extractFile = File('dialog_extract.txt');
  final ceoFile = File('lib/screens/ceo_dashboard.dart');

  // 1. Base content from temp_cfo_client.txt
  String cfoContent = tempCfoFile.readAsStringSync();
  // Ensure temp_cfo_client.txt actually ends cleanly with _getAvatarColor closing brace
  if (!cfoContent.trim().endsWith('}')) {
    cfoContent += '\n}\n';
  }

  // 2. Add variables for the tabs
  String variables = '''

  bool _showTeamForm = false;

''';
  cfoContent += variables;

  // 3. Add tabs from dialog_extract.txt
  String extractContent = extractFile.readAsStringSync();
  int personnelIdx = extractContent.indexOf('Widget _buildPersonnelTab()');
  if (personnelIdx != -1) {
    String tabsContent = extractContent.substring(personnelIdx);
    // Remove trailing braces to ensure clean slate
    while (tabsContent.trim().endsWith('}')) {
      tabsContent = tabsContent.substring(0, tabsContent.lastIndexOf('}'));
    }
    cfoContent += tabsContent + '\n}\n'; // Close the last tab method cleanly
  }

  // 4. Add missing methods from CEO
  String ceoContent = ceoFile.readAsStringSync();
  String getAssignees = extractMethod(
    ceoContent,
    'List<Map<String, String>> _getAssigneesForRole',
  );
  String getAssigneeName = extractMethod(ceoContent, 'String _getAssigneeName');
  String addClient = extractMethod(ceoContent, 'void _showAddClientDialog');
  String editClient = extractMethod(ceoContent, 'void _showEditClientDialog');

  cfoContent +=
      '\n' +
      getAssignees +
      '\n' +
      getAssigneeName +
      '\n' +
      addClient +
      '\n' +
      editClient +
      '\n}\n';

  cfoFile.writeAsStringSync(cfoContent);
  print('CFO perfectly reconstructed!');
}
