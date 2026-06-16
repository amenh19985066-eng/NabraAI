import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmotionAnalysisApp extends StatelessWidget {
  final double confidence;
  final double anxiety;
  final double anger;
  final double neutral;

  const EmotionAnalysisApp({
    super.key,
    required this.confidence,
    required this.anxiety,
    required this.anger,
    required this.neutral,
  });

  @override
  Widget build(BuildContext context) {
   
    double total = confidence + anxiety + anger + neutral;
    
    double pConf = total > 0 ? (confidence / total) * 100 : 0;
    double pAnx = total > 0 ? (anxiety / total) * 100 : 0;
    double pAng = total > 0 ? (anger / total) * 100 : 0;
    double pNeu = total > 0 ? (neutral / total) * 100 : 100;

    return AnalysisScreen(
      confidence: pConf,
      anxiety: pAnx,
      anger: pAng,
      neutral: pNeu,
    );
  }

}

class AnalysisScreen extends StatelessWidget {
  final double confidence;
  final double anxiety;
  final double anger;
  final double neutral;

  const AnalysisScreen({
    super.key,
    required this.confidence,
    required this.anxiety,
    required this.anger,
    required this.neutral,
  });

  String _getDominantEmotion() {
    Map<String, double> emotions = {
      'confidence': confidence,
      'anxiety': anxiety,
      'anger': anger,
      'neutral': neutral,
    };
    return emotions.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  String _getSummaryText() {
    String dominant = _getDominantEmotion();
    switch (dominant) {
      case 'confidence':
        return "Your tone showed high confidence\nwith minimal anxiety";
      case 'anxiety':
        return "Your tone indicates some anxiety";
      case 'anger':
        return "Your tone sounds a bit intense";
      case 'neutral':
      default:
        return "Your voice was steady and balanced";
    }
  }

  Future<void> _saveReport(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('sessions')
          .add({
        'date': FieldValue.serverTimestamp(),
        'confidence': confidence,
        'anxiety': anxiety,
        'anger': anger,
        'neutral': neutral,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Report saved successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving report: $e")),
      );
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
            colors: [Color(0xFF081C2E), Color(0xFF020A10)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildChartCard(),
                      const SizedBox(height: 20),
                      _buildFeedbackCard(),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () => _saveReport(context),
                        child: const Text("Save report",
                            style: TextStyle(color: Colors.blueAccent)),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white10,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white),
                 onPressed: () {
                 final user = FirebaseAuth.instance.currentUser;
                 String currentUserName = user?.displayName ?? 'User';
                 Navigator.pushNamedAndRemoveUntil(
                 context, '/home', (route) => false,

                  arguments: currentUserName);
                   },
                ),
              ),
              const Expanded(
                child: Text(
                  "Speech Emotion Analysis\nReport",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
          const SizedBox(height: 10),
          const Text("Here's your AI-powered voice analysis report",
              style: TextStyle(color: Colors.white54, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildChartCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          const Text("Your Emotion Analysis Result",
              style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w600, fontSize: 18)),
          const SizedBox(height: 30),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 50,
                sections: [
                  if (confidence > 0) _chartSection(confidence, const Color(0xFF3F51B5)),
                  if (neutral > 0) _chartSection(neutral, const Color(0xFF00E5FF)),
                  if (anxiety > 0) _chartSection(anxiety, const Color(0xFF7E57C2)),
                  if (anger > 0) _chartSection(anger, const Color(0xFF00E676)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Wrap(
            spacing: 15, runSpacing: 10, alignment: WrapAlignment.center,
            children: [
              _LegendItem(label: "Confidence", color: Color(0xFF3F51B5)),
              _LegendItem(label: "Neutral Tone", color: Color(0xFF00E5FF)),
              _LegendItem(label: "Anxiety", color: Color(0xFF7E57C2)),
              _LegendItem(label: "Anger", color: Color(0xFF00E676)),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            _getSummaryText(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w500, height: 1.4, color: Colors.white),
          ),
        ],
      ),
    );
  }

  PieChartSectionData _chartSection(double value, Color color) {
    return PieChartSectionData(
      color: color,
      value: value,
      radius: 50,
      showTitle: false,
      badgeWidget: _Badge('${value.toStringAsFixed(0)}%'),
      badgePositionPercentageOffset: .98,
    );
  }

  Widget _buildFeedbackCard() {
    String dominant = _getDominantEmotion();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          const Text("Feedback",
              style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w600, fontSize: 18)),
          const SizedBox(height: 20),

          if (dominant == 'confidence')
            const _FeedbackItem(
              title: "Your tone was confident but a bit rushed",
              subtitle: "Try to slow down for clarity and better impact",
            )
          else if (dominant == 'anxiety')
            const _FeedbackItem(
              title: "You sounded slightly nervous at the start",
              subtitle: "Try to take deep breaths for more stability",
            )
          else if (dominant == 'neutral')
              const _FeedbackItem(
                title: "Your voice was calm and consistent",
                subtitle: "Excellent delivery! You sounded very professional.",
              )
            else if (dominant == 'anger')
                const _FeedbackItem(
                  title: "Your delivery had a strong, firm edge",
                  subtitle: "Try to maintain a calmer pace and volume",
                ),
        ],
      ),
    );
  }
}


class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;
  const _LegendItem({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }
}

class _FeedbackItem extends StatelessWidget {
  final String title, subtitle;
  const _FeedbackItem({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
        const SizedBox(height: 4),
        Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Colors.white54)),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge(this.text);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [
        BoxShadow(color: Colors.black26, blurRadius: 4),
      ]),
      child: Text(text, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10)),
    );
  }
}