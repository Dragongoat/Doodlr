import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doodlr/main.dart';
import 'package:doodlr/services/authentication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ProfileWidget extends StatefulWidget {
  ProfileWidget({this.auth});

  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() {
    return ProfileWidgetState();
  }
}

class ProfileWidgetState extends State<ProfileWidget> {
  FirebaseUser _user;
  final _firestore = Firestore.instance;
  String _profilePicLink;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  void getUser() async {
    var user = await widget.auth.getCurrentUser();
    setState(() {
      _user = user;
    });
    getProfilePic();
  }

  void getProfilePic() async {
    DocumentSnapshot docRef = await _firestore
        .collection("users")
        .document(_user.uid)
        .get();

    if (docRef.data.containsKey("profilePic")) {
      setState(() {
        _profilePicLink = docRef.data["profilePic"];
      });
    }
  }

  void editProfilePic(source) async {
    var image = await ImagePicker.pickImage(source: source);
    StorageReference ref = FirebaseStorage.instance.ref().child("profilePics").child("${_user.uid}.png");
    StorageUploadTask uploadTask = ref.putFile(image);
    var link = await (await uploadTask.onComplete).ref.getDownloadURL();
    await _firestore
        .collection("users")
        .document(_user.uid)
        .updateData({
      "profilePic": link
    });
    setState(() {
      _profilePicLink = link;
    });
  }

  Widget _showPage() {
    if (_user == null || _firestore == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/colored_pencils_pixel.png"),
            fit: BoxFit.cover,
          ),
        ),
        constraints: BoxConstraints.expand(),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 100.0, 20.0, 100.0),
            child: Card(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        _showAvatar(),
                        _showUsername(),
                      ],
                    ),
                  ),
                  Divider(),
                  Expanded(
                      child: _showStats()
                  ),
                ],
              ),
            ),
          )
        )
    );
  }

  Widget _showStats() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  StreamBuilder(
                    stream: _firestore
                        .collection("users")
                        .document(_user.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Text("--");
                      return Text(
                        snapshot.data["gamesPlayed"].toString(),
                        style: TextStyle(
                          fontSize: 25.0,
                          shadows: <Shadow>[
                            Shadow(
                              offset: Offset(1.0, 1.0),
                              blurRadius: 2.0,
                              color: Colors.grey,
                            )
                          ],
                        ),
                      );
                    }
                  ),
                  Text(
                    "games played",
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  StreamBuilder(
                      stream: _firestore
                          .collection("users")
                          .document(_user.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const Text("--");
                        return Text(
                          snapshot.data["goldMedals"].toString(),
                          style: TextStyle(
                            fontSize: 25.0,
                            color: Colors.amber,
                            shadows: <Shadow>[
                              Shadow(
                                offset: Offset(1.0, 1.0),
                                blurRadius: 2.0,
                                color: Colors.amber[900],
                              )
                            ],
                          ),
                        );
                      }
                  ),
                  Text(
                    "gold medals",
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(
          height: 45.0,
        ),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  StreamBuilder(
                      stream: _firestore
                          .collection("users")
                          .document(_user.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const Text("--");
                        return Text(
                          snapshot.data["silverMedals"].toString(),
                          style: TextStyle(
                            fontSize: 25.0,
                            color: Colors.grey,
                            shadows: <Shadow>[
                              Shadow(
                                offset: Offset(1.0, 1.0),
                                blurRadius: 2.0,
                                color: Colors.grey[900],
                              )
                            ],
                          ),
                        );
                      }
                  ),
                  Text(
                    "silver medals",
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  StreamBuilder(
                      stream: _firestore
                          .collection("users")
                          .document(_user.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const Text("--");
                        return Text(
                          snapshot.data["bronzeMedals"].toString(),
                          style: TextStyle(
                            fontSize: 25.0,
                            color: Colors.deepOrange,
                            shadows: <Shadow>[
                              Shadow(
                                offset: Offset(1.0, 1.0),
                                blurRadius: 2.0,
                                color: Colors.deepOrange[900],
                              )
                            ],
                          ),
                        );
                      }
                  ),
                  Text(
                    "bronze medals",
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _showUsername() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            _user.displayName,
            textAlign: TextAlign.left,
            style: TextStyle(
              shadows: <Shadow>[
                Shadow(
                  offset: Offset(1.0, 1.0),
                  blurRadius: 2.0,
                  color: Colors.grey,
                )
              ],
              fontSize: 20.0,
            ),
          ),
          SizedBox(
            height: 5.0,
          ),
          StreamBuilder(
              stream: _firestore
                  .collection("users")
                  .document(_user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Text("--");
                return Text(
                  "Joined: " + DateFormat
                      .yMd()
                      .add_jm()
                      .format(snapshot
                              .data["joinDate"]
                              .toDate()
                              .toLocal())
                      .toString(),
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 10.0,
                  ),
                );
              }
          ),
          SizedBox(height: 10.0,),
        ],
      ),
    );
  }

  Widget _showAvatar() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            CircleAvatar(
              maxRadius: 80.0,
              minRadius: 40.0,
              backgroundImage: (_profilePicLink == null) ? AssetImage("assets/profile_pic.jpg") : NetworkImage(_profilePicLink),
              backgroundColor: Colors.transparent,
            ),
            SizedBox(height: 5.0,),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ClipOval(
                    child: Material(
                      color: Colors.white,
                      child: Center(
                        child: Ink(
                          decoration: const ShapeDecoration(
                            color: Colors.lightBlue,
                            shape: CircleBorder(),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.photo_camera),
                            color: Colors.white,
                            onPressed: () => editProfilePic(ImageSource.camera),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 5.0,),
                  ClipOval(
                    child: Material(
                      color: Colors.white,
                      child: Center(
                        child: Ink(
                          decoration: const ShapeDecoration(
                            color: Colors.lightBlue,
                            shape: CircleBorder(),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.photo_library),
                            color: Colors.white,
                            onPressed: () => editProfilePic(ImageSource.gallery),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _showPage(),
    );
  }
}