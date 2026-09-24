const express = require('express');
const router = express.Router();
const { addDocument, getCollection, getDocument, queryCollection } = require('../config/db');
const Submission = require('../models/Submission');
const Result = require('../models/Result');

// Get all submissions
router.get('/', (req, res) => {
  try {
    const { userId, examId } = req.query;
    let submissions;
    if (userId) {
      submissions = queryCollection('submissions', { userId });
    } else if (examId) {
      submissions = queryCollection('submissions', { examId });
    } else {
      submissions = getCollection('submissions');
    }
    res.json({ success: true, data: submissions });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// Get submission by ID
router.get('/:id', (req, res) => {
  try {
    const submission = getDocument('submissions', req.params.id);
    if (!submission) {
      return res.status(404).json({ success: false, message: 'Submission not found' });
    }
    res.json({ success: true, data: submission });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// Submit exam - auto-calculate result
router.post('/', (req, res) => {
  try {
    const { examId, userId, answers, timeTaken } = req.body;

    if (!examId || !userId || !answers) {
      return res.status(400).json({ success: false, message: 'examId, userId, and answers are required' });
    }

    // Save submission
    const newSubmission = new Submission({ examId, userId, answers, timeTaken });
    const savedSubmission = addDocument('submissions', newSubmission);

    // Get questions for this exam to calculate result
    const questions = getCollection('questions').filter((q) => q.examId === examId);
    const exam = getDocument('exams', examId);

    let correctAnswers = 0;
    let wrongAnswers = 0;
    let skippedAnswers = 0;
    let obtainedMarks = 0;

    questions.forEach((question) => {
      const userAnswer = answers[question.id];
      if (!userAnswer) {
        skippedAnswers++;
      } else if (userAnswer === question.correctOption) {
        correctAnswers++;
        obtainedMarks += question.marks || 1;
      } else {
        wrongAnswers++;
      }
    });

    const totalMarks = exam ? exam.totalMarks : questions.reduce((sum, q) => sum + (q.marks || 1), 0);
    const percentage = totalMarks > 0 ? Math.round((obtainedMarks / totalMarks) * 100) : 0;
    const grade = Result.calculateGrade(percentage);
    const passed = percentage >= 50;

    // Save result
    const newResult = new Result({
      examId,
      userId,
      submissionId: savedSubmission.id,
      totalMarks,
      obtainedMarks,
      percentage,
      correctAnswers,
      wrongAnswers,
      skippedAnswers,
      grade,
      passed,
    });
    const savedResult = addDocument('results', newResult);

    res.status(201).json({
      success: true,
      message: 'Exam submitted successfully',
      data: {
        submission: savedSubmission,
        result: savedResult,
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
