import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  String? firestoreImageUrl;
  final formKey = GlobalKey<FormState>();
  User? user = FirebaseAuth.instance.currentUser;
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  File? myImage;
  final ImagePicker imgPicker = ImagePicker();
  //User? user = FirebaseAuth.instance.currentUser;

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

  @override
  void initState() {
    super.initState();
    firstNameController.text = user?.displayName ?? "";
    lastNameController.text = "";
    emailController.text = user?.email ?? "";
    loadUserImage();
  }

  void saveChanges() async {
    if (formKey.currentState!.validate()) {
      try {
        await user?.updateDisplayName("${firstNameController.text}${lastNameController.text}");
       

        if (emailController.text != user?.email) {
          await user?.verifyBeforeUpdateEmail(emailController.text);
        }
     //   if (passwordController.text.isNotEmpty) {
          //await user?.updatePassword(passwordController.text);
       // }
      

        Future<void> reauthenticate(String currentPassword) async {
          AuthCredential credential = EmailAuthProvider.credential(
            email: user!.email!,
            password: currentPassword,
          );
          await user!.reauthenticateWithCredential(credential);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Updated successfully")));
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: CircleAvatar(
                          backgroundColor: Colors.white24,
                          child: Padding(
                            padding: EdgeInsets.only(left: 5),
                            child: Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 100),

                      Text(
                        "Edit Profile",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),

                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 70,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: myImage != null
                              ? FileImage(myImage!)
                              : (firestoreImageUrl != null
                                        ? NetworkImage(firestoreImageUrl!)
                                        : (user?.photoURL!=null?
                                        NetworkImage(user!.photoURL!): null))
                                    as ImageProvider?,
                          child: myImage == null && user?.photoURL == null
                              ? Icon(
                                  Icons.person,
                                  size: 70,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 22,
                            backgroundColor: Color(0xff194A7B),
                            child: Icon(Icons.edit, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 40),
                  buildField("Frist Name", firstNameController),
                  buildField("Last Name", lastNameController),
                  buildField("Email", emailController),
                 // buildField("Password", passwordController, isPassword: true),

                  SizedBox(height: 40),

                  Center(
                    child: GestureDetector(
                      onTap: saveChanges,
                      child: Container(
                        width: 220,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: Color(0xff02308B),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            "Save changes",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget buildField(
  String title,
  TextEditingController controller, {
  bool isPassword = false,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 10),
      TextFormField(
        controller: controller,
        obscureText: isPassword,
        style: TextStyle(color: Colors.white),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "This field is required";
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: title,
          hintStyle: TextStyle(color: Colors.white54),
          filled: true,
          fillColor: Colors.white24,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      SizedBox(height: 20),
    ],
  );
}
