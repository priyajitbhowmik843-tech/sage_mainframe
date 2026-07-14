import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  var file10 = File('../avtar/10.png');
  var file11 = File('../avtar/11.png');
  
  int count = 1;

  void sliceImage(File file) {
    if (file.existsSync()) {
      var image = img.decodeImage(file.readAsBytesSync());
      if (image != null) {
        int w = image.width ~/ 2;
        int h = image.height ~/ 2;
        
        for (int y = 0; y < 2; y++) {
          for (int x = 0; x < 2; x++) {
            var crop = img.copyCrop(image, x: x * w, y: y * h, width: w, height: h);
            File('assets/avatars/avatar' + count.toString() + '.png').writeAsBytesSync(img.encodePng(crop));
            print('Saved avatar' + count.toString() + '.png');
            count++;
          }
        }
      }
    }
  }
  
  Directory('assets/avatars').createSync(recursive: true);
  
  sliceImage(file10);
  sliceImage(file11);
}
