import 'dart:io';

void main() {
  void fixFileBytes(String path) {
    final file = File(path);
    if (!file.existsSync()) return;

    var bytes = file.readAsBytesSync().toList();
    bool changed = false;

    // We want to find `",1\${` which is:
    // " (34)
    //  (239, 191, 189)  [EF BF BD]
    // , (44)
    // 1 (49)
    // \$ (36)
    // { (123)
    final search1 = [34, 239, 191, 189, 44, 49, 36, 123];
    // Replace with `₹\${` which is:
    // ₹ (226, 130, 185) [E2 82 B9]
    // \$ (36)
    // { (123)
    final replace1 = [226, 130, 185, 36, 123];

    // We also want to find `,1\${` (without the quote) just in case
    final search2 = [239, 191, 189, 44, 49, 36, 123];
    final replace2 = [226, 130, 185, 36, 123];

    // Also `"₹\${` which is `34, 226, 130, 185, 36, 123`
    // And replace it with `₹\${` (removing the extra quote)
    final search3 = [34, 226, 130, 185, 36, 123];
    final replace3 = [226, 130, 185, 36, 123];

    // Helper to replace bytes
    List<int> replaceBytes(
      List<int> source,
      List<int> search,
      List<int> replace,
    ) {
      List<int> result = [];
      int i = 0;
      while (i < source.length) {
        if (i + search.length <= source.length) {
          bool match = true;
          for (int j = 0; j < search.length; j++) {
            if (source[i + j] != search[j]) {
              match = false;
              break;
            }
          }
          if (match) {
            result.addAll(replace);
            i += search.length;
            changed = true;
            continue;
          }
        }
        result.add(source[i]);
        i++;
      }
      return result;
    }

    bytes = replaceBytes(bytes, search1, replace1);
    bytes = replaceBytes(bytes, search2, replace2);
    // Be careful with search3: it removes quote before ₹\${.
    // Is there any valid `"₹\${`?
    // Yes: `Text("₹\${amount}")` ! Wait, for `Text("₹\${amount}")`, removing the quote breaks it!
    // So ONLY remove `"₹\${` if it's NOT preceded by `Text(`!
    // Wait, let's just do search1 and search2 first, and see what breaks!

    if (changed) {
      file.writeAsBytesSync(bytes);
      print('Fixed byte corruption in \$path');
    }
  }

  fixFileBytes('lib/screens/ceo_dashboard.dart');
  fixFileBytes('lib/screens/cofounder_dashboard.dart');
  fixFileBytes('lib/screens/marketing_executive_dashboard.dart');
  fixFileBytes('lib/state/app_state.dart');
}
