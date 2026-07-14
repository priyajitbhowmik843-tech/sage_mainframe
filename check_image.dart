import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  var file10 = File('../avtar/10.png');
  var file11 = File('../avtar/11.png');
  
  if (file10.existsSync()) {
    var image10 = img.decodeImage(file10.readAsBytesSync());
    if (image10 != null) {
      print('10.png dimensions: ${image10.width} x ${image10.height}');
    }
  } else {
    print('10.png not found');
  }

  if (file11.existsSync()) {
    var image11 = img.decodeImage(file11.readAsBytesSync());
    if (image11 != null) {
      print('11.png dimensions: ${image11.width} x ${image11.height}');
    }
  } else {
    print('11.png not found');
  }
}
