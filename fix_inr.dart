import 'dart:io';

void main() {
  final dir = Directory('lib/screens');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart') || f.path.endsWith('.txt'));
  
  for (final file in files) {
    try {
      final bytes = file.readAsBytesSync();
      // Search for \xef\xbf\xbd,1 (which is three bytes + comma + 1)
      // utf8 replacement character is 239, 191, 189
      // comma is 44, 1 is 49
      final searchPattern = [239, 191, 189, 44, 49];
      bool changed = false;
      List<int> newBytes = [];
      
      for (int i = 0; i < bytes.length; i++) {
        if (i <= bytes.length - 5 && 
            bytes[i] == 239 && 
            bytes[i+1] == 191 && 
            bytes[i+2] == 189 && 
            bytes[i+3] == 44 && 
            bytes[i+4] == 49) {
          // Replace with ₹ (e2 82 b9)
          newBytes.addAll([226, 130, 185]);
          i += 4; // Skip the rest of the pattern
          changed = true;
        } else {
          newBytes.add(bytes[i]);
        }
      }
      
      if (changed) {
        file.writeAsBytesSync(newBytes);
        print('Fixed INR in ${file.path}');
      }
    } catch (e) {
      print('Error processing ${file.path}: $e');
    }
  }
}
