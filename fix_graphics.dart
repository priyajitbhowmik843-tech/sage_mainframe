import 'dart:io';

void main() {
  final f = File('lib/screens/graphics_editor_dashboard.dart');
  String c = f.readAsStringSync();
  
  // 1. Remove UNPAID PAYMENT TRACKER from _buildHomeTab
  final homeMatch = RegExp(r'TerminalPanel\(\s*title: .UNPAID PAYMENT TRACKER.,[\s\S]*?\),\s*const SizedBox\(height: 14\),').firstMatch(c);
  if (homeMatch != null) {
    c = c.replaceRange(homeMatch.start, homeMatch.end, '');
  }

  // 2. Update _buildFinanceTab calculations and tiles
  final financeStartMatch = RegExp(r'Widget _buildFinanceTab[\s\S]*?Widget _buildProfileTab').firstMatch(c);
  if (financeStartMatch != null) {
    String financeBlock = financeStartMatch.group(0)!;
    // Update logic variables
    financeBlock = financeBlock.replaceAll(
      'final double perDesignRate = emp.perDesignRate;',
      'final double deductionAmount = emp.pendingPayDeduction;'
    );
    financeBlock = financeBlock.replaceAll(
      'final double amountPaid = numPaid * perDesignRate;',
      'final double amountPaid = emp.paidMonths.length * emp.monthlySalary;'
    );
    financeBlock = financeBlock.replaceAll(
      'final double amountPending = numPending * perDesignRate;',
      'final double amountPending = emp.paymentCleared ? emp.pendingPayAmount : (emp.monthlySalary - deductionAmount);'
    );
    // Replace PER DESIGN RATE tile with DEDUCTIONS tile
    financeBlock = financeBlock.replaceAll(
      "Expanded(child: StatChip(label: 'PER DESIGN RATE', value: '\\u20B9\${perDesignRate.toStringAsFixed(0)}', valueColor: Colors.black87, icon: Icons.price_change)),",
      "Expanded(child: StatChip(label: 'DEDUCTIONS', value: '\\u20B9\${deductionAmount.toStringAsFixed(0)}', valueColor: SageColors.error, icon: Icons.money_off)),"
    );
    
    c = c.replaceRange(financeStartMatch.start, financeStartMatch.end, financeBlock);
  }

  // 3. Update _buildProfileTab
  final profileMatch = RegExp(r'Widget _buildProfileTab[\s\S]*?FINANCE DATA.,\s*child: Column\(\s*children: \[').firstMatch(c);
  if (profileMatch != null) {
    // we need to replace the profile rows inside FINANCE DATA
    final rowMatch = RegExp(r'_profileRow\("AMOUNT PAID"[\s\S]*?_profileRow\("UNPAID DESIGNS".*?\),').firstMatch(c);
    if (rowMatch != null) {
      String newRows = '''
              _profileRow("SALARY AMOUNT", "\\u20B9\${emp.monthlySalary.toStringAsFixed(0)} / mo"),
              _profileRow("PAID TILL MONTH", emp.paidMonths.isNotEmpty ? emp.paidMonths.last : 'None'),
              _profileRow("DEDUCTIONS", "\\u20B9\${emp.pendingPayDeduction.toStringAsFixed(0)}"),''';
      c = c.replaceRange(rowMatch.start, rowMatch.end, newRows);
    }
  }

  // Also remove unused variables in _buildProfileTab to avoid warnings
  c = c.replaceAll(
    'final numPaid = completedDesigns.where((t) => t.isPaymentAcknowledgedByGraphicsEditor).length;\n    final numUnpaid = completedDesigns.length - numPaid;\n    \n    final double amountPaid = numPaid * emp.perDesignRate;\n    final double amountUnpaid = numUnpaid * emp.perDesignRate;\n\n    final displayPayout = emp.paymentCleared ? emp.pendingPayAmount : amountUnpaid;\n    final displaySessions = emp.paymentCleared ? (emp.pendingPayMonth ?? "\$numUnpaid") : "\$numUnpaid";',
    ''
  );

  f.writeAsStringSync(c);
  print('Done graphics_editor_dashboard.dart');
}
