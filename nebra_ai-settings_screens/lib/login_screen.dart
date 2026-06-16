import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nebra_ai/home_screen.dart'; 
import 'Create_account.dart';

class LoginToYourAccount extends StatefulWidget{

      final String?  initialEmail;
      final String? initialPassword;
       const LoginToYourAccount({super.key,this.initialEmail, this.initialPassword});

   
   @override
  State<LoginToYourAccount> createState() => _LoginToYourAccountState();
 }

 class _LoginToYourAccountState extends State<LoginToYourAccount>{

  bool rememberMe =false;
  bool isPasswordHidden=true;
  final TextEditingController emailController =TextEditingController();
  final TextEditingController passwordController =TextEditingController();
     
     @override
     void dispose(){
        emailController.dispose();
         passwordController.dispose();
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
                const Text(" Login to your Account", 
                 style: TextStyle(fontSize: 26,
                 fontWeight: FontWeight.bold,color:
                  Colors.white),
                  ),

                const SizedBox(height: 50),

                const Text("Email",
                  style: TextStyle(color: Colors.white70)
                  ),
                 const SizedBox(height:10),

                TextField( 
                 controller:emailController,
                 style: const TextStyle(color: Colors.white),
                 decoration: InputDecoration(
                 hintText: "Maryam@gmail.com",
                 hintStyle: TextStyle(color: Colors.white24),
                 filled:true,
                 fillColor: Color(0xFF001F33),
                 contentPadding: 
                 const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                 border: OutlineInputBorder(
                 borderRadius: BorderRadius.circular(30),
                 borderSide: BorderSide.none, 
                  ),
                 ),
                ),

               const SizedBox(height: 25),
          
               const Text("Password",
                 style: TextStyle(color: Colors.white70)
                 ),
                 
                const SizedBox(height:10),

              TextField( 
                controller:passwordController,
                obscureText: isPasswordHidden,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                hintText: "*********",
                hintStyle:const TextStyle(color: Colors.white30),
                filled:true,
                fillColor:  Color(0xFF001F33),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                suffixIcon:IconButton(
                  onPressed: (){
                      setState(() {
                         isPasswordHidden=! isPasswordHidden;
                      });
                  },
                 icon: Icon(
                    isPasswordHidden
                     ? Icons.visibility_off
                     : Icons.visibility,
                     color: Colors.white54,
                    
                     ),
                ),
               border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
               ),
               ),
             ),
               const SizedBox(height: 15),

               
              
                   const SizedBox(height: 25),

                   SizedBox(
                  width: double.infinity,
                  height: 55,   
                 child: ElevatedButton(onPressed: () async{
               
               if (emailController.text.trim().isEmpty||
               passwordController.text.trim().isEmpty){
                  ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text(
                                "Please fill all fields",
                           textAlign: TextAlign.right,
                            ),
                          backgroundColor: Colors.orange,
                      ),
                   );
                    return;
                   }

               try {
                final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                  email: emailController.text.trim(),
                  password: passwordController.text.trim(),
                );
                String nameFromDB ="User";
                String uid= credential.user!.uid;

               try{
               DocumentSnapshot userDoc = await FirebaseFirestore
               .instance
               .collection('users')
               .doc(uid)
               .get();
               if(userDoc.exists){
                nameFromDB = userDoc.get('name')??"User";
                }else if(credential.user!.displayName != null) {
                   nameFromDB = credential.user!.displayName!;
                }
               }catch(e){
                 debugPrint("Error fetching name: $e");
               }
                 if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Welcome back $nameFromDB",
                              textAlign: TextAlign.right,
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                       
                     Navigator.pushAndRemoveUntil(context,MaterialPageRoute(
                       builder: (context)=>  HomeScreen(userName: nameFromDB)),
                        (route) => false,
                  );
                 }
                 } on FirebaseAuthException catch (e) {
                   String message = "login failed" ;
                    if (e.code == 'user-not-found'|| e.code=='invalial-credential') {
                      message ="Incorrect email address or password";
                      } else if (e.code == 'wrong-password') {
                      message = "Incorrect password";
                      }
                      if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(message, textAlign: TextAlign.right),
                            backgroundColor: Colors.red,
                          ),
                         );
                       }  } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "inaccuracy: $e",
                              textAlign: TextAlign.right,
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  
        
               },
               style: ElevatedButton.styleFrom(
                 backgroundColor:const Color (0xFF0D1783),
                 shape: RoundedRectangleBorder(
                 borderRadius: BorderRadius.circular(30),
                  ),
               ), 
              child: Text("Login",
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
               const Text("Don't Have an Account ? " ,
                style:TextStyle( color: Colors.white54),
               ),
               GestureDetector(onTap:() {
                 Navigator.push(context, MaterialPageRoute(builder: (context)=> const CreateAccount(),
                     ),
                 );
               },
               child:const Text (
                "Sign up",
               style:TextStyle(color:
                Colors.blueAccent,
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

 