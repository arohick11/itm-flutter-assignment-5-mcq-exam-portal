// Firebase configuration with in-memory fallback
// To use Firebase, replace the config below with your Firebase Admin SDK credentials

let db = null;
let useFirebase = false;

// In-memory data store (fallback when Firebase is not configured)
const inMemoryDB = {
  users: [],
  exams: [],
  questions: [],
  submissions: [],
  results: [],
};

let idCounters = {
  users: 1,
  exams: 1,
  questions: 1,
  submissions: 1,
  results: 1,
};

const connectDB = async () => {
  try {
    // Attempt Firebase connection (comment out if no Firebase config)
    // const admin = require('firebase-admin');
    // const serviceAccount = require('./serviceAccountKey.json');
    // admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
    // db = admin.firestore();
    // useFirebase = true;
    // console.log('Connected to Firebase Firestore');

    // Using in-memory DB for this demo
    console.log('Using in-memory database (Firebase fallback)');
  } catch (error) {
    console.log('Firebase not configured, using in-memory DB:', error.message);
  }
};

// Generic CRUD helpers for in-memory DB
const getCollection = (collectionName) => inMemoryDB[collectionName] || [];

const addDocument = (collectionName, data) => {
  const id = String(idCounters[collectionName]++);
  const doc = { id, ...data, createdAt: new Date().toISOString() };
  inMemoryDB[collectionName].push(doc);
  return doc;
};

const getDocument = (collectionName, id) => {
  return inMemoryDB[collectionName].find((doc) => doc.id === id) || null;
};

const updateDocument = (collectionName, id, data) => {
  const index = inMemoryDB[collectionName].findIndex((doc) => doc.id === id);
  if (index === -1) return null;
  inMemoryDB[collectionName][index] = {
    ...inMemoryDB[collectionName][index],
    ...data,
    updatedAt: new Date().toISOString(),
  };
  return inMemoryDB[collectionName][index];
};

const deleteDocument = (collectionName, id) => {
  const index = inMemoryDB[collectionName].findIndex((doc) => doc.id === id);
  if (index === -1) return false;
  inMemoryDB[collectionName].splice(index, 1);
  return true;
};

const queryCollection = (collectionName, filters = {}) => {
  let results = [...inMemoryDB[collectionName]];
  Object.entries(filters).forEach(([key, value]) => {
    results = results.filter((doc) => doc[key] === value);
  });
  return results;
};

module.exports = {
  connectDB,
  db,
  useFirebase,
  inMemoryDB,
  getCollection,
  addDocument,
  getDocument,
  updateDocument,
  deleteDocument,
  queryCollection,
};
