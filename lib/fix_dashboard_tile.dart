import 'dart:io';

void main() {
  final f = File('widgets/common_widgets.dart');
  final lines = f.readAsLinesSync();
  
  final startIdx = lines.indexWhere((l) => l.contains('class DashboardTile extends StatelessWidget {'));
  final endIdx = lines.indexWhere((l) => l.contains('class StatChip extends StatelessWidget {'));
  
  // Actually, we want to replace from startIdx up to the line before // ─── STAT CHIP ─
  final statChipCommentIdx = lines.indexWhere((l) => l.contains('STAT CHIP'));
  
  final newClass = """
class DashboardTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color iconBackgroundColor;
  final IconData icon;
  final VoidCallback? onTap;

  const DashboardTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.iconBackgroundColor,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black, width: 1.5),
          boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(3, 3), blurRadius: 0)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBackgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.black87, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Check",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(Icons.arrow_forward, color: Colors.black87, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
""";

  final before = lines.sublist(0, startIdx).join('\n');
  final after = lines.sublist(statChipCommentIdx).join('\n');
  
  f.writeAsStringSync(before + '\n' + newClass + '\n' + after);
}
