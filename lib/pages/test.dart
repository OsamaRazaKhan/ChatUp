import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SimpleImageUploadScreen extends StatefulWidget {
  @override
  _SimpleImageUploadScreenState createState() =>
      _SimpleImageUploadScreenState();
}

class _SimpleImageUploadScreenState extends State<SimpleImageUploadScreen> {
  File? _image;
  final picker = ImagePicker();
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    //  requestPermissions();
  }

  // Future<void> requestPermissions() async {
  //   var status = await Permission.storage.status;
  //   if (!status.isGranted) {
  //     await Permission.storage.request();
  //   }
  // }

  Future pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File tempImage = File(pickedFile.path);
      if (await tempImage.exists()) {
        setState(() {
          _image = tempImage;
        });
      } else {
        print("Picked file does not exist.");
      }
    } else {
      print('No image selected.');
    }
  }

  Future uploadImage() async {
    if (_image == null) {
      print("No image selected for upload.");
      return;
    }

    String fileName =
        'uploads/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg';
    FirebaseStorage storage = FirebaseStorage.instance;

    try {
      TaskSnapshot snapshot = await storage.ref(fileName).putFile(_image!);
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        imageUrl = downloadUrl;
      });
      print("Image Uploaded: $downloadUrl");
    } catch (e) {
      print("Error uploading image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Image to Firebase"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image != null ? Image.file(_image!) : Text('No image selected.'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: pickImage,
              child: Text('Pick Image'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: uploadImage,
              child: Text('Upload Image'),
            ),
            SizedBox(height: 20),
            imageUrl != null
                ? Text('Uploaded Image URL: $imageUrl')
                : Container(),
          ],
        ),
      ),
    );
  }
}
