// Exam Model
class Exam {
  constructor({ id, title, description, subject, duration, totalMarks, createdBy, isActive }) {
    this.id = id || null;
    this.title = title || '';
    this.description = description || '';
    this.subject = subject || '';
    this.duration = duration || 60; // in minutes
    this.totalMarks = totalMarks || 100;
    this.createdBy = createdBy || '';
    this.isActive = isActive !== undefined ? isActive : true;
    this.createdAt = new Date().toISOString();
  }

  toJSON() {
    return {
      id: this.id,
      title: this.title,
      description: this.description,
      subject: this.subject,
      duration: this.duration,
      totalMarks: this.totalMarks,
      createdBy: this.createdBy,
      isActive: this.isActive,
      createdAt: this.createdAt,
    };
  }
}

module.exports = Exam;
