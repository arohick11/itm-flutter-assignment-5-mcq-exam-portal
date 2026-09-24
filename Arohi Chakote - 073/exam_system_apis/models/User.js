// User Model
class User {
  constructor({ id, name, email, password, role, profileImage }) {
    this.id = id || null;
    this.name = name || '';
    this.email = email || '';
    this.password = password || '';
    this.role = role || 'student'; // 'student' or 'admin'
    this.profileImage = profileImage || '';
    this.createdAt = new Date().toISOString();
  }

  toJSON() {
    return {
      id: this.id,
      name: this.name,
      email: this.email,
      role: this.role,
      profileImage: this.profileImage,
      createdAt: this.createdAt,
    };
  }
}

module.exports = User;
