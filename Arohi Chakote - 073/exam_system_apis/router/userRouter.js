const express = require('express');
const router = express.Router();
const { addDocument, getCollection, queryCollection } = require('../config/db');
const User = require('../models/User');

// Register new user
router.post('/register', (req, res) => {
  try {
    const { name, email, password, role } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({ success: false, message: 'Name, email, and password are required' });
    }

    // Check if email already exists
    const users = getCollection('users');
    const existingUser = users.find((u) => u.email === email);
    if (existingUser) {
      return res.status(400).json({ success: false, message: 'Email already registered' });
    }

    const newUser = new User({ name, email, password, role: role || 'student' });
    const saved = addDocument('users', newUser);

    res.status(201).json({ success: true, message: 'User registered successfully', data: saved });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// Login user
router.post('/login', (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ success: false, message: 'Email and password are required' });
    }

    const users = getCollection('users');
    const user = users.find((u) => u.email === email && u.password === password);

    if (!user) {
      return res.status(401).json({ success: false, message: 'Invalid email or password' });
    }

    const { password: _, ...userWithoutPassword } = user;
    res.json({ success: true, message: 'Login successful', data: userWithoutPassword });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// Get all users (admin only)
router.get('/', (req, res) => {
  try {
    const users = getCollection('users').map(({ password, ...u }) => u);
    res.json({ success: true, data: users });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// Get user by ID
router.get('/:id', (req, res) => {
  try {
    const users = getCollection('users');
    const user = users.find((u) => u.id === req.params.id);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }
    const { password, ...userWithoutPassword } = user;
    res.json({ success: true, data: userWithoutPassword });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
