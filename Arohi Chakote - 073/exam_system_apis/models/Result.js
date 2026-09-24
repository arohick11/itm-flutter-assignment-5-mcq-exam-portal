// Result Model
class Result {
  constructor({ id, examId, userId, submissionId, totalMarks, obtainedMarks, percentage, correctAnswers, wrongAnswers, skippedAnswers, grade, passed }) {
    this.id = id || null;
    this.examId = examId || '';
    this.userId = userId || '';
    this.submissionId = submissionId || '';
    this.totalMarks = totalMarks || 0;
    this.obtainedMarks = obtainedMarks || 0;
    this.percentage = percentage || 0;
    this.correctAnswers = correctAnswers || 0;
    this.wrongAnswers = wrongAnswers || 0;
    this.skippedAnswers = skippedAnswers || 0;
    this.grade = grade || 'F';
    this.passed = passed !== undefined ? passed : false;
    this.createdAt = new Date().toISOString();
  }

  static calculateGrade(percentage) {
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B';
    if (percentage >= 60) return 'C';
    if (percentage >= 50) return 'D';
    return 'F';
  }

  toJSON() {
    return {
      id: this.id,
      examId: this.examId,
      userId: this.userId,
      submissionId: this.submissionId,
      totalMarks: this.totalMarks,
      obtainedMarks: this.obtainedMarks,
      percentage: this.percentage,
      correctAnswers: this.correctAnswers,
      wrongAnswers: this.wrongAnswers,
      skippedAnswers: this.skippedAnswers,
      grade: this.grade,
      passed: this.passed,
      createdAt: this.createdAt,
    };
  }
}

module.exports = Result;
