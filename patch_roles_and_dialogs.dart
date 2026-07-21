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

void replaceMethod(File file, String methodName, String newMethod) {
  String content = file.readAsStringSync();
  int startIndex = content.indexOf(methodName);
  if (startIndex == -1) {
    // Append instead
    int lastBrace = content.lastIndexOf('}');
    if (lastBrace != -1) {
      content = content.substring(0, lastBrace) + '\n' + newMethod + '\n}';
    }
    file.writeAsStringSync(content);
    return;
  }
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
    // Check if the previous line had a void or something before methodName
    int methodStart = content.lastIndexOf('void ', startIndex);
    if (methodStart == -1 || methodStart < startIndex - 20)
      methodStart = startIndex;

    content = content.replaceRange(methodStart, endIndex, newMethod);
    file.writeAsStringSync(content);
  }
}

void main() {
  final ceoFile = File('lib/screens/ceo_dashboard.dart');
  final cfoFile = File('lib/screens/cofounder_dashboard.dart');
  final extractFile = File('dialog_extract.txt');
  final fullFile = File('dialog_full.txt');

  // 1. Get Add/Edit Client Dialogs for CFO
  String editClientStr = extractMethod(
    fullFile.readAsStringSync(),
    'void _showEditClientDialog',
  );
  String addClientStr = editClientStr
      .replaceAll(
        '_showEditClientDialog(BuildContext context, Client c)',
        '_showAddClientDialog(BuildContext context)',
      )
      .replaceAll('text: c.name', 'text: ""')
      .replaceAll('text: c.contact.name', 'text: ""')
      .replaceAll('text: c.contact.email', 'text: ""')
      .replaceAll('text: c.contact.phone', 'text: ""')
      .replaceAll('text: c.contact.address', 'text: ""')
      .replaceAll('text: c.contact.website', 'text: ""')
      .replaceAll('text: c.monthlyPayable.toString()', 'text: ""')
      .replaceAll('text: c.nextDueDate', 'text: ""')
      .replaceAll('text: c.paymentsDue.toString()', 'text: "0"')
      .replaceAll('text: c.weeklyReels.toString()', 'text: "0"')
      .replaceAll('text: c.weeklyPosts.toString()', 'text: "0"')
      .replaceAll('text: c.weeklyCarousels.toString()', 'text: "0"')
      .replaceAll('text: c.weeklyStories.toString()', 'text: "0"')
      .replaceAll('text: c.campaigns.toString()', 'text: "0"')
      .replaceAll('text: c.campaignReach', 'text: ""')
      .replaceAll('text: c.postRequirements', 'text: ""')
      .replaceAll(
        'String packageType = c.packageType;',
        'String packageType = "Growth";',
      )
      .replaceAll(
        'String contractPeriod = c.contractPeriod;',
        'String contractPeriod = "3 Months";',
      )
      .replaceAll(
        'String conversionProbability = c.conversionProbability;',
        'String conversionProbability = "Medium";',
      )
      .replaceAll(
        'String retentionHealth = c.retentionHealth;',
        'String retentionHealth = "Good";',
      )
      .replaceAll(
        'String serviceType = c.serviceType;',
        'String serviceType = "Marketing";',
      )
      .replaceAll(
        'bool hasMarketingCommission = c.hasMarketingCommission;',
        'bool hasMarketingCommission = false;',
      )
      .replaceAll(
        'String? marketingExecutiveId = c.marketingExecutiveId;',
        'String? marketingExecutiveId;',
      )
      .replaceAll(
        'String? assignedVideographerId = c.assignedVideographerId;',
        'String? assignedVideographerId;',
      )
      .replaceAll('text: c.sessionRate.toString()', 'text: "0"')
      .replaceAll('if (c.status == \'Lead\')', 'if (true)')
      .replaceAll('c.id', 'DateTime.now().millisecondsSinceEpoch.toString()')
      .replaceAll('updateClient', 'addClient')
      .replaceAll('updateClientVideographer', '//updateClientVideographer')
      .replaceAll('EDIT CLIENT', 'ADD CLIENT');

  replaceMethod(cfoFile, '_showEditClientDialog', editClientStr);
  replaceMethod(cfoFile, '_showAddClientDialog', addClientStr);

  print('Done parsing CFO');
}
