import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_generator_sample_app/pdf_viewer.dart';
import 'package:pdf_generator_sample_app/select_image.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<File> files = new List<File>();
  final pdf = pw.Document();
  String docPath;
  Directory _downloadsDirectory;

  @override
  void initState() {
    super.initState();
    initDownloadsDirectoryState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initDownloadsDirectoryState() async {
    Directory downloadsDirectory;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      downloadsDirectory = await DownloadsPathProvider.downloadsDirectory;
    } on PlatformException {
      print('Could not get the downloads directory');
    }
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    setState(() {
      _downloadsDirectory = downloadsDirectory;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return Image.file(
            files[index],
            height: 150,
            width: 150,
          );
        },
        itemCount: files.length,
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "btn1",
            backgroundColor: Colors.blueAccent,
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () {
              Future<List<File>> filesa = SelectImage.getImageFromGallery();
              filesa.then((value) {
                files = value;
                setState(() {});
              });
            },
          ),
          SizedBox(
            width: 10,
          ),
          FloatingActionButton(
            heroTag: "btn2",
            backgroundColor: Colors.blueAccent,
            child: Icon(
              Icons.arrow_drop_down_circle,
              color: Colors.white,
            ),
            onPressed: () {
              generatePdf();
              savePdf();
            },
          )
        ],
      ),
    );
  }

  generatePdf() {
    for (File file in files) {
      pdf.addPage(pw.Page(
          margin: pw.EdgeInsets.all(12),
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(
                child: pw.Image(generateImage(file), fit: pw.BoxFit.contain));
          }));
    }
  }

  generateImage(File imageFile) {
    var image = PdfImage.file(pdf.document, bytes: imageFile.readAsBytesSync());
    return image;
  }

  savePdf() async {
//    Directory directory = await getApplicationDocumentsDirectory();
//    String path=directory.path;
//    print(path);

//    File pdff=File("$path/example.pdf");
//    docPath = "$path/example.pdf";
//    pdff.writeAsBytesSync(pdf.save());
    File downloadFile = new File("${_downloadsDirectory.path}/example.pdf");
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    downloadFile.writeAsBytesSync(pdf.save());
    docPath = "${_downloadsDirectory.path}/example.pdf";
    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => PdfView(
                  path: docPath,
                )));
  }
}
