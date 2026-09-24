import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddQuestionScreen extends StatefulWidget {
  const AddQuestionScreen({super.key});

  @override
  State<AddQuestionScreen> createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _optionAController = TextEditingController();
  final _optionBController = TextEditingController();
  final _optionCController = TextEditingController();
  final _optionDController = TextEditingController();
  final _marksController = TextEditingController(text: '1');
  String _correctOption = 'A';
  Map<String, dynamic>? _exam;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _exam = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
  }

  @override
  void dispose() {
    _questionController.dispose();
    _optionAController.dispose();
    _optionBController.dispose();
    _optionCController.dispose();
    _optionDController.dispose();
    _marksController.dispose();
    super.dispose();
  }

  Future<void> _addQuestion() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.post('/questions', {
        'examId': _exam?['id'] ?? '',
        'questionText': _questionController.text.trim(),
        'optionA': _optionAController.text.trim(),
        'optionB': _optionBController.text.trim(),
        'optionC': _optionCController.text.trim(),
        'optionD': _optionDController.text.trim(),
        'correctOption': _correctOption,
        'marks': int.tryParse(_marksController.text) ?? 1,
      });
      if (result['success'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Question added!'), backgroundColor: Colors.green),
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
      appBar: AppBar(title: Text('Add Question - ${_exam?['title'] ?? ''}')),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _questionController,
                        maxLines: 3,
                        decoration: const InputDecoration(labelText: 'Question Text', prefixIcon: Icon(Icons.help)),
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      const Text('Options:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...[
                        ('A', _optionAController),
                        ('B', _optionBController),
                        ('C', _optionCController),
                        ('D', _optionDController),
                      ].map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: TextFormField(
                              controller: item.$2,
                              decoration: InputDecoration(
                                labelText: 'Option ${item.$1}',
                                prefixIcon: CircleAvatar(
                                  radius: 14,
                                  backgroundColor: _correctOption == item.$1 ? Colors.green : Colors.grey.shade300,
                                  child: Text(item.$1, style: const TextStyle(fontSize: 12, color: Colors.white)),
                                ),
                              ),
                              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                            ),
                          )),
                      const SizedBox(height: 8),
                      const Text('Correct Answer:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        children: ['A', 'B', 'C', 'D'].map((option) {
                          return Expanded(
                            child: RadioListTile<String>(
                              title: Text(option),
                              value: option,
                              groupValue: _correctOption,
                              onChanged: (v) => setState(() => _correctOption = v!),
                              dense: true,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _marksController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Marks for this question', prefixIcon: Icon(Icons.star)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _addQuestion,
                  icon: _isLoading
                      ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save),
                  label: const Text('Save Question', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
