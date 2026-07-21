import 'dart:io';

void main() {
  String p = 'lib/screens/videographer_dashboard.dart';
  String t = File(p).readAsStringSync();

  String broken = '''
                  _navIcon(0, Icons.calendar_month_outlined, Icons.calendar_month),
      onTap: () => setState(() => _tab = idx),
      child: Container(''';

  String fixed = '''
                  _navIcon(0, Icons.calendar_month_outlined, Icons.calendar_month),
                  _navIcon(1, Icons.bar_chart_outlined, Icons.bar_chart),
                  _navIcon(2, Icons.person_outline, Icons.person),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    ),
    );
  }

  Widget _navIcon(int idx, IconData outline, IconData filled) {
    final active = _tab == idx;
    return GestureDetector(
      onTap: () => setState(() => _tab = idx),
      child: Container(''';

  // Make it whitespace insensitive if possible, or just replace exact substrings
  // Let's replace line by line or using Regex if needed.
  // Actually, we can just replace everything between `_navIcon(0` and `child: Container(`

  t = t.replaceAll(broken, fixed);
  File(p).writeAsStringSync(t);
  print('Repaired videographer!');
}
