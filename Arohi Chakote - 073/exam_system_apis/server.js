const express = require('express');
const cors = require('cors');
const userRouter = require('./router/userRouter');
const examRouter = require('./router/examRouter');
const questionRouter = require('./router/questionRouter');
const submissionRouter = require('./router/submissionRouter');
const resultRouter = require('./router/resultRouter');
const { connectDB } = require('./config/db');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Connect to Firebase DB
connectDB();

// Routes
app.use('/api/users', userRouter);
app.use('/api/exams', examRouter);
app.use('/api/questions', questionRouter);
app.use('/api/submissions', submissionRouter);
app.use('/api/results', resultRouter);

// Health check
app.get('/', (req, res) => {
  res.json({ message: 'MCQ Exam Portal API is running!', status: 'OK' });
});

// Port setup
const PORT = process.env.PORT || 3000;
const tryPort = (port) => {
  app.listen(port, () => {
    console.log(`Server running on port ${port}`);
  }).on('error', (err) => {
    if (err.code === 'EADDRINUSE') {
      console.log(`Port ${port} in use, trying ${port + 1}...`);
      tryPort(port + 1);
    } else {
      console.error('Server error:', err);
    }
  });
};

tryPort(PORT);
