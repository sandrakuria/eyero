import 'dart:io';

import 'package:eyero/Result.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class MyImagePicker extends StatefulWidget {
  static final style = TextStyle(
    fontSize: 20,
    fontFamily: "Billy",
    fontWeight: FontWeight.w400,
  );

  @override
  _MyImagePickerState createState() => _MyImagePickerState();
}

class _MyImagePickerState extends State<MyImagePicker> {
  File imageURI;
  String result;
  String path;
  var confidence;
  var label;

  Future getImageFromCamera() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      imageURI = image;
      path = image.path;
    });
  }

  Future getImageFromGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageURI = image;
      path = image.path;
    });
  }

  Future classifyImage() async {
    await Tflite.loadModel(
        model: "assets/model_unquant.tflite", labels: "assets/labels.txt");
    var output = await Tflite.runModelOnImage(path: path);
    var data = getResult(output);
    setState(() {
      // result = data.toString();
      // print(result);
      confidence = data[0].confidence.toString();
      label = data[0].label.toString();
    });
  }

  List<Result> getResult(List<dynamic> output) {
    List<Result> data = List();
    output.forEach((element) {
      Result item = Result(
          confidence: element['confidence'],
          label: element['label'],
          index: element['index']);
      data.add(item);
    });
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Eyero"),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Scaffold(
            body: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
              imageURI == null
                  ? Text('No image selected.')
                  : Image.file(imageURI,
                      width: 300, height: 200, fit: BoxFit.cover),
              Container(
                  margin: EdgeInsets.fromLTRB(0, 30, 0, 20),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),
                    onPressed: () => getImageFromCamera(),
                    child: Text('Select Image From Camera'),
                    textColor: Colors.white,
                    color: Color(0xFF55006c),
                    padding: EdgeInsets.fromLTRB(12, 12, 12, 12),
                  )),
              Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),
                    onPressed: () => getImageFromGallery(),
                    child: Text('Pick From Gallery'),
                    textColor: Colors.white,
                    color: Color(0xFF55006c),
                    padding: EdgeInsets.fromLTRB(12, 12, 12, 12),
                  )),
              Container(
                  margin: EdgeInsets.fromLTRB(0, 30, 0, 20),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),
                    onPressed: () => classifyImage(),
                    child: Text('Run Detection'),
                    textColor: Colors.white,
                    color: Color(0xFF55006c),
                    padding: EdgeInsets.fromLTRB(12, 12, 12, 12),
                  )),
              confidence == null ? Text('Confidence') : Text(confidence),
              label == null ? Text('Label') : Text(label),
            ]))),
      ),
    );
  }
}
