// Question Model
class Question {
  constructor({ id, examId, questionText, optionA, optionB, optionC, optionD, correctOption, marks, imageUrl }) {
    this.id = id || null;
    this.examId = examId || '';
    this.questionText = questionText || '';
    this.optionA = optionA || '';
    this.optionB = optionB || '';
    this.optionC = optionC || '';
    this.optionD = optionD || '';
    this.correctOption = correctOption || 'A'; // 'A', 'B', 'C', or 'D'
    this.marks = marks || 1;
    this.imageUrl = imageUrl || '';
    this.createdAt = new Date().toISOString();
  }

  toJSON() {
    return {
      id: this.id,
      examId: this.examId,
      questionText: this.questionText,
      optionA: this.optionA,
      optionB: this.optionB,
      optionC: this.optionC,
      optionD: this.optionD,
      correctOption: this.correctOption,
      marks: this.marks,
      imageUrl: this.imageUrl,
      createdAt: this.createdAt,
    };
  }
}

module.exports = Question;
