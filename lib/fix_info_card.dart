import 'dart:io';

void main() {
  final file = File('lib/screens/videographer_dashboard.dart');
  String content = file.readAsStringSync();
  
  final replacement = '''        Row(
          children: [
            Expanded(
              child: StatChip(
                label: 'SESSIONS THIS MONTH',
                value: '\$completedThisMonth',
                valueColor: SageColors.primary,
                icon: Icons.check_circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatChip(
                label: 'PAYMENT PENDING',
                value: '\\u20B9\${emp.pendingPayAmount.toStringAsFixed(0)}',
                valueColor: SageColors.error,
                icon: Icons.pending,
              ),
            ),
          ],
        ),''';
        
  // Replace the old Row containing InfoCards
  final regex = RegExp(r'        Row\([\s\S]*?const SizedBox\(height: 24\),');
  content = content.replaceFirst(regex, replacement + '\n        const SizedBox(height: 24),');
  
  file.writeAsStringSync(content);
  print('Fixed InfoCard to StatChip');
}
