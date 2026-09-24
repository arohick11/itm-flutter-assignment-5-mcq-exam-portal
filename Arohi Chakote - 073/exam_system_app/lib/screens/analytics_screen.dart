import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  List<Map<String, dynamic>> _results = [];
  List<Map<String, dynamic>> _exams = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final resultsResponse = await ApiService.get('/results');
      final examsResponse = await ApiService.get('/exams');
      if (mounted) {
        setState(() {
          _results = List<Map<String, dynamic>>.from(resultsResponse['data'] ?? []);
          _exams = List<Map<String, dynamic>>.from(examsResponse['data'] ?? []);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  double get _averageScore {
    if (_results.isEmpty) return 0;
    final total = _results.fold<double>(0, (sum, r) => sum + (r['percentage'] ?? 0));
    return total / _results.length;
  }

  int get _passCount => _results.where((r) => r['passed'] == true).length;
  int get _failCount => _results.where((r) => r['passed'] != true).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary cards
                    const Text('Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _AnalyticsCard(
                          title: 'Total Exams',
                          value: _exams.length.toString(),
                          icon: Icons.quiz,
                          color: Colors.blue,
                        ),
                        _AnalyticsCard(
                          title: 'Total Submissions',
                          value: _results.length.toString(),
                          icon: Icons.assignment_turned_in,
                          color: Colors.green,
                        ),
                        _AnalyticsCard(
                          title: 'Pass Rate',
                          value: _results.isEmpty ? '0%' : '${(_passCount / _results.length * 100).toStringAsFixed(1)}%',
                          icon: Icons.check_circle,
                          color: Colors.green,
                        ),
                        _AnalyticsCard(
                          title: 'Avg Score',
                          value: '${_averageScore.toStringAsFixed(1)}%',
                          icon: Icons.bar_chart,
                          color: Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Pass/Fail Breakdown
                    const Text('Pass/Fail Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    _passCount.toString(),
                                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.green),
                                  ),
                                  const Text('Passed', style: TextStyle(color: Colors.green)),
                                ],
                              ),
                            ),
                            Container(width: 1, height: 60, color: Colors.grey.shade300),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    _failCount.toString(),
                                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.red),
                                  ),
                                  const Text('Failed', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Recent results
                    if (_results.isNotEmpty) ...[
                      const Text('Recent Results', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      ...(_results.take(5).toList()).map((result) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: result['passed'] == true ? Colors.green : Colors.red,
                                child: Text(
                                  result['grade'] ?? 'F',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text('User: ${result['userId'] ?? 'N/A'}'),
                              subtitle: Text('${result['percentage']}% • ${result['obtainedMarks']}/${result['totalMarks']} marks'),
                            ),
                          )),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _AnalyticsCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            Text(title, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
