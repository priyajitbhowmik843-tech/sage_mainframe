import 'dart:io';

void main() {
  final files = [
    'lib/screens/ceo_dashboard.dart',
    'lib/screens/cofounder_dashboard.dart',
    'lib/widgets/common_widgets.dart',
  ];

  for (final file in files) {
    var content = File(file).readAsStringSync();

    // Revert soft shadow 4 to hard shadow 3
    content = content.replaceAll(
      '''            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                offset: const Offset(0, 4),
                blurRadius: 12,
              ),
            ],''',
      '''            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                offset: Offset(3, 3),
                blurRadius: 0,
              ),
            ],''',
    );

    // Revert soft shadow 4 to hard shadow 2
    content = content.replaceAll(
      '''                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                    ),
                  ],''',
      '''                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ],''',
    );

    // Revert border removal
    content = content.replaceAll(
      '/* border removed for pastel style */',
      'border: Border.all(color: Colors.black, width: 1.5),',
    );

    // Specifically add to DashboardTile
    content = content.replaceAll(
      '''        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
        ),''',
      '''        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black, width: 1.5),
          boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(3, 3), blurRadius: 0)],
        ),''',
    );

    // Also DashboardTile's icon background might need a border? Let's leave icon alone.

    // Also check TerminalPanel and StatChip if they missed borders because I removed the line entirely.
    // In previous script, I did:
    // content = content.replaceAll('border: Border.all(color: Colors.black, width: 1.5),', '/* border removed for pastel style */');
    // So restoring that comment handles the revert!

    File(file).writeAsStringSync(content);
    print('Reverted in \$file');
  }
}
