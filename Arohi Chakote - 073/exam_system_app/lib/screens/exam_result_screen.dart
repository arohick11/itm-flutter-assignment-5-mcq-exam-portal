import 'package:flutter/material.dart';

class ExamResultScreen extends StatelessWidget {
  final Map<String, dynamic> result;
  const ExamResultScreen({super.key, required this.result});

  Color get _gradeColor {
    final grade = result['grade'] ?? 'F';
    switch (grade) {
      case 'A+':
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.blue;
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.yellow.shade700;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final passed = result['passed'] == true;
    final percentage = (result['percentage'] ?? 0).toDouble();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Result'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Result header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: passed ? [Colors.green, Colors.green.shade700] : [Colors.red, Colors.red.shade700],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    passed ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                    size: 60,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    passed ? 'Congratulations!' : 'Better Luck Next Time!',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    passed ? 'You passed the exam!' : 'You did not pass',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Grade and score
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: _gradeColor,
                      child: Text(
                        result['grade'] ?? 'F',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${result['obtainedMarks'] ?? 0} / ${result['totalMarks'] ?? 0} Marks',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Stats breakdown
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Detailed Breakdown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _StatRow(label: 'Correct Answers', value: result['correctAnswers']?.toString() ?? '0', color: Colors.green, icon: Icons.check_circle),
                    _StatRow(label: 'Wrong Answers', value: result['wrongAnswers']?.toString() ?? '0', color: Colors.red, icon: Icons.cancel),
                    _StatRow(label: 'Skipped', value: result['skippedAnswers']?.toString() ?? '0', color: Colors.grey, icon: Icons.remove_circle),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Actions
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/student-dashboard', (route) => false),
                icon: const Icon(Icons.home),
                label: const Text('Back to Dashboard', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/my-results'),
                icon: const Icon(Icons.leaderboard),
                label: const Text('View All Results', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatRow({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
        ],
      ),
    );
  }
}
