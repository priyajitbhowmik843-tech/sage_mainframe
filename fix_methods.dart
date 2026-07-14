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

void removeMethod(File file, String methodName) {
  String content = file.readAsStringSync();
  int startIndex = content.indexOf(methodName);
  if (startIndex == -1) return;
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
    int methodStart = content.lastIndexOf('void ', startIndex);
    if (methodStart == -1 || methodStart < startIndex - 20) methodStart = startIndex;
    content = content.replaceRange(methodStart, endIndex, '');
    file.writeAsStringSync(content);
  }
}

void main() {
  final ceoFile = File('lib/screens/ceo_dashboard.dart');
  final cfoFile = File('lib/screens/cofounder_dashboard.dart');
  
  String ceoContent = ceoFile.readAsStringSync();
  
  String getAssignees = extractMethod(ceoContent, 'List<Map<String, String>> _getAssigneesForRole');
  String getAssigneeName = extractMethod(ceoContent, 'String _getAssigneeName');
  String addClient = extractMethod(ceoContent, 'void _showAddClientDialog');
  String editClient = extractMethod(ceoContent, 'void _showEditClientDialog');
  
  // Remove the old botched edit/add from CFO
  removeMethod(cfoFile, 'void _showAddClientDialog');
  removeMethod(cfoFile, 'void _showEditClientDialog');
  
  String cfoContent = cfoFile.readAsStringSync();
  
  // Ensure no lingering errors at the end
  int finalBrace = cfoContent.lastIndexOf('}');
  if (finalBrace != -1) {
    cfoContent = cfoContent.substring(0, finalBrace) + 
      '\n' + getAssignees + 
      '\n' + getAssigneeName + 
      '\n' + addClient + 
      '\n' + editClient + 
      '\n}\n';
    cfoFile.writeAsStringSync(cfoContent);
    print('CFO fixed with actual CEO methods!');
  }
}
