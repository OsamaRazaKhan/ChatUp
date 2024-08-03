import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_2/pages/chatpage.dart';
import 'package:flutter_application_2/pages/signin.dart';
import 'package:flutter_application_2/pages/useraccount.dart';
import 'package:flutter_application_2/services/database.dart';
import 'package:flutter_application_2/services/shared_pref.dart';

String img = '';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool search = false;
  String? myName, myProfilePic, myUserName, myEmail, myId;
  Stream? chatRoomStream;

  bool _isLightboxOpen = false;

  void _toggleLightbox() {
    setState(() {
      _isLightboxOpen = !_isLightboxOpen;
    });
  }

  getthesharedpref() async {
    myName = await SharedPreferenceHelper().getDisplayName();
    myProfilePic = await SharedPreferenceHelper().getUserPic();
    myUserName = await SharedPreferenceHelper().getUserName();
    myEmail = await SharedPreferenceHelper().getUserEmail();
    myId = await SharedPreferenceHelper().getUserId();
    setState(() {});
  }

  ontheload() async {
    await getthesharedpref();
    chatRoomStream = await DatabaseMethods().getChatRooms();
    setState(() {});
  }

  Widget ChatRoomList() {
    return StreamBuilder(
      stream: chatRoomStream,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return ChatRoomListTile(
                    ds.id,
                    ds["lastMessage"],
                    myUserName!,
                    ds["lastMessageSendTs"],
                    toggleLightboxCallback: _toggleLightbox,
                  );
                })
            : Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    ontheload();
  }

  getChatRoomIdbyUsername(String a, String b) {
    String firstUsername = a.compareTo(b) < 0 ? a : b;
    String secondUsername = a.compareTo(b) < 0 ? b : a;
    return "$firstUsername\_$secondUsername";
    /*if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }*/
  }

  var queryResultSet = [];
  var tempSearchStorm = [];

  initiateSearch(value) {
    if (value.length == 0) {
      setState(() {
        queryResultSet = [];
        tempSearchStorm = [];
      });
    }
    setState(() {
      search = true;
    });

    var capitalizedValue =
        value.substring(0, 1).toUpperCase() + value.substring(1);

    if (queryResultSet.length == 0 && value.length == 1) {
      DatabaseMethods().Search(value).then((QuerySnapshot docs) {
        for (int i = 0; i < docs.docs.length; ++i) {
          queryResultSet.add(docs.docs[i].data());
        }
      });
    } else {
      tempSearchStorm = [];
      queryResultSet.forEach((element) {
        String st = myUserName!;
        if (element['username'].startsWith(capitalizedValue) &&
            element['username'] != myUserName) {
          setState(() {
            tempSearchStorm.add(element);
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _isLightboxOpen
          ? GestureDetector(
              onTap: _toggleLightbox,
              child: Container(
                color: Colors.black.withOpacity(0.4),
                alignment: Alignment.center,
                child: Container(
                  width: MediaQuery.of(context).size.width / 1,
                  height: MediaQuery.of(context).size.height / 2,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Image.network(
                    img,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            search
                ? Expanded(
                    child: TextField(
                      onChanged: (value) {
                        initiateSearch(value.toUpperCase());
                      },
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search User',
                          hintStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w500)),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500),
                    ),
                  )
                : Text(
                    "ChatUp",
                    style: TextStyle(
                        color: Color(0xffc199cd),
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold),
                  ),
            GestureDetector(
              onTap: () {
                search = true;
                setState(() {});
              },
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Color(0xFF3a2144),
                    borderRadius: BorderRadius.circular(20)),
                child: search
                    ? GestureDetector(
                        onTap: () {
                          search = false;
                          setState(() {});
                        },
                        child: Icon(
                          Icons.close,
                          color: Color(0xffc199cd),
                        ),
                      )
                    : Icon(
                        Icons.search,
                        color: Color(0xffc199cd),
                      ),
              ),
            ),
          ],
        ),
        backgroundColor: Color(0xFF553370),
      ),
      // backgroundColor: Color(0xFF553370),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
                width: MediaQuery.of(context).size.width,
                height: search
                    ? MediaQuery.of(context).size.height / 1.2
                    : MediaQuery.of(context).size.height / 1.167,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20))),
                child: Column(
                  children: [
                    search
                        ? ListView(
                            padding: EdgeInsets.only(left: 10.0, right: 10.0),
                            primary: false,
                            shrinkWrap: true,
                            children: tempSearchStorm.map((element) {
                              return buildResultCard(element);
                            }).toList())
                        : ChatRoomList(),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      //////////////////////////////////////////////////////////////////////////
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: Image.network(
                            myProfilePic!,
                            height: 70,
                            width: 70,
                            fit: BoxFit.cover,
                          )),
                      SizedBox(width: 10),
                      Container(
                        child: Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                  '$myName',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                  '$myUserName'),
                              Text(
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                  '$myEmail'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 134, 82, 177),
              ),
            ),
            ListTile(
                leading: Icon(Icons.home),
                title: Text('Home'),
                onTap: () {
                  Navigator.pop(context);
                }),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Account Setting'),
              onTap: () {
                List<String> name_lst = myName!.split(' ');
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return UserDetailsScreen(
                    userId: myId!,
                    firstName: name_lst[0],
                    lastName: name_lst[1],
                    profilePicUrl: myProfilePic!,
                  );
                }));
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                  return SignIn();
                }));
              },
            ),
          ],
        ),
      ),
      /////////////////////////////////////////////////////////////////////////
    );
  }

  Widget buildResultCard(data) {
    return GestureDetector(
      onTap: () async {
        search = false;
        setState(() {});
        var chatRoomId = getChatRoomIdbyUsername(myUserName!, data["username"]);
        Map<String, dynamic> chatRoomInfoMap = {
          "users": [myUserName, data["username"]]
        };
        await DatabaseMethods().createChatRoom(chatRoomId, chatRoomInfoMap);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatPage(
                    name: data["Name"],
                    profileurl: data["Photo"],
                    username: data["username"])));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Material(
          elevation: 5.0,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: Image.network(
                    data["Photo"],
                    height: 70,
                    width: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(
                  width: 20.0,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data["Name"],
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text(
                      data["username"],
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChatRoomListTile extends StatefulWidget {
  final String lastMessage, chatRoomId, myUsername, time;
  final Function toggleLightboxCallback; // Callback to toggle lightbox
  ChatRoomListTile(
      this.chatRoomId, this.lastMessage, this.myUsername, this.time,
      {required this.toggleLightboxCallback});

  @override
  State<ChatRoomListTile> createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String profilePicUrl = "", name = "", username = "", id = "";

  getthisUserInfo() async {
    List<String> chatroomArray = widget.chatRoomId.split('_');
    chatroomArray[0] == widget.myUsername
        ? username = chatroomArray[1]
        : username = chatroomArray[0];

    //  username = widget.chatRoomId.replaceAll("_", "").replaceAll(widget.myUsername, "");
    QuerySnapshot querySnapshot =
        await DatabaseMethods().getUserInfo(username.toUpperCase());
    name = "${querySnapshot.docs[0]["Name"]}";
    profilePicUrl = "${querySnapshot.docs[0]["Photo"]}";
    id = "${querySnapshot.docs[0]["Id"]}";
    setState(() {});
  }

  @override
  void initState() {
    getthisUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        setState(() {});
        Map<String, dynamic> chatRoomInfoMap = {
          "users": [widget.myUsername, name]
        };
        await DatabaseMethods()
            .createChatRoom(widget.chatRoomId, chatRoomInfoMap);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatPage(
                    name: name,
                    profileurl: profilePicUrl,
                    username: username)));
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            profilePicUrl == ""
                ? CircularProgressIndicator()
                : GestureDetector(
                    onTap: () {
                      img = profilePicUrl;
                      widget
                          .toggleLightboxCallback(); // Call the callback function
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Image.network(profilePicUrl,
                          height: 70, width: 70, fit: BoxFit.cover),
                    ),
                  ),
            SizedBox(
              width: 20.0,
            ),
            Container(
              width: MediaQuery.of(context).size.width / 3,
              child: Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      username,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 2,
                      child: Text(
                        widget.lastMessage,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.black45,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),
            Text(
              widget.time,
              style: TextStyle(
                  color: Colors.black45,
                  fontSize: 13.0,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
