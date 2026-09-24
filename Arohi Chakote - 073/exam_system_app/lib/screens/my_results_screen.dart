import 'package:flutter/material.dart';
import '../services/api_service.dart';

class MyResultsScreen extends StatefulWidget {
  const MyResultsScreen({super.key});

  @override
  State<MyResultsScreen> createState() => _MyResultsScreenState();
}

class _MyResultsScreenState extends State<MyResultsScreen> {
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get('/results');
      if (mounted) {
        setState(() {
          _results = List<Map<String, dynamic>>.from(response['data'] ?? []);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _gradeColor(String grade) {
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
    return Scaffold(
      appBar: AppBar(title: const Text('My Results')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadResults,
              child: _results.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.leaderboard_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No results yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final result = _results[index];
                        final grade = result['grade'] ?? 'F';
                        final passed = result['passed'] == true;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _gradeColor(grade),
                              child: Text(
                                grade,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text('Exam: ${result['examId'] ?? 'N/A'}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${result['obtainedMarks']} / ${result['totalMarks']} marks (${result['percentage']}%)'),
                                Row(
                                  children: [
                                    Icon(
                                      passed ? Icons.check_circle : Icons.cancel,
                                      size: 14,
                                      color: passed ? Colors.green : Colors.red,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      passed ? 'Passed' : 'Failed',
                                      style: TextStyle(color: passed ? Colors.green : Colors.red, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '✓ ${result['correctAnswers']}',
                                  style: const TextStyle(color: Colors.green, fontSize: 12),
                                ),
                                Text(
                                  '✗ ${result['wrongAnswers']}',
                                  style: const TextStyle(color: Colors.red, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
