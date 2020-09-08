import 'dart:convert';
import 'dart:io';

import 'dart:typed_data';

class ImageToString {
  static String base64convert(File file) {
    print(base64Encode(file.readAsBytesSync()));
    return base64Encode(file.readAsBytesSync());
  }

  static Uint8List imageFromBase64(String string) {
    return base64Decode(string);
  }
}