import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nebra_ai/emotion_report_screen.dart';
import 'job_selection_screen.dart';
import 'settings_screen.dart';

class SessionModel {
  final String title;
  final String date;

  const SessionModel({required this.title, required this.date});
}

class HomeScreen extends StatefulWidget {
  final String userName;
  final List<SessionModel> sessions;

  const HomeScreen({
    super.key,
    required this.userName,
    this.sessions = const [],
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<SessionModel> filteredSessions;

  @override
  void initState() {
    super.initState();
    filteredSessions = widget.sessions;
  }

  void searchSessions(String text) {
    setState(() {
      filteredSessions = widget.sessions.where((session) {
        final title = session.title.toLowerCase();
        final date = session.date.toLowerCase();
        final searchText = text.toLowerCase();

        return title.contains(searchText) || date.contains(searchText);
      }).toList();
    });
  }

  void goToSession() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const JobSelectionScreen()),
    );
  }

  void goToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    const navColor = Color(0xFF001B34);

    return Scaffold(
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
              onTap: goToSettings,
            ),
          ],
        ),
      ),
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
            padding: const EdgeInsets.fromLTRB(32, 42, 32, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildHeader(),
                const SizedBox(height: 29),
                buildSearchBar(),
                const SizedBox(height: 20),
                buildStartCard(),
                const SizedBox(height: 18),
                const Text(
                  "History",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(child: buildHistoryBox()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome, ${widget.userName}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              "Ready for a new training session?",
              style: TextStyle(color: Color(0xFFB5C4D1), fontSize: 11.5),
            ),
          ],
        ),
        
      ],
    );
  }

  Widget buildSearchBar() {
    return Container(
      height: 36,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(22),
      ),
      child: TextField(
        onChanged: searchSessions,
        style: const TextStyle(color: Colors.white, fontSize: 11, height: 1.2),
        textAlignVertical: TextAlignVertical.center,
        decoration: const InputDecoration(
          isCollapsed: true,
          hintText: "Search for sessions ...",
          hintStyle: TextStyle(color: Colors.white54, fontSize: 11),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: Colors.white54, size: 18),
          prefixIconConstraints: BoxConstraints(minWidth: 28, minHeight: 28),
        ),
      ),
    );
  }

  Widget buildStartCard() {
    return InkWell(
      onTap: goToSession,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        height: 205,
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 25),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFD7D3EE),
              Color(0xFFB7C5C7),
              Color(0xFF88D6D0),
              Color(0xFF1B3E51),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 29,
              height: 29,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.45),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.mic, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 25),
            const Padding(
              padding: EdgeInsets.only(left: 15),
              child: Text(
                "Start Interview\nSimulation",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  height: 1.08,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(left: 14),
              child: Container(
                width: 115,
                height: 29,
                decoration: BoxDecoration(
                  color: const Color(0xFF5EB0E1),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.75),
                    width: 1,
                  ),
                ),
                child: const Center(
                  child: Text(
                    "Start Session",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHistoryBox() {
    final user=
    FirebaseAuth.instance.currentUser;
    
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 128, maxHeight: 170),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('sessions')
        .orderBy('date',descending: true)
        .snapshots(),
        builder: (context, snapshot) {
          if(!snapshot.hasData||
          snapshot.data!.docs.isEmpty){
            return const Center(child: Text("No session yet",style:TextStyle(color:Colors.white70,fontSize: 12)));
          } 
          return ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: snapshot.data!.docs.length,
          separatorBuilder: (context, index) => Divider(height: 1, color: Colors.white12),
          itemBuilder: (context, index) {
            var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            var date = (data['date'] as Timestamp?)?.toDate() ?? DateTime.now();

            return ListTile(
              dense: true,
              title: Text("Analysis Report", style: TextStyle(color: Color(0xFF47A5FF), fontSize: 11, fontWeight: FontWeight.bold)),
              subtitle: Text("Date: ${date.day}/${date.month}/${date.year}", style: TextStyle(color: Colors.white70, fontSize: 10)),
              trailing: const Text("View Report →", style: TextStyle(color: Colors.white, fontSize: 9)),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>
                EmotionAnalysisApp(confidence: (data['confidence'] ??0.0).toDouble(), anxiety: (data['anxiety'] ??0.0).toDouble(), anger: (data['anger'] ??0.0).toDouble(), neutral: (data['netural'] ??0.0).toDouble()),
                
                ),
            );
              },
            );
          },
        );
      },
    ),
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
