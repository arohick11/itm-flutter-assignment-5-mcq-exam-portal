import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EditQuestionScreen extends StatefulWidget {
  final Map<String, dynamic> question;
  const EditQuestionScreen({super.key, required this.question});

  @override
  State<EditQuestionScreen> createState() => _EditQuestionScreenState();
}

class _EditQuestionScreenState extends State<EditQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _questionController;
  late TextEditingController _optionAController;
  late TextEditingController _optionBController;
  late TextEditingController _optionCController;
  late TextEditingController _optionDController;
  late TextEditingController _marksController;
  late String _correctOption;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.question['questionText'] ?? '');
    _optionAController = TextEditingController(text: widget.question['optionA'] ?? '');
    _optionBController = TextEditingController(text: widget.question['optionB'] ?? '');
    _optionCController = TextEditingController(text: widget.question['optionC'] ?? '');
    _optionDController = TextEditingController(text: widget.question['optionD'] ?? '');
    _marksController = TextEditingController(text: widget.question['marks']?.toString() ?? '1');
    _correctOption = widget.question['correctOption'] ?? 'A';
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

  Future<void> _updateQuestion() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.put('/questions/${widget.question['id']}', {
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
          const SnackBar(content: Text('Question updated!'), backgroundColor: Colors.green),
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
      appBar: AppBar(title: const Text('Edit Question')),
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
                        decoration: const InputDecoration(labelText: 'Question Text'),
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      ...[
                        ('A', _optionAController),
                        ('B', _optionBController),
                        ('C', _optionCController),
                        ('D', _optionDController),
                      ].map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: TextFormField(
                              controller: item.$2,
                              decoration: InputDecoration(labelText: 'Option ${item.$1}'),
                              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                            ),
                          )),
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
                      TextFormField(
                        controller: _marksController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Marks'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _updateQuestion,
                  icon: _isLoading
                      ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.update),
                  label: const Text('Update Question', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
