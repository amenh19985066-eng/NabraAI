import 'package:flutter/material.dart';
import 'interview_screen.dart';

class JobSelectionScreen extends StatefulWidget {
  const JobSelectionScreen({super.key});

  @override
  State<JobSelectionScreen> createState() => _JobSelectionScreenState();
}

class _JobSelectionScreenState extends State<JobSelectionScreen> {
  
  final List<String> jobs = [
    "Programmer",
    "Software Engineer",
    "Administration",
    "Graphic designer",
    "Marketing Specialist",
  ];

  
  int selectedJobIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF003E52), Color(0xFF002F4A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                      onPressed: () {Navigator.pop(context);},
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Select Your Job Title",
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade200.withOpacity(0.2),
                    hintText: "Enter your job title",
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(Icons.search, color: Colors.white54),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  ),
                ),
              ),

              Container(
                height: 350, 
                margin: const EdgeInsets.symmetric(horizontal: 25),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B4152).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(35),
                  border: Border.all(color: Colors.white10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(35),
                  child: ListView.builder(
                    itemCount: jobs.length,
                    itemBuilder: (context, index) => buildJobItem(jobs[index], index),
                  ),
                ),
              ),

              const Spacer(), 

              
              Padding(
                padding: const EdgeInsets.only(bottom: 30, right: 30),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                   onPressed: () {
  
  if (selectedJobIndex != -1) {
    
    
    Navigator.push(
      context,
      MaterialPageRoute(
        
        builder: (context) => InterviewScreen(
          jobTitle: jobs[selectedJobIndex], 
        ),
      ),
    );
    
  } else {
    
    print("Please select a job title first");
  }
},
                    label: const Icon(Icons.arrow_forward, color: Color(0xFF4796BD)),
                    icon: const Text(
                      "Start Interview Simulation",
                      style: TextStyle(color: Color(0xFF4796BD), fontWeight: FontWeight.bold),
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

 
  Widget buildJobItem(String title, int index) {
    bool isSelected = selectedJobIndex == index;
    return GestureDetector(
      onTap: () => setState(() => selectedJobIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
        color: isSelected ? Colors.white.withOpacity(0.05) : Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontSize: 17)),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                border: Border.all(color: isSelected ? Colors.white : Colors.white24, width: 1.5),
                borderRadius: BorderRadius.circular(5),
              ),
              child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
            ),
          ],
        ),
      ),
    );
  }
}