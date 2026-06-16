import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'splash_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try{
if(Firebase.apps.isEmpty){
  await Firebase.initializeApp(
    options:
   DefaultFirebaseOptions.currentPlatform);
} }catch (e){
  
}
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        "/home": (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final name = args is String ? args : "Raneem";
          return HomeScreen(userName: name);
        },
        "/settings": (context) => const SettingsScreen(),
        "editprofile": (context) => const EditProfileScreen(),
        "changepassword": (context) => const ChangePasswordScreen(),
      },
    );
  }
}
