import 'package:flutter/material.dart';
import '../services/api_service.dart';

class QuestionListScreen extends StatefulWidget {
  const QuestionListScreen({super.key});

  @override
  State<QuestionListScreen> createState() => _QuestionListScreenState();
}

class _QuestionListScreenState extends State<QuestionListScreen> {
  Map<String, dynamic>? _exam;
  List<Map<String, dynamic>> _questions = [];
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _exam = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get('/questions?examId=${_exam?['id']}');
      if (mounted) {
        setState(() {
          _questions = List<Map<String, dynamic>>.from(response['data'] ?? []);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteQuestion(String questionId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Question'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await ApiService.delete('/questions/$questionId');
      _loadQuestions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_exam?['title'] ?? 'Questions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, '/add-question', arguments: _exam).then((_) => _loadQuestions()),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadQuestions,
              child: _questions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.help_outline, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text('No questions yet', style: TextStyle(fontSize: 16, color: Colors.grey)),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(context, '/add-question', arguments: _exam).then((_) => _loadQuestions()),
                            icon: const Icon(Icons.add),
                            label: const Text('Add Question'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _questions.length,
                      itemBuilder: (context, index) {
                        final q = _questions[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF6C63FF),
                              child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
                            ),
                            title: Text(q['questionText'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                            subtitle: Text('Correct: ${q['correctOption']} • ${q['marks']} mark(s)'),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _OptionRow(label: 'A', text: q['optionA'] ?? '', isCorrect: q['correctOption'] == 'A'),
                                    _OptionRow(label: 'B', text: q['optionB'] ?? '', isCorrect: q['correctOption'] == 'B'),
                                    _OptionRow(label: 'C', text: q['optionC'] ?? '', isCorrect: q['correctOption'] == 'C'),
                                    _OptionRow(label: 'D', text: q['optionD'] ?? '', isCorrect: q['correctOption'] == 'D'),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton.icon(
                                          onPressed: () => Navigator.pushNamed(context, '/edit-question', arguments: q).then((_) => _loadQuestions()),
                                          icon: const Icon(Icons.edit),
                                          label: const Text('Edit'),
                                        ),
                                        TextButton.icon(
                                          onPressed: () => _deleteQuestion(q['id']),
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          label: const Text('Delete', style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add-question', arguments: _exam).then((_) => _loadQuestions()),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  final String label;
  final String text;
  final bool isCorrect;

  const _OptionRow({required this.label, required this.text, required this.isCorrect});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isCorrect ? Colors.green : Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, color: isCorrect ? Colors.green : Colors.grey),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
          if (isCorrect) const Icon(Icons.check_circle, color: Colors.green, size: 16),
        ],
      ),
    );
  }
}
