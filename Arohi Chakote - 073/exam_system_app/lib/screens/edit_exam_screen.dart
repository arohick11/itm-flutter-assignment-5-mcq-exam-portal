import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EditExamScreen extends StatefulWidget {
  final Map<String, dynamic> exam;
  const EditExamScreen({super.key, required this.exam});

  @override
  State<EditExamScreen> createState() => _EditExamScreenState();
}

class _EditExamScreenState extends State<EditExamScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _subjectController;
  late TextEditingController _durationController;
  late TextEditingController _marksController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.exam['title'] ?? '');
    _descController = TextEditingController(text: widget.exam['description'] ?? '');
    _subjectController = TextEditingController(text: widget.exam['subject'] ?? '');
    _durationController = TextEditingController(text: widget.exam['duration']?.toString() ?? '60');
    _marksController = TextEditingController(text: widget.exam['totalMarks']?.toString() ?? '100');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _subjectController.dispose();
    _durationController.dispose();
    _marksController.dispose();
    super.dispose();
  }

  Future<void> _updateExam() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.put('/exams/${widget.exam['id']}', {
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'subject': _subjectController.text.trim(),
        'duration': int.tryParse(_durationController.text) ?? 60,
        'totalMarks': int.tryParse(_marksController.text) ?? 100,
      });
      if (result['success'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exam updated successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Exam')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(labelText: 'Exam Title', prefixIcon: Icon(Icons.title)),
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descController,
                        maxLines: 3,
                        decoration: const InputDecoration(labelText: 'Description', prefixIcon: Icon(Icons.description)),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _subjectController,
                        decoration: const InputDecoration(labelText: 'Subject', prefixIcon: Icon(Icons.subject)),
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _durationController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Duration (min)', prefixIcon: Icon(Icons.timer)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _marksController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Total Marks', prefixIcon: Icon(Icons.star)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _updateExam,
                  icon: _isLoading
                      ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.update),
                  label: const Text('Update Exam', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
