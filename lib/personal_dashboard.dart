import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PersonalDashboard extends StatefulWidget {
  const PersonalDashboard({super.key});

  @override
  State<PersonalDashboard> createState() => _PersonalDashboardState();
}

class _PersonalDashboardState extends State<PersonalDashboard> {
  final TextEditingController _problemController = TextEditingController();
  String _aiResponse =
      "Explain your legal problem above, and I will act as your legal advocate.";
  bool _isLoading = false;

  // WARNING: In a production app, never hardcode the API key. This is just for your prototype.
  static const String _apiKey = 'AIzaSyCktZ3fIuP5dqOYsfGuVnO6pHHyxlJmoYk';

  Future<void> _analyzeLegalProblem() async {
    if (_problemController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _aiResponse =
          "Analyzing legal procedures and formatting court documents...";
    });

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-pro',
        apiKey: _apiKey,
        systemInstruction: Content.system(
          'You are an expert legal advocate in India. Analyze the user\'s problem. If it is small, provide step-by-step guidance and draft court-acceptable formatted documents. If it requires a lawyer, suggest finding an advocate and estimate the legal fees.',
        ),
      );

      final prompt = _problemController.text;
      final response = await model.generateContent([Content.text(prompt)]);

      setState(() {
        _aiResponse = response.text ?? "No response generated.";
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _aiResponse = "Error connecting to AI: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nyaya - Personal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _problemController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Enter your legal issue here...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _analyzeLegalProblem,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                padding: const EdgeInsets.all(16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Draft Legal Solution & Documents'),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _aiResponse,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
