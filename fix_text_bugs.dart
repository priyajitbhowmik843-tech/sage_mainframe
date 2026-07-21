import 'dart:io';

void main() {
  void replaceInFile(String path, Map<String, String> replacements) {
    final file = File(path);
    if (!file.existsSync()) return;
    String content = file.readAsStringSync();

    replacements.forEach((target, replacement) {
      content = content.replaceAll(target, replacement);
    });

    file.writeAsStringSync(content);
  }

  replaceInFile('lib/screens/ceo_dashboard.dart', {
    '"₹\${state.clients.length}': '"\${state.clients.length}',
    '"₹\${state.employees.length': '"\${state.employees.length',
    '"₹\${n.timestamp': '"\${n.timestamp',
    '"₹\${c.paymentsDue} Months"': '"\${c.paymentsDue} Months"',
    '"₹\${c.weeklyReels} Reels': '"\${c.weeklyReels} Reels',
    '"₹\${c.discountPercent}%"': '"\${c.discountPercent}%"',
    '"₹\${c.campaigns}"': '"\${c.campaigns}"',
    '"₹\${day.toString().padLeft': '"\${day.toString().padLeft',
    '"₹\${paymentDate.day}': '"\${paymentDate.day}',
  });

  replaceInFile('lib/screens/cofounder_dashboard.dart', {
    '"₹\${state.clients.length}': '"\${state.clients.length}',
    '"₹\${state.employees.length': '"\${state.employees.length',
    '"₹\${n.timestamp': '"\${n.timestamp',
    '"₹\${c.paymentsDue} Months"': '"\${c.paymentsDue} Months"',
    '"₹\${c.weeklyReels} Reels': '"\${c.weeklyReels} Reels',
    '"₹\${c.discountPercent}%"': '"\${c.discountPercent}%"',
    '"₹\${c.campaigns}"': '"\${c.campaigns}"',
    '"₹\${paymentDate.day}': '"\${paymentDate.day}',
  });

  replaceInFile('lib/screens/marketing_executive_dashboard.dart', {
    '"₹\${pendingClients.length}': '"\${pendingClients.length}',
    '"₹\${pct.toStringAsFixed(0)}%"': '"\${pct.toStringAsFixed(0)}%"',
  });

  replaceInFile('lib/state/app_state.dart', {
    "'Payment received! \${c.name} paid ?\${c.monthlyPayable.toStringAsFixed(0)}'":
        "'Payment received! \${c.name} paid ₹\${c.monthlyPayable.toStringAsFixed(0)}'",
    "'Payment received! \${c.name} paid ?\${c.monthlyPayable.toStringAsFixed(0)} for Month \$month'":
        "'Payment received! \${c.name} paid ₹\${c.monthlyPayable.toStringAsFixed(0)} for Month \$month'",
  });
}
