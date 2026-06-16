
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; 
import 'login_screen.dart';

class CreateAccount extends StatefulWidget{
   const CreateAccount({super.key});
   
     @override
     State<StatefulWidget> createState() => _CreateAccountState();

   
}

class _CreateAccountState extends State<CreateAccount>{

    final TextEditingController emailController =TextEditingController();
    final TextEditingController passwordController =TextEditingController();
    final TextEditingController  confirmPasswordController =TextEditingController();
    final TextEditingController  nameController = TextEditingController();

        
     @override
     void dispose(){
        emailController.dispose();
        passwordController.dispose();
        confirmPasswordController.dispose();
        nameController.dispose();
        super.dispose();
     }
     
     @override
     Widget build(BuildContext context) {
       return  Scaffold(
        body:Container(
          width: double.infinity,
          height:double.infinity,
            decoration: const BoxDecoration(
            gradient:LinearGradient(
               colors: [
                Color(0xFF003E52),
                Color(0xFF004A60),
                Color(0xFF002F4A)
                ],
                begin :Alignment.topCenter,
                end:Alignment.bottomCenter,
            ),
          ),//
        
            
            child: SingleChildScrollView(
             padding: const EdgeInsets.symmetric(horizontal: 25),
             child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 100),

                const Text("Create Account", 
                 style: TextStyle(fontSize: 26,
                 fontWeight:FontWeight.bold,color:
                  Colors.white),
                  ),

                const SizedBox(height: 30),

                const Text("Name",
                 style: TextStyle(color: Colors.white70)),
                 
                const SizedBox(height:10),

                TextField( 
                 style: const TextStyle(color: Colors.white),
                 controller: nameController,
                 decoration: InputDecoration(
                 hintText: "ex:Maryam",
                 hintStyle: TextStyle(color: Colors.white24),
                 filled:true,
                 fillColor: Color(0xFF001F33),
                 contentPadding: 
                 const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                 border: OutlineInputBorder(
                 borderRadius: BorderRadius.circular(30),
                 borderSide: BorderSide.none) 
                  ),
                 ),
             
               const SizedBox(height: 20),
                
                const Text("Email",
                 style: TextStyle(color: Colors.white70)),
                 
                const SizedBox(height:10),

              TextField( 
                controller: emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                hintText: "Maryam@gmail.com",
                hintStyle:const TextStyle(color: Colors.white30),
                filled:true,
                fillColor:  Color(0xFF001F33),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
               border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none) ,
               ),
               ),
                const SizedBox(height:20),

               const Text("Password",
                 style: TextStyle(color: Colors.white70)),
                 
                const SizedBox(height:10),

              TextField( 
                controller: passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                hintText: "*********",
                hintStyle:const TextStyle(color: Colors.white30),
                filled:true,
                fillColor:  Color(0xFF001F33),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
               border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none) ,
               ),
               ),
               const SizedBox(height: 20),

               const Text("Confirm password",
                 style: TextStyle(color: Colors.white70)),
                 
                const SizedBox(height:10),

              TextField( 
                controller: confirmPasswordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                hintText: "*********",
                hintStyle:const TextStyle(color: Colors.white30),
                filled:true,
                fillColor:  Color(0xFF001F33),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
               border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none) ,
               ),
               ),
                
               
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 55,   
               child: ElevatedButton(onPressed: ()async{
                    
                    if (nameController.text.trim().isEmpty ||
                        emailController.text.trim().isEmpty ||
                        passwordController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Please fill in all fields",
                            textAlign: TextAlign.left,
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }
                  
                   if (passwordController.text !=
                        confirmPasswordController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                             "Passwords do not match",
                            textAlign: TextAlign.left,
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                  try{
        
                    final userCredential =await FirebaseAuth.instance.createUserWithEmailAndPassword(
                     email: emailController.text.trim(),
                     password:passwordController.text.trim(),
                    );

                      await userCredential.user!.updateDisplayName(
                        nameController.text.trim(),
                      );


                          await FirebaseFirestore.instance
                          .collection('users')
                          .doc(userCredential.user!.uid)
                          .set({
                            "name": nameController.text.trim(),
                            "email": emailController.text.trim(),
                            "uid": userCredential.user!.uid,
                            "created_at": FieldValue.serverTimestamp(),
                          });

                          if (!context.mounted) return;

                           await FirebaseAuth.instance.signOut();
                          if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Account created successfully! Please log in with your new details ",
                            textAlign: TextAlign.left,
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                       
                      Navigator.pushAndRemoveUntil(
                        context,MaterialPageRoute(
                        builder:(context)=>const LoginToYourAccount(
                          
                       ),
                      ),
                       (route) => false,
                       );
                      } on FirebaseAuthException catch (e) {
                      String message = "Account creation failed";
                      if (e.code == 'weak-password') {
                        message = "The password is very weak";
                      } else if (e.code == 'email-already-in-use') {
                        message = "This email address is already in use";
                      } else if (e.code == 'invalid-email') {
                        message = "Invalid email address";
                      }

                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(message, textAlign: TextAlign.left),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "An unexpected error occurred: $e",
                            textAlign: TextAlign.left,
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
          
               style: ElevatedButton.styleFrom(
                 backgroundColor:const Color (0xFF0D1783),
                 shape: RoundedRectangleBorder(
                 borderRadius: BorderRadius.circular(30),
                  ),
               ), 
              child: Text("create Account",
               style:TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold),
              ),
              ),
              ),
        
               const SizedBox(height:25),
             Row(
              mainAxisAlignment:MainAxisAlignment.center,
              children: [
               const Text(" Have an Account ? " , style:TextStyle( color: Colors.white54),
               ),
               GestureDetector(onTap:() {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> const  LoginToYourAccount (),
                     ),
                 );
               },
               child:const Text (" Login",
               style:TextStyle(color: Colors.blueAccent,
               fontWeight: FontWeight.bold),
                              ),
                            ),
                                     
                        ],
                       ),
                      ],
                    ),
                    ),
                    ), 
           );
         } 
        }
   
