const express = require('express');
const router = express.Router();
const { getCollection, getDocument, queryCollection } = require('../config/db');

// Get all results
router.get('/', (req, res) => {
  try {
    const { userId, examId } = req.query;
    let results;
    if (userId) {
      results = queryCollection('results', { userId });
    } else if (examId) {
      results = queryCollection('results', { examId });
    } else {
      results = getCollection('results');
    }
    res.json({ success: true, data: results });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// Get result by ID
router.get('/:id', (req, res) => {
  try {
    const result = getDocument('results', req.params.id);
    if (!result) {
      return res.status(404).json({ success: false, message: 'Result not found' });
    }
    res.json({ success: true, data: result });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// Get result by submission ID
router.get('/submission/:submissionId', (req, res) => {
  try {
    const results = getCollection('results');
    const result = results.find((r) => r.submissionId === req.params.submissionId);
    if (!result) {
      return res.status(404).json({ success: false, message: 'Result not found' });
    }
    res.json({ success: true, data: result });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
