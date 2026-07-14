import 'dart:io';
void main() {
  var file = File('update_ceo_personnel.dart');
  var content = file.readAsStringSync();
  int editEnd = content.indexOf("''';");
  if (editEnd != -1) {
    content = content.substring(0, editEnd + 4);
    content += '''
    String editBefore = content.substring(0, editStart);
    String editAfter = content.substring(editEnd);
    content = editBefore + newEditDialog + "\\n\\n  " + editAfter;
    }
    
    file.writeAsStringSync(content);
    print('ceo_dashboard.dart updated.');
}
''';
    file.writeAsStringSync(content);
    print('Fixed update_ceo_personnel.dart');
  }
}
