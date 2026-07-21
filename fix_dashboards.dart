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
  // 1. Fix CEO dashboard colors
  final ceoFile = File('lib/screens/ceo_dashboard.dart');
  String ceoContent = ceoFile.readAsStringSync();
  ceoContent = ceoContent.replaceAll('SageColors.green', 'Colors.green');
  ceoContent = ceoContent.replaceAll('SageColors.red', 'Colors.red');
  ceoFile.writeAsStringSync(ceoContent);
  print('Fixed CEO colors');

  // 2. Re-copy CFO dashboard
  final cfoFile = File('lib/screens/cofounder_dashboard.dart');
  final tempCfoFile = File('temp_cfo_client.txt');
  String cfoContent = tempCfoFile.readAsStringSync();

  // 3. Extract and append tabs from dialog_extract.txt
  final extractFile = File('dialog_extract.txt');
  String extractContent = extractFile.readAsStringSync();

  // Find where _buildPersonnelTab starts in dialog_extract
  int personnelIdx = extractContent.indexOf('Widget _buildPersonnelTab()');
  if (personnelIdx != -1) {
    // Append the _showTeamForm and _taskSubTab variables which were missed
    String variables = '''
  bool _showTeamForm = false;
  String _taskSubTab = 'ALL';
''';
    // Remove the trailing '}' of the class before appending
    int lastBrace = cfoContent.lastIndexOf('}');
    if (lastBrace != -1) {
      cfoContent = cfoContent.substring(0, lastBrace);
    }

    // Append variables and the rest of dialog_extract
    cfoContent += '\n' + variables + extractContent.substring(personnelIdx);
  }

  // Ensure it doesn't have an extra '}' or is missing one.
  // dialog_extract.txt was truncated before the last '}'.
  cfoContent += '\n}\n';

  // Write the file so far
  cfoFile.writeAsStringSync(cfoContent);

  // 4. Extract client dialogs from dialog_full.txt
  final fullFile = File('dialog_full.txt');
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
      .replaceAll('if (c.status == \\\'Lead\\\')', 'if (true)')
      .replaceAll('c.id', 'DateTime.now().millisecondsSinceEpoch.toString()')
      .replaceAll('updateClient', 'addClient')
      .replaceAll('updateClientVideographer', '//updateClientVideographer')
      .replaceAll('EDIT CLIENT', 'ADD CLIENT');

  // Since we know the end of the class is now guaranteed clean, we can just insert it before the last '}'
  cfoContent = cfoFile.readAsStringSync();
  int finalBrace = cfoContent.lastIndexOf('}');
  if (finalBrace != -1) {
    cfoContent =
        cfoContent.substring(0, finalBrace) +
        '\n' +
        editClientStr +
        '\n' +
        addClientStr +
        '\n}\n';
  }

  cfoFile.writeAsStringSync(cfoContent);
  print('Fixed CFO dashboard completely');
}
