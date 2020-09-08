import 'dart:core';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'image_to_string_converter.dart';

class SelectImage {
  static Future<List<String>> getImageFromCamera() async {
    final pickedFile = await ImagePicker().getImage(source: ImageSource.camera);
    List<String> imageList = new List<String>();
    if (pickedFile == null) return imageList;
    File file = new File(pickedFile.path);
    imageList.add(ImageToString.base64convert(file));
    return imageList;
  }

  static Future<List<File>> getImageFromGallery() async {
    List<File> files = await FilePicker.getMultiFile(type: FileType.image);
    return files;
  }

  static Future<File> saveImage(String pe) async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    File file = File(pickedFile.path);
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path;
//    imageCache.clear();
    //File("$path/$pe.png").delete();
    final Future<File> newImage = file.copy("$path/$pe.png");
    newImage.then((value) {
      print(value.path);
      return value;
    });
    return newImage;
  }
}
