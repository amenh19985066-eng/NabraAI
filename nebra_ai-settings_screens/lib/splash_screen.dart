
import 'package:flutter/material.dart'; 
import 'dart:async';
import 'login_option_screen.dart';




class SplashScreen extends StatefulWidget{
   const SplashScreen ({super.key});
 

  @override
  State<SplashScreen> createState()=>_SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>{

   @override
  void initState(){
  super.initState();

    Timer(const Duration(seconds:2),(){
    if(mounted){
    Navigator.pushReplacement(
      context,
       MaterialPageRoute(builder: (context)=> const  LoginOptionScreen(),
                     ),
                 );
           }
    });
  }
  Widget build(BuildContext context){
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
          ),
        
         
         child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/NabraAI.png",fit:BoxFit.fill,width: 250),

            const SizedBox(height:20), //مسافة 
             
            const Padding(
            padding: EdgeInsets.only(bottom:30),
            child: 
            Text ("AI-Powered interview Training", 
             textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54, 
                fontWeight: FontWeight.w300,
                fontSize:  14,
                letterSpacing: 1.5, 
                  ),
                ),
              ),
            ],
          ),
        ),
      ); 
  }
}
