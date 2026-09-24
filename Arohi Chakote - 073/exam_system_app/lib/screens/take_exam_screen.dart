import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TakeExamScreen extends StatefulWidget {
  final Map<String, dynamic> exam;
  const TakeExamScreen({super.key, required this.exam});

  @override
  State<TakeExamScreen> createState() => _TakeExamScreenState();
}

class _TakeExamScreenState extends State<TakeExamScreen> {
  List<Map<String, dynamic>> _questions = [];
  Map<String, String> _answers = {};
  int _currentIndex = 0;
  int _remainingSeconds = 0;
  Timer? _timer;
  bool _isLoading = true;
  bool _isSubmitting = false;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = (widget.exam['duration'] ?? 60) * 60;
    _startTime = DateTime.now();
    _loadQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    try {
      final response = await ApiService.get('/questions?examId=${widget.exam['id']}');
      if (mounted) {
        setState(() {
          _questions = List<Map<String, dynamic>>.from(response['data'] ?? []);
          _isLoading = false;
        });
        _startTimer();
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        timer.cancel();
        _submitExam();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  String get _timerText {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Color get _timerColor {
    if (_remainingSeconds < 60) return Colors.red;
    if (_remainingSeconds < 300) return Colors.orange;
    return Colors.green;
  }

  Future<void> _submitExam() async {
    _timer?.cancel();
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Submit Exam'),
        content: Text('You have answered ${_answers.length} of ${_questions.length} questions. Submit now?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Submit')),
        ],
      ),
    );

    if (confirm != true) {
      _startTimer(); // restart timer if they cancel
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final timeTaken = DateTime.now().difference(_startTime!).inSeconds;
      final result = await ApiService.post('/submissions', {
        'examId': widget.exam['id'],
        'userId': 'guest', // Replace with actual user ID
        'answers': _answers,
        'timeTaken': timeTaken,
      });

      if (result['success'] == true && mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/exam-result',
          arguments: result['data']['result'],
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Scaffold(appBar: AppBar(title: Text(widget.exam['title'] ?? '')), body: const Center(child: CircularProgressIndicator()));

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.exam['title'] ?? '')),
        body: const Center(child: Text('No questions available for this exam.')),
      );
    }

    final currentQ = _questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exam['title'] ?? ''),
        automaticallyImplyLeading: false,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: _timerColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(_timerText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress
          LinearProgressIndicator(value: (_currentIndex + 1) / _questions.length),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Question ${_currentIndex + 1} of ${_questions.length}'),
                Text('${_answers.length} answered', style: const TextStyle(color: Colors.green)),
              ],
            ),
          ),

          // Question
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: const Color(0xFF6C63FF),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        currentQ['questionText'] ?? '',
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...['A', 'B', 'C', 'D'].map((option) {
                    final optionText = currentQ['option$option'] ?? '';
                    final isSelected = _answers[currentQ['id']] == option;
                    return GestureDetector(
                      onTap: () => setState(() => _answers[currentQ['id']] = option),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF6C63FF).withOpacity(0.1) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF6C63FF) : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: isSelected ? const Color(0xFF6C63FF) : Colors.grey.shade200,
                              child: Text(
                                option,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(optionText)),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Navigation
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Row(
              children: [
                if (_currentIndex > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _currentIndex--),
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentIndex > 0) const SizedBox(width: 12),
                Expanded(
                  child: _currentIndex < _questions.length - 1
                      ? ElevatedButton(
                          onPressed: () => setState(() => _currentIndex++),
                          child: const Text('Next'),
                        )
                      : ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitExam,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: _isSubmitting
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Submit'),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
