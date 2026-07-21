import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  // Compress invoice_logo.png
  final logoFile = File('assets/logo/invoice_logo.png');
  if (logoFile.existsSync()) {
    final logoImage = img.decodeImage(logoFile.readAsBytesSync());
    if (logoImage != null) {
      final resizedLogo = img.copyResize(
        logoImage,
        width: 400,
      ); // Resize to 400px width
      logoFile.writeAsBytesSync(img.encodePng(resizedLogo, level: 9));
      print('invoice_logo.png resized and compressed.');
    }
  }

  // Compress ceo e sign.png
  final signFile = File('assets/logo/ceo e sign.png');
  if (signFile.existsSync()) {
    final signImage = img.decodeImage(signFile.readAsBytesSync());
    if (signImage != null) {
      final resizedSign = img.copyResize(
        signImage,
        width: 400,
      ); // Resize to 400px width
      signFile.writeAsBytesSync(img.encodePng(resizedSign, level: 9));
      print('ceo e sign.png resized and compressed.');
    }
  }
}
