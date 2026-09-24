const express = require('express');
const router = express.Router();
const { addDocument, getCollection, getDocument, updateDocument, deleteDocument } = require('../config/db');
const Exam = require('../models/Exam');

// Get all exams
router.get('/', (req, res) => {
  try {
    const exams = getCollection('exams');
    res.json({ success: true, data: exams });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// Get exam by ID
router.get('/:id', (req, res) => {
  try {
    const exam = getDocument('exams', req.params.id);
    if (!exam) {
      return res.status(404).json({ success: false, message: 'Exam not found' });
    }
    res.json({ success: true, data: exam });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// Create new exam
router.post('/', (req, res) => {
  try {
    const { title, description, subject, duration, totalMarks, createdBy } = req.body;

    if (!title || !subject) {
      return res.status(400).json({ success: false, message: 'Title and subject are required' });
    }

    const newExam = new Exam({ title, description, subject, duration, totalMarks, createdBy });
    const saved = addDocument('exams', newExam);

    res.status(201).json({ success: true, message: 'Exam created successfully', data: saved });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// Update exam
router.put('/:id', (req, res) => {
  try {
    const updated = updateDocument('exams', req.params.id, req.body);
    if (!updated) {
      return res.status(404).json({ success: false, message: 'Exam not found' });
    }
    res.json({ success: true, message: 'Exam updated successfully', data: updated });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// Delete exam
router.delete('/:id', (req, res) => {
  try {
    const deleted = deleteDocument('exams', req.params.id);
    if (!deleted) {
      return res.status(404).json({ success: false, message: 'Exam not found' });
    }
    res.json({ success: true, message: 'Exam deleted successfully' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
