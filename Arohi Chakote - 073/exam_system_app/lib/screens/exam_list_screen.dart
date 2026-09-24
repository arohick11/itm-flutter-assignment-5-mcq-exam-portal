import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ExamListScreen extends StatefulWidget {
  const ExamListScreen({super.key});

  @override
  State<ExamListScreen> createState() => _ExamListScreenState();
}

class _ExamListScreenState extends State<ExamListScreen> {
  List<Map<String, dynamic>> _exams = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExams();
  }

  Future<void> _loadExams() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get('/exams');
      if (mounted) {
        setState(() {
          _exams = List<Map<String, dynamic>>.from(response['data'] ?? []);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteExam(String examId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Exam'),
        content: const Text('Are you sure you want to delete this exam?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await ApiService.delete('/exams/$examId');
      _loadExams();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Exams'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, '/add-exam').then((_) => _loadExams()),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadExams,
              child: _exams.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.quiz_outlined, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text('No exams yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(context, '/add-exam').then((_) => _loadExams()),
                            icon: const Icon(Icons.add),
                            label: const Text('Add Exam'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _exams.length,
                      itemBuilder: (context, index) {
                        final exam = _exams[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF6C63FF),
                              child: Text(
                                exam['subject']?.substring(0, 1).toUpperCase() ?? 'E',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(exam['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text('${exam['subject']} • ${exam['duration']} min'),
                            trailing: PopupMenuButton(
                              itemBuilder: (ctx) => [
                                PopupMenuItem(
                                  child: const ListTile(leading: Icon(Icons.visibility), title: Text('View')),
                                  onTap: () => Navigator.pushNamed(context, '/exam-detail', arguments: exam),
                                ),
                                PopupMenuItem(
                                  child: const ListTile(leading: Icon(Icons.edit), title: Text('Edit')),
                                  onTap: () => Navigator.pushNamed(context, '/edit-exam', arguments: exam).then((_) => _loadExams()),
                                ),
                                PopupMenuItem(
                                  child: const ListTile(leading: Icon(Icons.quiz), title: Text('Questions')),
                                  onTap: () => Navigator.pushNamed(context, '/question-list', arguments: exam),
                                ),
                                PopupMenuItem(
                                  child: const ListTile(leading: Icon(Icons.delete, color: Colors.red), title: Text('Delete', style: TextStyle(color: Colors.red))),
                                  onTap: () => _deleteExam(exam['id']),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add-exam').then((_) => _loadExams()),
        child: const Icon(Icons.add),
      ),
    );
  }
}
