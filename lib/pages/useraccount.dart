import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/pages/home.dart';
import 'package:flutter_application_2/services/database.dart';
import 'package:flutter_application_2/services/shared_pref.dart';
import 'package:image_picker/image_picker.dart';

class UserDetailsScreen extends StatefulWidget {
  String firstName, lastName, userId, profilePicUrl;
  UserDetailsScreen(
      {required this.firstName,
      required this.lastName,
      required this.profilePicUrl,
      required this.userId});

  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  File? _image;
  final picker = ImagePicker();

  bool _isLightboxOpen = false;

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
      DatabaseMethods().updateProfilePic(widget.userId, downloadUrl);
      await SharedPreferenceHelper().saveUserPic(downloadUrl);
      setState(() {
        widget.profilePicUrl = downloadUrl;
      });
      print("Image Uploaded: $downloadUrl");
    } catch (e) {
      print("Error uploading image: $e");
    }
  }

  void _toggleLightbox() {
    _image = null;
    setState(() {
      _isLightboxOpen = !_isLightboxOpen;
    });
  }

  updateUserName() async {
    String newName = widget.firstName + " " + widget.lastName;
    await DatabaseMethods().updateUserName(widget.userId, newName);
    await SharedPreferenceHelper().saveUserDisplayName(newName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _isLightboxOpen
          ? Container(
              color: Colors.black.withOpacity(1),
              alignment: Alignment.center,
              child: Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Container(
                        height: MediaQuery.of(context).size.height / 2.5,
                        width: MediaQuery.of(context).size.width / 1.2,
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: _image != null
                            ? Image.file(_image!)
                            : Image.network(
                                widget.profilePicUrl,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),
                  _image != null
                      ? Container(
                          margin: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height / 1.3,
                              left: MediaQuery.of(context).size.width / 2.5),
                          child: ElevatedButton(
                              onPressed: uploadImage,
                              child: Text(
                                'Save',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              )),
                        )
                      : Container(
                          child: null,
                        ),
                  Positioned(
                    top: 60,
                    left: 10,
                    child: SafeArea(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: _toggleLightbox,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 10,
                          ),
                          Text(
                            'Profile Picture',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize:
                                    MediaQuery.of(context).size.width / 15),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 10,
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.white),
                            onPressed: pickImage,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        Home())); // Navigate back to the previous screen (HomeScreen)
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.height / 15, left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Profile picture
                widget.profilePicUrl.isEmpty
                    ? CircularProgressIndicator() // Placeholder if profile picture URL is empty
                    : GestureDetector(
                        onTap: _toggleLightbox,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: Image.network(
                            widget.profilePicUrl,
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
              ],
            ),
            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.firstName,
                  style: TextStyle(fontSize: 16),
                ),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Edit First Name"),
                          content: TextFormField(
                            initialValue: widget.firstName,
                            onChanged: (value) {
                              setState(() {
                                widget.firstName = value;
                              });
                            },
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                updateUserName();
                                Navigator.of(context).pop();
                              },
                              child: Text('Save'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Icon(
                    Icons.save,
                    color: Color(0xffc199cd),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.lastName,
                  style: TextStyle(fontSize: 16),
                ),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Edit First Name"),
                          content: TextFormField(
                            initialValue: widget.lastName,
                            onChanged: (value) {
                              setState(() {
                                widget.lastName = value;
                              });
                            },
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                updateUserName();
                                Navigator.of(context).pop();
                              },
                              child: Text('Save'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Icon(
                    Icons.save,
                    color: Color(0xffc199cd),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
