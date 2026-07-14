import 'dart:io';

void main() {
  final files = ['lib/screens/ceo_dashboard.dart', 'lib/screens/cofounder_dashboard.dart'];

  for (final path in files) {
    final file = File(path);
    var content = file.readAsStringSync();

    // Revert everything back to standard
    content = content.replaceAll(r'''
                ) : SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
''', r'''
                ) : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
''');

    content = content.replaceAll(r'''
              ) : SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
''', r'''
              ) : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
''');

    content = content.replaceAll(r'''
              ) : SingleChildScrollView(
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
''', r'''
              ) : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
''');

    // Make sure we have the right closing brackets
    content = content.replaceAll(r'''
                      ]);
                    }).toList(),
                  ),
                ),
              ),
              actions: [
''', r'''
                      ]);
                    }).toList(),
                  ),
                ),
              ),
              ),
              actions: [
''');

    content = content.replaceAll(r'''
                      ]);
                    }).toList(),
                  ),
                  ),
                ),
              ),
              actions: [
''', r'''
                      ]);
                    }).toList(),
                  ),
                ),
              ),
              ),
              actions: [
''');

    file.writeAsStringSync(content);
    print("Fixed $path");
  }
}
