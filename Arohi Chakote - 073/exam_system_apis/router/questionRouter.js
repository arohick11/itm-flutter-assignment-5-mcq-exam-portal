const express = require('express');
const router = express.Router();
const { addDocument, getCollection, getDocument, updateDocument, deleteDocument, queryCollection } = require('../config/db');
const Question = require('../models/Question');

// Get all questions
router.get('/', (req, res) => {
  try {
    const { examId } = req.query;
    let questions;
    if (examId) {
      questions = queryCollection('questions', { examId });
    } else {
      questions = getCollection('questions');
    }
    res.json({ success: true, data: questions });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// Get question by ID
router.get('/:id', (req, res) => {
  try {
    const question = getDocument('questions', req.params.id);
    if (!question) {
      return res.status(404).json({ success: false, message: 'Question not found' });
    }
    res.json({ success: true, data: question });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// Create new question
router.post('/', (req, res) => {
  try {
    const { examId, questionText, optionA, optionB, optionC, optionD, correctOption, marks, imageUrl } = req.body;

    if (!examId || !questionText || !optionA || !optionB || !optionC || !optionD || !correctOption) {
      return res.status(400).json({ success: false, message: 'All question fields are required' });
    }

    const newQuestion = new Question({ examId, questionText, optionA, optionB, optionC, optionD, correctOption, marks, imageUrl });
    const saved = addDocument('questions', newQuestion);

    res.status(201).json({ success: true, message: 'Question created successfully', data: saved });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// Update question
router.put('/:id', (req, res) => {
  try {
    const updated = updateDocument('questions', req.params.id, req.body);
    if (!updated) {
      return res.status(404).json({ success: false, message: 'Question not found' });
    }
    res.json({ success: true, message: 'Question updated successfully', data: updated });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// Delete question
router.delete('/:id', (req, res) => {
  try {
    const deleted = deleteDocument('questions', req.params.id);
    if (!deleted) {
      return res.status(404).json({ success: false, message: 'Question not found' });
    }
    res.json({ success: true, message: 'Question deleted successfully' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
