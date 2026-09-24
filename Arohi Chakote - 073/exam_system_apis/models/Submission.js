// Submission Model
class Submission {
  constructor({ id, examId, userId, answers, submittedAt, timeTaken }) {
    this.id = id || null;
    this.examId = examId || '';
    this.userId = userId || '';
    this.answers = answers || {}; // { questionId: selectedOption }
    this.submittedAt = submittedAt || new Date().toISOString();
    this.timeTaken = timeTaken || 0; // in seconds
    this.createdAt = new Date().toISOString();
  }

  toJSON() {
    return {
      id: this.id,
      examId: this.examId,
      userId: this.userId,
      answers: this.answers,
      submittedAt: this.submittedAt,
      timeTaken: this.timeTaken,
      createdAt: this.createdAt,
    };
  }
}

module.exports = Submission;
