import 'package:flutter/material.dart';
import 'settings_screen.dart';

class SwitchScreen extends StatefulWidget{
   const SwitchScreen({super.key});

  @override
  SwitchScreenState createState() => SwitchScreenState(); 

  
  }

class SwitchScreenState extends State<SwitchScreen>{
int currentIndex = 0;

final List<Widget> screens =[
  // HomeScreen(),
  // SessionScreen(),
  // ReportsScreen(),
   SettingsScreen(),

];

@override
Widget build(BuildContext context){
return Scaffold(

  body: IndexedStack(
    index: currentIndex,
    children: screens,
  ),

  bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF062F3F),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.white54,
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mic),
            label: "Session",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: "Reports",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
);

}

}


