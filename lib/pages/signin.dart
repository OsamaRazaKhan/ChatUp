import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_2/pages/forgotpassword.dart';
import 'package:flutter_application_2/pages/home.dart';
import 'package:flutter_application_2/pages/signup.dart';
import 'package:flutter_application_2/services/database.dart';
import 'package:flutter_application_2/services/shared_pref.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  String email = "", password = "", name = "", pic = "", username = "", id = "";
  TextEditingController usermailcontroller = new TextEditingController();
  TextEditingController userpasswordcontroller = new TextEditingController();

  final _formkey = GlobalKey<FormState>();
  userLogin() async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      QuerySnapshot querySnapshot =
          await DatabaseMethods().getUserbyemail(email);

      name = "${querySnapshot.docs[0]["Name"]}";
      username = "${querySnapshot.docs[0]["username"]}";
      pic = "${querySnapshot.docs[0]["Photo"]}";
      id = "${querySnapshot.docs[0].id}";

      await SharedPreferenceHelper().saveUserDisplayName(name);
      await SharedPreferenceHelper().saveUserName(username);
      await SharedPreferenceHelper().saveUserId(id);
      await SharedPreferenceHelper().saveUserPic(pic);
      await SharedPreferenceHelper().saveUserEmail(email);

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return Home();
      }));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "No User Found for that Email",
              style: TextStyle(fontSize: 18.0, color: Colors.black),
            )));
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "Wrong Password Provided by User",
              style: TextStyle(fontSize: 18.0, color: Colors.black),
            )));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 4.0,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Color(0xFF7f30fe), Color(0xFF6380fb)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  borderRadius: BorderRadius.vertical(
                      bottom: Radius.elliptical(
                          MediaQuery.of(context).size.width, 105.0))),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Center(
                        child: Text(
                      "Sign In",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold),
                    )),
                    Center(
                        child: Text(
                      "Login to your account",
                      style: TextStyle(
                          color: Color(0xFFbbb0ff),
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500),
                    )),
                    Container(
                      margin: EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 20.0),
                      child: Material(
                        elevation: 5.0,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 30.0, horizontal: 20.0),
                          height: MediaQuery.of(context).size.height / 2,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: Form(
                            key: _formkey,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Email",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(left: 40.0),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1.0, color: Colors.black38)),
                                    child: TextFormField(
                                      controller: usermailcontroller,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Please enter E-mail";
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          prefixIcon: Icon(
                                            Icons.mail_outline,
                                            color: Color(0xFF7f30fe),
                                          )),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20.0,
                                  ),
                                  Text(
                                    "Password",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(left: 40.0),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1.0, color: Colors.black38)),
                                    child: TextFormField(
                                      controller: userpasswordcontroller,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Please enter Password";
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          prefixIcon: Icon(
                                            Icons.password,
                                            color: Color(0xFF7f30fe),
                                          )),
                                      obscureText: true,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushReplacement(context,
                                          MaterialPageRoute(builder: (context) {
                                        return ForgotPassword();
                                      }));
                                    },
                                    child: Container(
                                      alignment: Alignment.bottomRight,
                                      child: Text(
                                        "Forgot Password",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 40.0,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      if (_formkey.currentState!.validate()) {
                                        setState(() {
                                          email = usermailcontroller.text;
                                          password =
                                              userpasswordcontroller.text;
                                        });
                                      }
                                      userLogin();
                                    },
                                    child: Center(
                                      child: Container(
                                        width: 130,
                                        child: Material(
                                          elevation: 5.0,
                                          child: Center(
                                            child: Container(
                                              padding: EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                  color: Color(0xFF6380fb),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Center(
                                                child: Text(
                                                  "SignIn",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18.0,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Dont have an account?",
                          style: TextStyle(color: Colors.black, fontSize: 16.0),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Signup()));
                          },
                          child: Text(
                            " Sign Up now",
                            style: TextStyle(
                                color: Color(0xFF7f30fe),
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
