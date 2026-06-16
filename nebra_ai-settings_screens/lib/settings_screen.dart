import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'job_selection_screen.dart';
import 'login_option_screen.dart';
import 'package:http/http.dart' as http;
import 'change_password_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  String? firestoreImageUrl;
  bool isNotificationOn = true;
  File? myImage;
  final ImagePicker imgPicker = ImagePicker();
  User? user = FirebaseAuth.instance.currentUser;
  @override

  void initState () {
   super.initState();
   loadUserImage();
  }

  Future<void> pickerImage(ImageSource source) async {
    final pickedImage = await imgPicker.pickImage(source: source);

    if (pickedImage != null) {
      setState(() {
        myImage = File(pickedImage.path);
      });
      await uploadImage();
    }

  }
  Future<void> loadUserImage() async {
  try {
    var doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user?.uid)
        .get();

    if (doc.exists) {
      setState(() {
        firestoreImageUrl = doc.data()?["image"];
      });
    }
  } catch (e) {
    print("Error loading image: $e");
  }
}
Future<String> getImageUrl(String path) async{
String? token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
 if (token == null){
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Authentication error")),);
  throw Exception("Token is null");}
  
  var uri = Uri.parse("https://image-server-az0e.onrender.com/image?path=$path", );

  var response = await http.get(
    uri, headers:{"Authorization": "Bearer $token",},);

        if(response.statusCode == 200){
          var data = jsonDecode(response.body);

          return data["url"];
        }else{
          throw Exception("Failed to get image URL");
        }
 }

  Future<void> uploadImage() async {
      if (myImage == null) return;

    try {
         String? token = await FirebaseAuth.instance.currentUser?.getIdToken(true);

        if (token == null){
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Authentication error")),); return;}

      var uri = Uri.parse("https://image-server-az0e.onrender.com/upload");

      var request = http.MultipartRequest("POST", uri);

      request.headers["Authorization"] = "Bearer $token";

      request.files.add( await http.MultipartFile.fromPath("file", myImage!.path),);

      var response = await request.send();

      if(response.statusCode == 200){
        var resData = await http.Response.fromStream(response);
        var jsonData = jsonDecode(resData.body);

        String filePath = jsonData['filePath'];

        String imageUrl = await getImageUrl(filePath);

 await FirebaseFirestore.instance.collection("users").doc(user?.uid).set({
        "image": imageUrl,
        "path": filePath,
      }, SetOptions(merge: true));
      setState(() {
        firestoreImageUrl=imageUrl;
      });
      await user?.updatePhotoURL(imageUrl);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Image updated successfully")));
    } else{ 
      print("Server Error Code: ${response.statusCode}"); 
  throw Exception("Updated failed with code: ${response.statusCode}");
    } 
      } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }


  void showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Choose Image",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text("Camera"),
                onTap: () {
                  Navigator.pop(context);
                  pickerImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo),
                title: Text("Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  pickerImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
     Navigator.pushReplacement(context,
     MaterialPageRoute(builder: (_) => LoginOptionScreen()),); 
  }

void goToSession() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const JobSelectionScreen()),
    );
  }

  void goToHome() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen(userName: '',)),
    );
  }
  @override
  Widget build(BuildContext context) {
        const navColor = Color(0xFF001B34);

    return Scaffold(
      body: Container(
          width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF003E52), Color(0xFF004A60), Color(0xFF002F4A)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(width: 100),
                      Text(
                        "Settings",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40),

                  Row(
                    children: [
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (myImage != null) {
                                showDialog(
                                  context: context,
                                  builder: (_) =>
                                      Dialog(child: Image.file(myImage!)),
                                );
                              }
                            },
                            child: CircleAvatar(
                              radius: 45,
                              backgroundColor: Colors.grey.shade300,
                              backgroundImage: myImage != null
                                  ? FileImage(myImage!)
                                  : (firestoreImageUrl != null
                                            ? NetworkImage(firestoreImageUrl!)
                                            : (user?.photoURL !=null?
                                            NetworkImage(user!.photoURL!):null))
                                        as ImageProvider?,
                              child: myImage == null && user?.photoURL == null
                                  ? Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 5, //0
                            right: 5, //0
                            child: InkWell(
                              child: GestureDetector(
                                onTap: showImageSourceDialog,
                                child: CircleAvatar(
                                  radius: 15,
                                  backgroundColor: Colors.white,
                                  child: Icon(Icons.camera_alt, size: 16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.displayName ?? "No name",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            user?.email ?? "No email",
                            style: TextStyle(color: Colors.white70),
                          ),
                          SizedBox(height: 10),
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pushNamed("editprofile");
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xff023493),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "Edit Profile",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 40),

                  buildItem(
                    icon: Icons.lock_outline,
                    title: "Change Password",
                    onTap: () {
                      Navigator.push(
                        context,MaterialPageRoute(builder: 
                        (context) => const
                        ChangePasswordScreen()),);
                    },
                  ),
                  Divider(color: Colors.white24),
                 
                  buildItem(
                    icon: Icons.logout,
                    title: "Log out",
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text("Logout"),
                          content: Text("Are you sure to logout?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                await logout();
                              },
                              child: Text("Yes"),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
   
    backgroundColor: navColor,
      bottomNavigationBar: Container(
        height: 70,
        color: navColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            buildNavItem(
              icon: Icons.home_rounded,
              label: "Home",
              isActive: true,
              onTap: () {},
            ),
            buildNavItem(
              icon: Icons.mic_rounded,
              label: "Session",
              onTap: goToSession,
            ),
            buildNavItem(
              icon: Icons.settings,
              label: "Settings",
              onTap: goToHome,
            ),
          ],
        ),
      ), );
  }

  Widget buildItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
  
  Widget buildNavItem({
    required IconData icon,
    required String label,
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    final color = isActive ? const Color(0xFF48A5FF) : Colors.white;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: Colors.white24,
        highlightColor: Colors.white10,
        child: SizedBox(
          width: 70,
          height: 60,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
