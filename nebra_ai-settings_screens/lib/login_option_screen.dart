import 'package:flutter/material.dart';
import  'Create_account.dart';
import  'login_screen.dart';


class LoginOptionScreen extends StatelessWidget{
   const LoginOptionScreen ({super.key});
   
     @override
     Widget build(BuildContext context) {
      return  Scaffold(
        body:Container(
          width: double.infinity,
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
           
          child: Padding(
              padding:const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              mainAxisAlignment:MainAxisAlignment.center,
             children: [
                 Image.asset("assets/app_icon_square.png",width: 100),

                 const SizedBox(height:20), 
            
                 const  Text(
                   "Welcome to NabraAI ! Let's login to your account", 
                     style: TextStyle(fontSize: 18,
                     color: Colors.white,
                     fontWeight: FontWeight.bold,
                   ),
               ),
            
                  const SizedBox(height:40),

                  SizedBox(
                   width:  double.infinity,
                  height: 55,   
                  child: ElevatedButton.icon(onPressed: (){
                    
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> const LoginToYourAccount(),
                     ),
                   );
               },
               icon: const Icon(Icons.person, color: Colors.white),
               label: const Text(" Log In",
                  style:TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
               ),
               style: ElevatedButton.styleFrom(
                 backgroundColor:const Color (0xFF0D1783),
                 shape: RoundedRectangleBorder(
                 borderRadius: BorderRadius.circular(30),
                  ),
               ), 
           ),
         ),
             
            SizedBox(height:20),
       
            SizedBox(
                width:  double.infinity,
                height: 55,   
                child: OutlinedButton.icon(onPressed: (){
                    
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> const CreateAccount(),
                     ),
                   );

               },
               icon: const Icon(Icons.add_circle_outline, color: Colors.white),
               label: const Text(
                  "Create Account",
                  style:TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
               ),
               style: OutlinedButton.styleFrom(
                  side: const BorderSide(color:Colors.white),
                 shape: RoundedRectangleBorder(
                 borderRadius: BorderRadius.circular(30),
                          ),
                        ), 
                      ),
                    ), 
                 ],
               ),
               ),
           ),
          );
          }
}      

         
