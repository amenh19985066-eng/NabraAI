import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'emotion_report_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class InterviewScreen extends StatefulWidget {
  final String jobTitle;

  const InterviewScreen({super.key, required this.jobTitle});

  @override
  State<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends State<InterviewScreen>
    with SingleTickerProviderStateMixin {
  bool isRecording = false;
  bool isLoading = true;
  int currentQuestionIndex = 0;
  List<String> interviewQuestions = [];
  late AnimationController _controller;
  final AudioRecorder audioRecorder = AudioRecorder(); 
String? recordedFilePath; 
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    fetchQuestionsFromAzure();
  }

  Future<void> fetchQuestionsFromAzure() async {
    const String apiKey = "YOURABI";
    const String fullUrl = "https://tu435-mmaype9p-eastus2.cognitiveservices.azure.com/openai/deployments/nabra-questions-model-v3/chat/completions?api-version=2024-10-21";

    try {
      final response = await http.post(
        Uri.parse(fullUrl),
        headers: {"Content-Type": "application/json", "api-key": apiKey.trim()},
        body: jsonEncode({
          "messages": [
            {"role": "user", "content": "Generate 5 interview questions in English for a ${widget.jobTitle} position. Return only the questions, one per line."}
          ],
        }),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String content = data["choices"][0]["message"]["content"];
        List<String> questions = content.trim().split(RegExp(r'[\n\r]+')).map((q) => q.replaceAll(RegExp(r'^\d+[\.\)]\s*'), '').trim()).where((q) => q.isNotEmpty).toList();

        if (!mounted) return;
        setState(() { interviewQuestions = questions; isLoading = false; });
      }
    } catch (e) {
      setState(() { interviewQuestions = ["Exception: ${e.toString()}"]; isLoading = false; });
    }
  }

Future<void> uploadAndAnalyze() async {
  if (recordedFilePath == null) {
    print("No recording found!"); //
    return;
  }

  setState(() => isLoading = true);
  var url = Uri.parse('https://amnah040-nebra-ai.hf.space/analyze');

  try {
    var request = http.MultipartRequest('POST', url);
    var audiofile = File(recordedFilePath!);
        var audioBytes = await audiofile.readAsBytes();
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      audioBytes,
      filename: 'recording.wav',
    ));

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EmotionAnalysisApp(
            confidence: data['confidence'].toDouble(),
            anxiety: data['anxiety'].toDouble(),
            anger: data['anger'].toDouble(),
            neutral: data['neutral'].toDouble(),
          ),
        ),
      );
    }
  } catch (e) {
    print("Connection error: $e"); //
  } finally {
    if (mounted) setState(() => isLoading = false);
  }
}

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String getCurrentQuestion() {
    if (interviewQuestions.isEmpty || currentQuestionIndex >= interviewQuestions.length) return "Loading...";
    return interviewQuestions[currentQuestionIndex];
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Container(
      width: double.infinity, height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF003E52), Color(0xFF002F4A)]
        )
      ),
      child: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : SingleChildScrollView( 
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20), 
                    _buildAnimation(),
                    const SizedBox(height: 30),
                    _buildQuestionArea(),
                    const SizedBox(height: 50), 
                    _buildControlPanel(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    ),
  );
}

  Widget _buildAnimation() {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: NabraMeshPainter(animationValue: _controller.value, isRecording: isRecording),
            child: const SizedBox(width: 260, height: 260),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Align(alignment: Alignment.centerLeft, child: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22), onPressed: () => Navigator.pop(context))),
         Expanded(child: 
          Column(
            children: [
              const Text("Interview Question", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Text("Question ${currentQuestionIndex + 1}/${interviewQuestions.length}", style: const TextStyle(color: Colors.white54, fontSize: 13)),
            ],
          ),)
        ],
      ),
    );
  }

  Widget _buildQuestionArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Text("\" ${getCurrentQuestion()} \"", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w500)),
          const SizedBox(height: 30),
          Text("Speak clearly and naturally\nwhen ready", textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMicButton(),
              
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  if (currentQuestionIndex < interviewQuestions.length - 1) {
                    setState(() { currentQuestionIndex++; isRecording = false; _controller.reset(); });
                  }
                },
                child: const Text("Next question", style: TextStyle(color: Color(0xFF4796BD), fontWeight: FontWeight.bold)),
              ),
             
TextButton(
  onPressed: () {
   
    uploadAndAnalyze(); 
  },
  child: Row(
    children: [
      const Text(
        "Finish & Analyze", 
        style: TextStyle(color: Color(0xFF4796BD), fontWeight: FontWeight.bold)
      ),
      const Icon(Icons.arrow_forward, color: Color(0xFF4796BD), size: 18),
    ],
  ),
),
            ],
          ),
        ],
      ),
    );
  }

 Widget _buildMicButton() {
  return GestureDetector(
    onTap: () async {
      if (isRecording) {
        final path = await audioRecorder.stop();
        setState(() {
          isRecording = false;
          recordedFilePath = path; 
          _controller.stop();
        });
      } else {
        if (await audioRecorder.hasPermission()) {
          final directory = await
          getTemporaryDirectory();
         
          final myPath = '${directory.path}/recording.wav';
          const config = RecordConfig(
            encoder: AudioEncoder.wav, 
          ); 
          
          await audioRecorder.start(config, path: myPath); 
          setState(() {
            isRecording = true;
            _controller.repeat();
          });
        }
      }
    },
    child: Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF4796BD), Color(0xFF1B4152)],
        ),
        boxShadow: isRecording
            ? [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 20)]
            : [],
      ),
      child: Icon(
        isRecording ? Icons.stop : Icons.mic,
        color: Colors.white,
        size: 35,
      ),
    ),
  );
}
 
}

class NabraMeshPainter extends CustomPainter {
  final double animationValue;
  final bool isRecording;
  NabraMeshPainter({required this.animationValue, required this.isRecording});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width * 0.42;
    final paint = Paint()..style = PaintingStyle.fill;
    const int count = 30; 

    for (int i = 0; i <= count; i++) {
      double phi = math.pi * i / count;
      for (int j = 0; j < count; j++) {
        double theta = 2 * math.pi * j / count;
        double x = math.sin(phi) * math.cos(theta);
        double y = math.cos(phi);
        double z = math.sin(phi) * math.sin(theta);

        double waterFlow = math.sin(phi * 3 + theta * 1.5 + animationValue * math.pi * 3);
        double displacement = 1.0 + (waterFlow * (isRecording ? 0.08 : 0.04));
        double currentRadius = baseRadius * displacement;
        double perspective = (z + 1) / 2;

        paint.color = Color.lerp(const Color(0xFF915FB5), const Color(0xFF4796BD), (phi / math.pi).clamp(0, 1))!.withOpacity(0.1 + (perspective * 0.8));
        canvas.drawCircle(Offset(center.dx + x * currentRadius, center.dy + y * currentRadius), 0.7 * (0.5 + perspective), paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}